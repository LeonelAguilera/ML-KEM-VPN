Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;
Use work.mlkem_types_pkg.all;
Use work.kpke_types_pks.all;

ENTITY kpke_decrypt IS
  PORT (
    clk : IN STD_LOGIC;
    start : IN STD_LOGIC;
    k : IN  INTEGER RANGE 2 TO 4;

    dk : IN byte_array_t(KPKE_DK_MAX_BYTES - 1 DOWNTO 0);          -- 384*k bytes used
    ciphertext : IN byte_array_t(KPKE_C_MAX_BYTES - 1 DOWNTO 0);   -- 32*(du*k + dv) bytes used

    m : OUT byte_array_t(KPKE_SEED_BYTES - 1 DOWNTO 0);
    done : OUT std_logic

  ) ;
END kpke_decrypt;

ARCHITECTURE rtl OF kpke_decrypt IS

  SIGNAL op_start   : STD_LOGIC;
  SIGNAL op_code    : INTEGER RANGE 0 TO 8;
  SIGNAL poly_index : INTEGER RANGE 0 TO 3;
  SIGNAL op_done    : STD_LOGIC := '0';
  SIGNAL k_op       : INTEGER RANGE 2 TO 4;      -- k latched by the controller at start

  SIGNAL s_hat : poly_vec_t;
  SIGNAL u     : poly_vec_t;
  SIGNAL v     : poly_t;
  SIGNAL acc   : poly_t;
  SIGNAL m_reg : byte_array_t(KPKE_SEED_BYTES - 1 DOWNTO 0) := (OTHERS => (OTHERS => '0'));


  --dk slice for s_hat[poly_index]
  SIGNAL dk_sel : byte_array_t(0 TO 32*12 - 1);
  SIGNAL s_dec  : poly_t;

    -- ciphertext slices: c1 part for u[poly_index], c2 part for v
  SIGNAL c1_10 : byte_array_t(32*10 - 1 DOWNTO 0);
  SIGNAL c1_11 : byte_array_t(32*11 - 1 DOWNTO 0);
  SIGNAL c2_4  : byte_array_t(32*4 - 1 DOWNTO 0);
  SIGNAL c2_5  : byte_array_t(32*5 - 1 DOWNTO 0);
  
  -- decode + decompress chains
  SIGNAL u_dec10, u_dec11, u_10, u_11 : poly_t;
  SIGNAL v_dec4,  v_dec5,  v_4,  v_5  : poly_t;

  -- shared arithmetic
  SIGNAL ntt_in, ntt_out  : poly_t;
  SIGNAL intt_out         : poly_t;
  SIGNAL mul_a, mul_out   : poly_t;
  SIGNAL as_a, as_b, as_r : poly_t;
  SIGNAL as_sub           : STD_LOGIC;
  
  -- message packing
  SIGNAL w_comp : poly_t;
  SIGNAL m_enc  : byte_array_t(KPKE_SEED_BYTES - 1 DOWNTO 0);

BEGIN

--Controller
  ctrl : ENTITY work.kpke_decrypt_ctrl
        PORT MAP (
            clk        => clk,
            start      => start,
            k          => k,
            k_latched  => k_op,
            op_start   => op_start,
            op_code    => op_code,
            poly_index => poly_index,
            op_done    => op_done,
            done       => done
        );

  --putting s_hat func over here because easy to read, debug or write
  -- s_hat[i] = ByteDecode_12(dk[384*i .. 384*i + 383])
  dk_select : PROCESS (dk, poly_index)
  BEGIN
    dk_sel <= dk(383 DOWNTO 0);
    FOR i IN 1 TO 3 LOOP
      IF poly_index = i THEN
        dk_sel <= dk(384*i + 383 DOWNTO 384*i);
      END IF;
    END LOOP;
  END PROCESS dk_select;
    
    dec_sk : ENTITY work.byte_decode GENERIC MAP (d => 12) PORT MAP (b => dk_sel, f => s_dec); -- we could have problem over here(in byte_decode, d 0 to 11) 

  --Slicing ciphertexts, with c1 and c2
  --   c1 = c[0 .. 32*du*k - 1], u[i] at offset 32*du*i
  --   c2 = c[32*du*k .. 32*(du*k + dv) - 1]

  c_select : PROCESS(ciphertext, poly_index, k_op)
  BEGIN
      c1_10 <= ciphertext(319 DOWNTO 0); -- du =10
      c1_11 <= ciphertext(351 DOWNTO 0); -- du =11
        FOR i IN 1 TO 3 LOOP
          IF poly_index = i THEN
            c1_10 <= ciphertext(320 * i + 319 DOWNTO 320 * i);
            c1_11 <= ciphertext(352 * i + 351 DOWNTO 352 * i);
          END IF ;
        END LOOP ;
        IF k_op = 3 THEN
          c2_4 <= ciphertext(1087 DOWNTO 960);    -- 32*10*3
        ELSE
          c2_4 <= ciphertext(767 DOWNTO 640);     -- 32*10*2
        END IF;
        c2_5 <= ciphertext(1567 DOWNTO 1408);     -- 32*11*4, only for k = 4
  END PROCESS c_select;
  -- byte_decode / sample_poly_cbd ports are currently 32*d+1 / 64*eta+1 bytes
  -- (one more than FIPS 203): K-PKE appends one zero byte to match them.
  

  dec_u10 : ENTITY work.byte_decode GENERIC MAP (d => 10) PORT MAP (b => c1_10, f => u_dec10);
  dec_u11 : ENTITY work.byte_decode GENERIC MAP (d => 11) PORT MAP (b => c1_11, f => u_dec11);
  dcp_u10 : ENTITY work.decompress  GENERIC MAP (d => 10) PORT MAP (y => u_dec10, decomp => u_10);
  dcp_u11 : ENTITY work.decompress  GENERIC MAP (d => 11) PORT MAP (y => u_dec11, decomp => u_11);

  dec_v4  : ENTITY work.byte_decode GENERIC MAP (d => 4)  PORT MAP (b => c2_4, f => v_dec4);
  dec_v5  : ENTITY work.byte_decode GENERIC MAP (d => 5)  PORT MAP (b => c2_5, f => v_dec5);
  dcp_v4  : ENTITY work.decompress  GENERIC MAP (d => 4)  PORT MAP (y => v_dec4, decomp => v_4);
  dcp_v5  : ENTITY work.decompress  GENERIC MAP (d => 5)  PORT MAP (y => v_dec5, decomp => v_5);

  -- Shared arithmetic
  ntt_in <= u(poly_index);
  mul_a  <= s_hat(poly_index);

  ntt_i  : ENTITY work.ntt           PORT MAP (f => ntt_in, fp => ntt_out);
  intt_i : ENTITY work.ntt_inv       PORT MAP (f => acc,    fp => intt_out);
  mul_i  : ENTITY work.multiply_ntts PORT MAP (f => mul_a, g => ntt_in, h => mul_out);

  -- MUL_ACC: acc + s_hat[i] x u_hat[i]      SUBTRACT_V: v - acc
  as_sub <= '1' WHEN op_code = DEC_OP_SUBTRACT_V ELSE '0';
  as_a   <= v   WHEN op_code = DEC_OP_SUBTRACT_V ELSE acc;
  as_b   <= acc WHEN op_code = DEC_OP_SUBTRACT_V ELSE mul_out;

  addsub : FOR n IN 0 TO MLKEM_N - 1 GENERATE              -- "+" and "-" from mlkem_types_pkg
      as_r(n) <= as_a(n) - as_b(n) WHEN as_sub = '1' ELSE
                 as_a(n) + as_b(n);
    END GENERATE addsub;
    
    -- m = ByteEncode_1(Compress_1(w)), w is held in acc
    cmp_m : ENTITY work.compress    GENERIC MAP (d => 1) PORT MAP (x => acc, comp => w_comp);
    enc_m : ENTITY work.byte_encode GENERIC MAP (d => 1) PORT MAP (f => w_comp, b => m_enc);

-- Datapath: executes one op per op_start, answers next cycle
    datapath : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            op_done <= '0';

            IF op_start = '1' THEN
                op_done <= '1';

                CASE op_code IS
                    WHEN DEC_OP_DECODE_SK =>
                        s_hat(poly_index) <= s_dec;

                    WHEN DEC_OP_DECODE_U =>
                        IF k_op = 4 THEN
                            u(poly_index) <= u_11;
                        ELSE
                            u(poly_index) <= u_10;
                        END IF;

                    WHEN DEC_OP_DECODE_V =>
                        IF k_op = 4 THEN
                            v <= v_5;
                        ELSE
                            v <= v_4;
                        END IF;

                    WHEN DEC_OP_CLEAR_ACC =>
                        acc <= POLY_ZERO;

                    WHEN DEC_OP_NTT_U =>
                        u(poly_index) <= ntt_out;

                    WHEN DEC_OP_MUL_ACC =>
                        acc <= as_r;

                    WHEN DEC_OP_INTT_ACC =>
                        acc <= intt_out;

                    WHEN DEC_OP_SUBTRACT_V =>
                        acc <= as_r;

                    WHEN DEC_OP_PACK_MSG =>
                        m_reg <= m_enc;

                    WHEN OTHERS =>
                        NULL;
                END CASE;
            END IF;
        END IF;
    END PROCESS datapath;

    m <= m_reg;
END rtl ; -- rtl