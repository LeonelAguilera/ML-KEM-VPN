-- description: compresses a 12 bit integer into d bits where d < 12
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

-- GENERIC description
-- d:           Number of bits of output coefficients

-- PORT description
-- x:           Input polynomial (256 coefficients with 12 bits each)
-- comp:        Output polynomial, still 12 bit wide vars but only d bits used (the LSBs)

ENTITY compress IS 
    GENERIC (
        d       : IN NATURAL RANGE 1 TO 11
    );
    PORT (
        x       : IN  poly_t;
        comp    : OUT poly_t
    );
END ENTITY compress;

ARCHITECTURE behavioral OF compress IS
    SUBTYPE extended_coeff_t IS UNSIGNED(0 TO 12+d);
    TYPE extended_poly_t IS ARRAY (0 TO MLKEM_N - 1) OF extended_coeff_t;
BEGIN

    PROCESS(x)
        VARIABLE resize_x : extended_coeff_t;
        VARIABLE var_compressed : extended_poly_t;
    BEGIN
        FOR coeff_index IN x'RANGE LOOP
            -- expand x for shift to keep MSBs
            resize_x := (d DOWNTO 0 => '0') & x;
            -- + 1664 to round to nearest integer 
            var_compressed := (shift_left(resize_x, d) + 1664)/MLKEM_Q;  
            comp(coeff_index) <= (comp'length-1 DOWNTO d => '0') & var_compressed(d-1 DOWNTO 0);
        END LOOP;
    END PROCESS;
         
END ARCHITECTURE behavioral;