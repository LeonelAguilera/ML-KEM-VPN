-- description: decompresses a d bit integer into 12 bits
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

ENTITY decompress IS 
    GENERIC (
        d       : IN NATURAL RANGE 0 TO 11
    );
    PORT (
        y       : IN  poly_t;
        decomp  : OUT poly_t
    );
END ENTITY decompress;

ARCHITECTURE basic OF decompress IS
    -- signal decomp_temp : unsigned(0 to 23);
begin
    -- rounding to nearest integer:
    -- add 1 shifted left with d-1 before shifting all to right by d
    -- decomp_temp <= shift_right(y * MLKEM_Q + shift_left(to_unsigned(1, 24), d - 1), d);
    -- decomp <= decomp_temp(0 to 11);
END ARCHITECTURE basic;
