-- description: 
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

ENTITY sample_poly_cbd IS 
    GENERIC (
        eta : NATURAL RANGE 2 TO 3
    );
    
    PORT (
        b : IN  byte_array_t(0 to 64*eta);
        f : OUT poly_t
    );
END ENTITY sample_poly_cbd;

ARCHITECTURE parallel OF sample_poly_cbd IS
    -- signal bit_array : std_logic_vector(0 to 8*64*eta);
BEGIN
    -- bit_array <= bytestobits(b, 64*eta);
END ARCHITECTURE parallel;