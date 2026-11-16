-- description: decodes a byte-array into a polynomial
--              LSB ordering!
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

-- GENERIC description
-- d:           Number of valid/used bits in input polynomial


-- PORT description
-- b:           Input bit array 
-- f:           Output polynomial with LSB logic (f(0) has b(0) as LSB)

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

    PROCESS
    BEGIN
        FOR coeff_index IN f'RANGE LOOP
            f(coeff_index) <= ((0 TO d-1) => b(coeff_index*d TO (coeff_index+1)*d-1), OTHERS => '0');
        END LOOP;
    END PROCESS;

END ARCHITECTURE parallel;