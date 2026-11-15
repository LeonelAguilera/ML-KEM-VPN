-- description: compresses a 12 bit integer into d bits where d < 12
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

ENTITY compress IS 
    GENERIC (
        d       : IN NATURAL RANGE 0 TO 11
    );
    PORT (
        x       : IN  poly_t;
        comp    : OUT poly_t
    );
END ENTITY compress;

ARCHITECTURE basic OF compress IS
    SIGNAL resize_x : UNSIGNED(0 TO 23);
    SIGNAL var_comp : UNSIGNED(0 TO 23);
BEGIN
    resize_x <= (11 DOWNTO 0 => '0') & x; -- expand x for shift
    -- + 1664 to round to nearest integer (+ 1/2 = + 1664/3329)
    var_comp <= (shift_left(resize_x, d) + 1664)/MLKEM_Q;  
    comp <= (comp'length-1 DOWNTO d => '0') & var_comp(d-1 DOWNTO 0);
END ARCHITECTURE basic;