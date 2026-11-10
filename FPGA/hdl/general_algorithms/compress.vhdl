-- description: compresses a 12 bit integer into d bits where d < 12
-- author:      Julia Müller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mlkem_types_pkg.all;

entity compress is 
    port (
        x       : in coeff_t;
        d       : in unsigned range 0 to 11; 
        comp    : out coeff_t
    );
end entity compress;

architecture basic of compress is
    signal resize_x : unsigned(0 to 23);
    signal var_comp : unsigned(0 to 23);
begin
    resize_x <= (11 downto 0 => '0') & x; -- expand x for shift
    -- + 1664 to round to nearest integer (+ 1/2 = + 1664/3329)
    var_comp <= (shift_left(resize_x, d) + 1664)/MLKEM_Q;  
    comp <= (comp'length-1 downto d => '0') & var_comp(d-1 downto 0);
end architecture basic;