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
-- b:           Output bit array (index 0 will contain LSB of f(0))

ENTITY byte_encode IS 
    GENERIC (
        d : NATURAL RANGE 1 TO 12
    );

    PORT (
        f : IN  poly_t;
        b : OUT byte_array_t(32*d-1 DOWNTO 0)
    );
END ENTITY byte_encode;

ARCHITECTURE parallel OF byte_encode IS
    SIGNAL bit_array : STD_LOGIC_VECTOR(32*d*8-1 DOWNTO 0);
BEGIN
    PROCESS(f)
    BEGIN
        FOR coeff_index IN f'RANGE LOOP
            bit_array((coeff_index+1)*d-1 DOWNTO coeff_index*d) <= f(coeff_index)(d-1 DOWNTO 0);
        END LOOP;
    END PROCESS;
    b <= bitstobytes(bit_array);

END ARCHITECTURE parallel;