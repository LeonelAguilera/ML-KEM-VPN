library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity kpke_keygen is
    port(
        clk   : in std_logic;
        start : in std_logic;
        k     : in integer Range 2 To 4;

        d : in byte_array_t(31 Downto 0);
        
        ek  : in byte_array_t(31 Downto 0);
        dk  : in byte_array_t(31 Downto 0);

        done : out std_logic
    );
    end entity kpke_keygen;