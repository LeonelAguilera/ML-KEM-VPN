-- description: 
-- author:      Julia Müller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mlkem_types_pkg.all;

entity byte_decode is 
    generic (
        D : unsigned range 0 to 11
    );

    port (
        b : in  byte_array_t(0 to 32*D);
        f : out poly_t
    );
end entity byte_decode;