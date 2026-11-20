Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;
Use work.mlkem_types_pkg.all;

ENTITY kpke_decrypt IS
  PORT (
    clk : IN STD_LOGIC;
    start : IN STD_LOGIC;
    k : IN  INTEGER RANGE 2 TO 4;

    dk : IN byte_array_t(31 DOWNTO 0);
    ciphertext : IN byte_array_t(31 DOWNTO 0);

    m : OUT byte_array_t(31 DOWNTO 0);
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
  SIGNAL m_reg : byte_array_t(0 TO KPKE_SEED_BYTES - 1) := (OTHERS => (OTHERS => '0'));


  --dk slice for s_hat[poly_index]
  SIGNAL dk_sel : byte_array_t(0 TO 32*12 - 1);
  SIGNAL s_dec  : poly_t;

    -- ciphertext slices: c1 part for u[poly_index], c2 part for v
  SIGNAL c1_10 : byte_array_t(0 TO 32*10 - 1);
  SIGNAL c1_11 : byte_array_t(0 TO 32*11 - 1);
  SIGNAL c2_4  : byte_array_t(0 TO 32*4 - 1);
  SIGNAL c2_5  : byte_array_t(0 TO 32*5 - 1);
  SIGNAL c1_10_p : byte_array_t(0 TO 32*10);         -- + one zero byte, see below
  SIGNAL c1_11_p : byte_array_t(0 TO 32*11);
  SIGNAL c2_4_p  : byte_array_t(0 TO 32*4);
  SIGNAL c2_5_p  : byte_array_t(0 TO 32*5);  

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
    dk_sel <= dk(0 to 383);
    FOR i IN 1 TO 3 LOOP
      IF poly_index = i THEN
        dk_sel = (384*i TO 384*i+383);
      END IF;
    END LOOP;
    
    dec_sk : ENTITY work.byte_decode GENERIC MAP (d => 12) PORT MAP (b => dk_sel, f => s_dec); -- we could have problem over here(in byte_decode, d 0 to 11) 

  --Slicing ciphertexts, with c1 and c2
  --   c1 = c[0 .. 32*du*k - 1], u[i] at offset 32*du*i
  --   c2 = c[32*du*k .. 32*(du*k + dv) - 1]

  c_select : PROCESS(ciphertext, poly_index, k_op)
  BEGIN
      c1_10 <= ciphertext(0 TO 319); -- du =10
      c1_11 <= ciphertext(0 TO 351); -- du =11
        FOR i IN 1 TO 3 LOOP
          IF poly_index = i THEN
            c1_10 <= ciphertext(320 * i TO 320 * i + 319);
            c1_11 <= ciphertext(352 * i TO 352 * i + 351);
          END IF ;  
        END LOOP ; 
        IF k_op = 3 THEN
          c2_4 <= ciphertext(960 TO 1087);    -- 32*10*3
        ELSE
          c2_4 <= ciphertext(640 TO 767);     -- 32*10*2
        END IF;
        c2_5 <= ciphertext(1408 TO 1567);       -- 32*11*4, only for k = 4
  END PROCESS c_select;
  -- byte_decode / sample_poly_cbd ports are currently 32*d+1 / 64*eta+1 bytes
  -- (one more than FIPS 203): K-PKE appends one zero byte to match them.
  c1_10_p <= c1_10 & BYTE_ZERO;
  c1_11_p <= c1_11 & BYTE_ZERO;
  c2_4_p  <= c2_4  & BYTE_ZERO;
  c2_5_p  <= c2_5  & BYTE_ZERO;

  dec_u10 : ENTITY work.byte_decode GENERIC MAP (d => 10) PORT MAP (b => c1_10_p, f => u_dec10);
  dec_u11 : ENTITY work.byte_decode GENERIC MAP (d => 11) PORT MAP (b => c1_11_p, f => u_dec11);
  dcp_u10 : ENTITY work.decompress  GENERIC MAP (d => 10) PORT MAP (y => u_dec10, decomp => u_10);
  dcp_u11 : ENTITY work.decompress  GENERIC MAP (d => 11) PORT MAP (y => u_dec11, decomp => u_11);

  dec_v4  : ENTITY work.byte_decode GENERIC MAP (d => 4)  PORT MAP (b => c2_4_p, f => v_dec4);
  dec_v5  : ENTITY work.byte_decode GENERIC MAP (d => 5)  PORT MAP (b => c2_5_p, f => v_dec5);
  dcp_v4  : ENTITY work.decompress  GENERIC MAP (d => 4)  PORT MAP (y => v_dec4, decomp => v_4);
  dcp_v5  : ENTITY work.decompress  GENERIC MAP (d => 5)  PORT MAP (y => v_dec5, decomp => v_5);

    -- Shared arithmetic
    ntt_in <= u(poly_index);
    mul_a  <= s_hat(poly_index);

    ntt_i  : ENTITY work.ntt           PORT MAP (f => ntt_in, fp => ntt_out);
    intt_i : ENTITY work.ntt_inv       PORT MAP (f => acc,    fp => intt_out);
    mul_i  : ENTITY work.multiply_ntts PORT MAP (f => mul_a, g => ntt_in, h => mul_out);

END rtl ; -- rtl