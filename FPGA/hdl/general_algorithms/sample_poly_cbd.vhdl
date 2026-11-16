-- description: Takes a seed as input and outputs a pseudorandom sample from 
--              the distribution D𝜂(𝑅𝑞)
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

-- GENERIC description
-- eta:         Changes "noise" of sampled values


-- PORT description
-- b:           Input byte array 
-- f:           Output polynomial

ENTITY sample_poly_cbd IS 
    GENERIC (
        eta : NATURAL RANGE 2 TO 3
    );
    
    PORT (
        b : IN  byte_array_t(0 TO 64*eta);
        f : OUT poly_t
    );
END ENTITY sample_poly_cbd;

ARCHITECTURE behavioral OF sample_poly_cbd IS
    SIGNAL bit_array : STD_LOGIC_VECTOR(0 TO 8*64*eta);
BEGIN
    bit_array <= bytestobits(b);

    PROCESS
        VARIABLE x : NATURAL RANGE 0 TO eta;
        VARIABLE y : NATURAL RANGE 0 TO eta;
        VARIABLE diff : INTEGER RANGE -eta TO eta;
    BEGIN
        FOR coeff_index IN f'RANGE LOOP
            x := 0;
            y := 0;
            FOR j IN 0 TO eta LOOP
                x := x + bit_array(2*coeff_index*eta + j);
                y := y + bit_array(2*coeff_index*eta + eta + j);
            END LOOP;
            diff := x-y;

            f(coeff_index) <= diff when (diff > 0) else
                              diff + MLKEM_Q;
        END LOOP;
    END PROCESS;

END ARCHITECTURE behavioral;