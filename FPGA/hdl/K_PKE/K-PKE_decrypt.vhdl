Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;

ENTITY kpke_decrypt IS
  port (
    clk : In std_logic;
    start : In std_logic;
    k : in  integer Range 2 to 4;

    dk : In byte_array_t(31 Downto 0);
    ciphertext : In byte_array_t(31 Downto 0);

    m : Out byte_array_t(31 Downto 0);
    done : Out std_logic
  ) ;
End kpke_decrypt;