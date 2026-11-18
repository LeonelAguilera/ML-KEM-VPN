-- description: Takes a 32-byte seed and two indices to output a pseudorandom element of T_q
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;
USE work.keccak_types_pkg.ALL;

-- PORT description
-- clk:         Wow, look at this! A clock!
-- reset:       active high, used to reset internal FSM state to IDLE, no matter what current state is -> there it is ready to be used
-- start:       apply input b, then set to high to start the generation of a polynomial 
--              (no matter if signal goes low after, if it is still high wenn generation is done and state goes to idle it will start a new generation immediately)
-- b:           input byte array with seed (wait for busy before changing b)
-- a:           the coefficients of the NTT of a polynomial
-- busy:        goes high after b is internally buffered -> b needs to be stable until then
-- done:        goes high when a can be read (stays high in IDLE except when reset or start is applied)

ENTITY sample_ntt IS 
    PORT (
        clk     : IN  STD_LOGIC;
        reset   : IN  STD_LOGIC;
        start   : IN  STD_LOGIC;
        b       : IN  byte_array_t(0 TO 33);
        a       : OUT poly_t;
        busy    : OUT STD_LOGIC;
        done    : OUT STD_LOGIC
    );
END ENTITY sample_ntt;

ARCHITECTURE behavioral OF sample_ntt is
    TYPE sample_ntt_state_t IS (IDLE, WAIT_FOR_XOF, ABSORB, SQUEEZE, GENERATE_COEFFS, STORE_COEFFS);

    CONSTANT xof_data_in_size_c : NATURAL := 4; -- four bytes
    CONSTANT xof_data_out_size_c : NATURAL := 3; -- three bytes
    CONSTANT xof_in_bytes_total_c : NATURAL := 34;

    -- internal registers
    SIGNAL state : sample_ntt_state_t;
    SIGNAL input_buffer_b : byte_array_t(0 TO 33);
    SIGNAL absorb_byte_cnt : NATURAL RANGE 0 TO xof_in_bytes_total_c;
    SIGNAL buffer_c : byte_array_t(0 TO xof_data_out_size_c-1);
    SIGNAL d1 : coeff_t;
    SIGNAL d2 : coeff_t;
    SIGNAL coeff_cnt : NATURAL RANGE 0 TO 255;

    -- signals connecting to keccak unit
    SIGNAL xof_reset : STD_LOGIC;
    SIGNAL xof_data_in : byte_array_t(0 TO xof_data_in_size_c-1);
    SIGNAL xof_in_len : NATURAL RANGE 1 TO xof_data_in_size_c;
    SIGNAL xof_absorb : STD_LOGIC;
    SIGNAL xof_next_in : STD_LOGIC;
    SIGNAL xof_data_out : byte_array_t(0 TO xof_data_out_size_c-1);
    SIGNAL xof_squeeze : STD_LOGIC;
    SIGNAL xof_out_ready : STD_LOGIC;
    SIGNAL xof_busy : STD_LOGIC;

BEGIN 

    -- -------------------------------------
    -- SUB ENTITY DEFINITION
    -- -------------------------------------
    XOF : ENTITY work.keccak
        GENERIC MAP(
            data_in_size => xof_data_in_size_c,
            data_out_size => xof_data_out_size_c
        )
        PORT MAP(
            clk         => clk,
            reset       => xof_reset,
            mode        => mode_xof,
            data_in     => xof_data_in,
            in_len      => xof_in_len,
            absorb      => xof_absorb,
            squeeze     => xof_squeeze,
            data_out    => xof_data_out,
            next_in     => xof_next_in,
            out_ready   => xof_out_ready,
            busy        => xof_busy
        );
    
    -- -------------------------------------
    -- MAIN PROCESS
    -- -------------------------------------
    PROCESS(clk)
        VARIABLE var_absorb_byte_cnt : NATURAL RANGE 0 TO xof_in_bytes_total_c;
        VARIABLE j : NATURAL RANGE 0 TO 2;
    BEGIN 
        IF RISING_EDGE(clk) THEN
            IF reset = '1' THEN
                state <= IDLE;
                done <= '0';
            ELSE
                xof_reset <= '0';
                CASE state IS 
                    WHEN IDLE => -----------------------------------
                        busy <= '0';
                        IF start = '1' THEN
                            state <= WAIT_FOR_XOF;
                            input_buffer_b <= b;
                            busy <= '1';
                            done <= '0';
                            absorb_byte_cnt <= 0;
                            xof_in_len <= xof_data_in_size_c;
                            xof_absorb <= '0';
                        END IF;
                    WHEN WAIT_FOR_XOF => ---------------------------
                        IF xof_busy = '0' THEN
                            xof_reset <= '1';
                            state <= ABSORB;
                        END IF;
                    WHEN ABSORB => ---------------------------------
                        IF xof_absorb = '1' AND xof_next_in = '1' THEN 
                            -- handshake accepted, update counters and check if absorb finished
                            xof_absorb <= '0';
                            var_absorb_byte_cnt := absorb_byte_cnt + xof_in_len;
                            absorb_byte_cnt <= var_absorb_byte_cnt;
                            xof_in_len <=   xof_data_in_size_c 
                                            WHEN xof_in_bytes_total_c - var_absorb_byte_cnt > xof_data_in_size_c 
                                            ELSE xof_in_bytes_total_c - var_absorb_byte_cnt; 
                            IF var_absorb_byte_cnt = xof_in_bytes_total_c THEN
                                state <= SQUEEZE;
                            END IF;
                        ELSE
                            -- apply next input data
                            xof_data_in <= (OTHERS => (OTHERS => '0'));
                            FOR i IN 0 TO xof_in_len-1 LOOP
                                xof_data_in(i) <= input_buffer_b(absorb_byte_cnt+i);
                            END LOOP;
                            xof_absorb <= '1';
                        END IF;
                    WHEN SQUEEZE =>---------------------------------
                        IF xof_squeeze = '1' AND xof_out_ready = '1' THEN 
                            xof_squeeze <= '0';
                            buffer_c <= xof_data_out;
                            state <= GENERATE_COEFFS;
                        END IF;                        
                    WHEN GENERATE_COEFFS =>-------------------------
                        d1 <= buffer_c(1)(0 TO 3) & buffer_c(0);
                        d2 <= buffer_c(2) & buffer_c(1)(4 TO 7);
                        state <= STORE_COEFFS;
                    WHEN STORE_COEFFS =>----------------------------
                        j := 0;
                        IF UNSIGNED(d1) < MLKEM_Q THEN
                            a(coeff_cnt) <= d1;
                            j := j + 1;
                        END IF;
                        IF UNSIGNED(d2) < MLKEM_Q AND coeff_cnt + j < 256  THEN
                            a(coeff_cnt+j) <= d2;
                            j := j + 1;
                        END IF;
                        coeff_cnt <= coeff_cnt + j;
                        -- Check if finished, if not squeeze more
                        IF coeff_cnt + j = 256 THEN
                            done <= '1';
                            state <= IDLE;
                        ELSE 
                            state <= SQUEEZE;
                            xof_squeeze <= '1';
                        END IF;
                    WHEN OTHERS => ---------------------------------
                        state <= IDLE;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE behavioral;