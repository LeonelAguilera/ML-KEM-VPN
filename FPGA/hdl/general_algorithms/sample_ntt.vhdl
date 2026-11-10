-- description: 
-- author:      Julia Müller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mlkem_types_pkg.all;

entity sample_ntt is 
    port (
        b : in  byte_array_t(0 to 33);
        a : out poly_t
    );
end entity sample_ntt;