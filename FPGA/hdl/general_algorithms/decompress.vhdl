-- description: decompresses a d bit integer into 12 bits
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

-- GENERIC description
-- d:           Number of bits of input coefficients

-- PORT description
-- x:           Input polynomial (256 coefficients with 12 bits each, but only d bits
--              used (the LSBs))
-- comp:        Output polynomial, 12 bit (all bits used) 

ENTITY decompress IS 
    GENERIC (
        d       : IN NATURAL RANGE 1 TO 11
    );
    PORT (
        y       : IN  poly_t;
        decomp  : OUT poly_t
    );
END ENTITY decompress;

ARCHITECTURE behavioral OF decompress IS
    SUBTYPE extended_coeff_t IS STD_LOGIC_VECTOR(0 TO COEFF_WL+d);
BEGIN

    PROCESS(y)
        VARIABLE var_decomp : extended_coeff_t;
        VARIABLE var_round  : UNSIGNED(0 TO 23);
    BEGIN
        -- add 1/2 for rounding to nearest integer:
        -- + 1/2 = + shift_right(shift_left(1, d-1), d) 
        var_round := shift_left(to_unsigned(1, 2*COEFF_WL), d - 1);
        FOR coeff_index IN y'RANGE LOOP
            var_decomp := STD_LOGIC_VECTOR(shift_right(UNSIGNED(y(coeff_index)) * MLKEM_Q + var_round, d));  
            decomp(coeff_index) <= var_decomp(0 to 11); 
        END LOOP;

    END PROCESS;
    
END ARCHITECTURE behavioral;

