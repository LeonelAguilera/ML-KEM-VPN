-- description: 
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

ENTITY byte_encode IS 
    GENERIC (
        d : NATURAL RANGE 0 TO 11
    );

    PORT (
        f : IN  poly_t;
        b : OUT byte_array_t(0 TO 32*d)
    );
END ENTITY byte_encode;

ARCHITECTURE parallel OF byte_encode IS
BEGIN
    -- process(all) is
    -- begin
    --     for index in 0 to 
    -- END process;
END ARCHITECTURE parallel;