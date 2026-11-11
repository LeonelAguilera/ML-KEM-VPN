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
