LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.mlkem_types_pkg.ALL;

ENTITY kpke_decrypt_ctrl IS
    PORT(
        clk   : IN STD_LOGIC;
        start : IN STD_LOGIC;
        k     : IN INTEGER RANGE 2 TO 4;

        ek : IN byte_array_t(31 DOWNTO 0);
        m  : IN byte_array_t(31 DOWNTO 0);
        r  : IN byte_array_t(31 DOWNTO 0);

        ciphertext : OUT byte_array_t(31 DOWNTO 0);

        done : OUT STD_LOGIC
    );
    END ENTITY;
