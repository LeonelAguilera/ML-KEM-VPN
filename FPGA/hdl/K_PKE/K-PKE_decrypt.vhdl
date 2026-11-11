library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mlkem_types_pkg.all;


entity kpke_decrypt is
  port (
    clk : in std_logic;
    start : in std_logic;
    k : in integer range 2 to 4;

    dk : in byte_array_t(31 downto 0);
    ciphertext : in byte_array_t(31 downto 0);

    m : out byte_array_t(31 downto 0);
    done : out std_logic;
  ) ;
end kpke_decrypt;