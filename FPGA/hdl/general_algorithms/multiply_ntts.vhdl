-- description: 
-- author:      Julia Müller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mlkem_types_pkg.all;

entity multiply_ntts is 
    port (
        f : in  poly_t;
        g : in  poly_t;
        h : out poly_t
    );
end entity multiply_ntts;