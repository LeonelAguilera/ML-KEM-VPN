LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ring_oscillator IS
    GENERIC (
        stages: INTEGER := 5
    );
    PORT (
        state: OUT STD_LOGIC;
    );
END ENTITY;

ARCHITECTURE behavioral OF ring_oscillator IS
    SIGNAL ring: STD_LOGIC_VECTOR(stages - 1 DOWNTO 0);
BEGIN
    PROCESS (ring) IS
    BEGIN
        ring(0) <= NOT ring (stages - 1) AFTER 0.5 ns;
        FOR i IN 1 TO stages - 1 LOOP
            ring(i) <= NOT ring(i - 1) AFTER 0.5 ns;
        END LOOP;
    END PROCESS;
    
    state <= ring(0);
END ARCHITECTURE;
