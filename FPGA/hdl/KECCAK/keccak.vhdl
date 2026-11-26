-- description: The keccak unit implements the functions H, G, XOF, J and PRF, which are
--              based on SHA3-256, SHA3-512, SHAKE128 and SHAKE256. 
--              Because those use the same underlying keccak algorithms with different
--              input and output sizes as well as rates, this unit is called keccak.
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;
USE work.keccak_types_pkg.ALL;

-- GENERIC description
-- data_in_size:    Defines size of input data package (meaning number of parallel bytes)
-- data_out_size:   Defines size of output data package (meaning number of parallel bytes)


-- PORT description
-- clk:         Wow, look at this! A clock!
-- reset:       used to reset internal permutation state
--              active high reset
--              -> for H, G, J, PRF: reset at start of each "function call"
--              -> for XOF: reset only when new context is used
-- mode:        selects the SHA3 function that is used, defined in keccak_types_pkg
-- data_in:     input_data -> data_in_size bytes
-- in_len:      length of valid bytes of current input = index of first invalid byte
--              (valid bytes are expected at LSB end)
-- absorb:      set high to indicate that data_in is ready (next_in being high indicates that 
--              entity is ready for next input)
-- squeeze:     set high to indicate that data_out should be given
--              (wait for out_ready to read data_out)
-- data_out:    hashed output data, all data_out_size bytes are valid always
--              The data_out array is filled starting from data_out(0)(0) upwards (kinda LSB ordering)
--              (only throw them away when you know what you're doing)
-- next_in:     stays high as long as the unit is ready to read new input data and 
--              previous command was absorb or after reset
-- out_ready:   stays high as long as the current output is ready and unchanged and
--              previous command was squeeze
-- busy:        busy-flag in case FSM is used 

ENTITY keccak IS 
    GENERIC (
        data_in_size    : NATURAL;
        data_out_size   : NATURAL
    );
    PORT (
        clk         : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC;
        mode        : IN  keccac_mode_t;
        data_in     : IN  byte_array_t (data_in_size-1 DOWNTO 0);
        in_len      : IN  NATURAL RANGE 1 TO data_in_size;
        absorb      : IN  STD_LOGIC;
        squeeze     : IN  STD_LOGIC;
        data_out    : OUT byte_array_t (data_out_size-1 DOWNTO 0);
        next_in     : OUT STD_LOGIC;
        out_ready   : OUT STD_LOGIC;
        busy        : OUT STD_LOGIC
    );
END ENTITY keccak;

ARCHITECTURE dummy OF keccak IS 
    CONSTANT dummy_out : byte_array_t(8 DOWNTO 0) := ("11111111","00000000","11111110","00000011","11110000","00111110","00001111","00001110","00110010");
BEGIN
    busy <= '0';

    -- -------------------------------------
    -- ABSORB PROCESS
    -- -------------------------------------
    PROCESS(clk)
        VARIABLE absorb_count : INTEGER;
    BEGIN 
        IF RISING_EDGE(clk) THEN
            IF reset = '1' THEN
                absorb_count := 0;
                next_in <= '0';
            ELSE 
                next_in <= '1';
                IF absorb_count < 5 THEN
                    absorb_count := absorb_count + 1;
                ELSIF absorb_count < 8 THEN
                    next_in <= '0';
                    absorb_count := absorb_count + 1;
                ELSE 
                    absorb_count := 0;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- -------------------------------------
    -- SQUEEZE PROCESS
    -- -------------------------------------
    PROCESS(clk)
        VARIABLE output_count : INTEGER;
        VARIABLE squeeze_count : INTEGER;
        VARIABLE index_count : INTEGER;
        VARIABLE continue : STD_LOGIC;
    BEGIN 
        IF RISING_EDGE(clk) THEN
            IF reset = '1' THEN
                squeeze_count := 0;
                out_ready <= '0';
                index_count := 0;
                output_count := 0;
                continue := '0';
            ELSE 
                out_ready <= '0';
                IF squeeze = '1' THEN
                    IF continue = '0' THEN 
                        IF squeeze_count < 2 THEN 
                            squeeze_count := squeeze_count + 1;
                        ELSE 
                            continue := '1';
                        END IF;
                    ELSE
                        FOR index IN index_count TO data_out_size-1 LOOP
                            IF output_count < 9 AND continue = '1' THEN
                                data_out(index) <= dummy_out(output_count);
                                output_count := output_count + 1;
                                index_count := index_count + 1;
                            ELSE 
                                output_count := 0;
                                squeeze_count := 0;
                                continue := '0';
                            END IF;
                        END LOOP;
                        IF index_count = data_out_size THEN
                            out_ready <= '1';
                            index_count := 0;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE dummy;


ARCHITECTURE behavioral OF keccak IS 
    -- SIGNAL capacity : NATURAL;
    -- SIGNAL keccak_buffer, perm_out : keccak_string_t;
    -- SIGNAL round_index : NATURAL RANGE 0 TO KECCAK_N_R-1;
BEGIN
    busy <= '1';
    -- -------------------------------------
    -- SUB ENTITY DEFINITION
    -- -------------------------------------
    -- perm : ENTITY work.permutation
    --     PORT MAP(
    --         a_in        => keccak_buffer,
    --         round_index => round_index,
    --         a_out       => perm_out
    --     );
    
    -- -------------------------------------
    -- MAIN PROCESS
    -- -------------------------------------
    -- PROCESS(clk)
    -- BEGIN 
    --     IF RISING_EDGE(clk) THEN
    --         IF reset = '1' THEN
    --         ELSE
    --             CASE state IS 
    --                 WHEN FULL_PERM => ------------------------------
    --                     round_index <= round_index + 1;
    --                     keccak_buffer <= perm_out;
    --                     IF round_index >= KECCAK_N_R THEN -- full permutation done
    --                         state <= READY;
    --                     END IF;
    --                 WHEN READY => ----------------------------------

    --                 WHEN IDLE => ----------------------------------- 
    --                 WHEN OTHERS => --------------------------------- 
    --             END CASE;
    --         END IF;
    --     END IF;
    -- END PROCESS;

END ARCHITECTURE behavioral;