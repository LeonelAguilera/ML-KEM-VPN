library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mlkem_types_pkg.all;

entity kpke_keygen is
    port(
        clk   : in std_logic;
        start : in std_logic;
        k     : in integer range 2 to 4;

        d : in byte_array_t(31 downto 0);
        
        ek  : out byte_array_t(31 downto 0);
        dk  : out byte_array_t(31 downto 0);

        done : out std_logic
    );
    end entity kpke_keygen;