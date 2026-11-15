-- https://arxiv.org/pdf/2209.04423

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.mlkem_types_pkg.ALL;

ENTITY random_number_generator IS
    PORT (
        clk: IN STD_LOGIC;
        random_number: OUT byte_array_t(31 DOWNTO 0);
        done: OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE behavioral OF random_number_generator IS
    TYPE stages_t IS ARRAY(3 DOWNTO 0) OF INTEGER;
    TYPE jitter_t IS ARRAY(3 DOWNTO 0) OF STD_LOGIC_VECTOR(1 DOWNTO 0);

    SIGNAL seed: STD_LOGIC_VECTOR((32 * 8) - 1 DOWNTO 0);

    SIGNAL stage_counter: UNSIGNED(6 DOWNTO 0);
    SIGNAL jitter_counter: jitter_t;
    SIGNAL jitter_measure_done: STD_LOGIC_VECTOR(3 DOWNTO 0);

    COMPONENT jitter_measure IS
        GENERIC (
            stages: INTEGER
        );
        PORT (
            clk: IN STD_LOGIC;
            bias: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            jitter: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            done: OUT STD_LOGIC
        );
    END COMPONENT;

    CONSTANT oscillator_stages: stages_t := (179, 181, 191, 193);
BEGIN
    jitter_measurements: FOR i IN 3 DOWNTO 0 GENERATE
        measure_i: jitter_measure
            GENERIC MAP (
                stages => oscillator_stages(i)
            )
            PORT MAP (
                clk => clk,
                bias => jitter_counter((i + 1) MOD 4),
                jitter => jitter_counter(i),
                done => jitter_measure_done(i)
            );
    END GENERATE;

    PROCESS(clk, jitter_counter, jitter_measure_done) IS
        VARIABLE next_data: STD_LOGIC;
        VARIABLE rand_bits: STD_LOGIC_VECTOR(1 DOWNTO 0);
    BEGIN
        IF RISING_EDGE(clk) THEN
            next_data := '0';
            FOR i IN 3 DOWNTO 0 LOOP
                next_data := next_data OR jitter_measure_done(i);
                rand_bits := rand_bits XOR (jitter_counter(i) AND jitter_measure_done(i));
            END LOOP;
            IF next_data = '1' THEN
                seed(seed'HIGH DOWNTO 2) <= seed(seed'HIGH - 2 DOWNTO 0);
                seed(1 DOWNTO 0) <= rand_bits;
                stage_counter <= stage_counter + 1;
            END IF;
        END IF;
    END PROCESS;

    out_split: FOR i IN 31 DOWNTO 0 GENERATE
        random_number(i) <= seed(((i + 1) * 8) - 1 DOWNTO i * 8);
    END GENERATE;
    done <= '1' WHEN stage_counter = 0 ELSE
            '0';

END ARCHITECTURE;
