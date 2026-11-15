LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY WORK;
USE WORK.mlkem_types_pkg.ALL;

ENTITY jitter_measure IS
    GENERIC (
        stages: INTEGER := 25
    );
    PORT (
        clk: IN STD_LOGIC;
        bias: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        jitter: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        done: OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE behavioral OF jitter_measure IS
    SIGNAL jitter_counter: UNSIGNED(1 DOWNTO 0);
    SIGNAL prev_osc_out: STD_LOGIC;
    SIGNAL osc_out: STD_LOGIC;
BEGIN
    OSC: ENTITY WORK.ring_oscillator
    GENERIC MAP (
        stages => stages
    )
    PORT MAP (
        state => osc_out
    );
    
    PROCESS(clk) IS
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF osc_out AND (NOT prev_osc_out) THEN
                jitter <= STD_LOGIC_VECTOR(jitter_counter);
                jitter_counter <= UNSIGNED(bias);
                done <= '1';
            ELSE
                jitter_counter <= jitter_counter + 1;
                done <= '0';
            END IF;
            prev_osc_out <= osc_out;
        END IF;
    END PROCESS;
END ARCHITECTURE;