-- description: decompresses a d bit integer into 12 bits
-- author:      Julia Müller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mlkem_types_pkg.all;

entity decompress is 
    port (
        y       : in coeff_t;
        d       : in unsigned range 0 to 11;
        decomp  : out coeff_t
    );
end entity decompress;

architecture basic of decompress is 
    signal decomp_temp : unsigned(0 to 23);
begin
    -- rounding to nearest integer:
    -- add 1 shifted left with d-1 before shifting all to right by d
    decomp_temp <= shift_right(y * MLKEM_Q + shift_left(to_unsigned(1, 24), d - 1), d);
    decomp <= decomp_temp(0 to 11);
end architecture basic;
