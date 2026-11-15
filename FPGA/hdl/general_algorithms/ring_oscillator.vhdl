LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ring_oscillator IS
    GENERIC (
        stages: INTEGER := 25
    );
    PORT (
        state: OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE behavioral OF ring_oscillator IS
    SIGNAL ring: STD_LOGIC_VECTOR(stages - 1 DOWNTO 0);

    ATTRIBUTE syn_keep : integer;
    ATTRIBUTE syn_keep of ring : signal is 1;
BEGIN
    ring(0) <= NOT ring (stages - 1);
    ring_stages: FOR i IN 1 TO stages - 1 GENERATE
        ring(i) <= NOT ring(i - 1);
    END GENERATE;
    
    state <= ring(0);
END ARCHITECTURE;
