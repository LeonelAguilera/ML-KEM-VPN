-- description: 
-- author:      Julia Müller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mlkem_types_pkg.all;

entity base_case_multiply is 
    port (
        a0    : in  coeff_t;
        a1    : in  coeff_t;
        b0    : in  coeff_t;
        b1    : in  coeff_t;
        gamma : in  coeff_t;
        c0    : out coeff_t;
        c1    : out coeff_t
    );
end entity base_case_multiply;