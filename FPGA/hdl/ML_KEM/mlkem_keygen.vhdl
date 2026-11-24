LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mlkem_keygen IS
    PORT (
        clk: IN STD_LOGIC;
        start: IN STD_LOGIC;
        k: IN INTEGER RANGE 2 TO 4;
        ek: OUT byte_array_t(31 DOWNTO 0);
        dk: OUT byte_array_t(31 DOWNTO 0);
        done: OUT STD_LOGIC;
    );
END ENTITY;

ARCHITECTURE behavioral OF mlkem_keygen IS
BEGIN
END ARCHITECTURE;
