-- https://arxiv.org/pdf/2209.04423

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY random_number_generator IS
    PORT (
        clk: IN STD_LOGIC;
        random_number: OUT byte_array_t(31 DOWNTO 0);
        done: OUT STD_LOGIC;
    );
END ENTITY;

ARCHITECTURE behavioral OF random_number_generator IS
    SIGNAL seed: STD_LOGIC_VECTOR((32 * 8) - 1 DOWNTO 0);
    SIGNAL ring_output: STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL ring_prev_output: STD_LOGIC_VECTOR(3 DOWNTO 0);

    SIGNAL stage_counter: UNSIGNED(6 DOWNTO 0);
    SIGNAL jitter_counter: ARRAY (3 DOWNTO 0) OF UNSIGNED(1 DOWNTO 0);


    COMPONENT ring_oscillator
        GENERIC (
            stages: INTEGER := 5
        );
        PORT (
            state: OUTPUT STD_LOGIC
        );
    END COMPONENT;

    CONSTANT oscillator_stages: ARRAY(3 DOWNTO 0) OF INTEGER := (5, 7, 11, 13);
BEGIN
    oscillators: FOR i IN 3 DOWNTO 0 GENERATE
        ring_i: ring_oscillator
            GENERIC MAP (
                stages => oscillator_stages(i);
            )
            PORT MAP (
                state => ring_output(i);
            );
    END GENERATE;

    PROCESS(clk, ring_output) IS
    BEGIN
        IF RISING_EDGE(clk) THEN
            FOR i IN 3 DOWNTO 0 LOOP
                IF (ring_output(i) = '1') AND (ring_prev_output(i) = '0') THEN
                    FOR j IN seed'HIGH DOWNTO 2 LOOP
                        seed(j) <= seed(j - 2);
                    END LOOP;
                    
                    seed(1 DOWNTO 0) <= STD_LOGIC_VECTOR(jitter_counter(i));

                    jitter_counter(i) <= 0;
                    stage_counter <= stage_counter + 1;
                ELSE
                    jitter_counter(i) <= jitter_counter(i) + 1;
                END IF;

                ring_prev_output(i) <= ring_output(i);
            END LOOP;
        END IF;
    END PROCESS;

    out_split: FOR i IN 31 DOWNTO 0 GENERATE
        random_number(i) <= seed(((i + 1) * 8) - 1 DOWNTO i * 8);
    END GENERATE;
    done <= '1' WHEN stage_counter = 0 ELSE
            '0';
END ARCHITECTURE;
