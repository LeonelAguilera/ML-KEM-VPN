-- description: 
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

ENTITY byte_decode IS 
    GENERIC (
        d : NATURAL RANGE 0 TO 11
    );

    PORT (
        b : IN byte_array_t(0 TO 32*d);
        f : OUT  poly_t
    );
END ENTITY byte_decode;

ARCHITECTURE parallel OF byte_decode IS
BEGIN

END ARCHITECTURE parallel;