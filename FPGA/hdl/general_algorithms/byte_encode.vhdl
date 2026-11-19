-- description: 
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

-- GENERIC description
-- d:           Number of valid/used bits in input polynomial


-- PORT description
-- f:           Input polynomial
-- b:           Output bit array with LSB ordering (index 0 will contain LSB of f(0))

ENTITY byte_encode IS 
    GENERIC (
        d : NATURAL RANGE 1 TO 12
    );

    PORT (
        f : IN  poly_t;
        b : OUT byte_array_t(0 TO 32*d-1)
    );
END ENTITY byte_encode;

ARCHITECTURE parallel OF byte_encode IS
    SIGNAL bit_array : STD_LOGIC_VECTOR(0 TO 32*d*8-1);
BEGIN
    PROCESS(f)
    BEGIN
        FOR coeff_index IN f'RANGE LOOP
            bit_array(coeff_index*d TO (coeff_index+1)*d-1) <= f(coeff_index)(0 TO d-1);
        END LOOP;
    END PROCESS;
    b <= bitstobytes(bit_array);

END ARCHITECTURE parallel;