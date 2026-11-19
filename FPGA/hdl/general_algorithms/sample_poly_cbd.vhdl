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
    SIGNAL bit_array : STD_LOGIC_VECTOR(0 TO 8*64*eta-1);
BEGIN
    bit_array <= bytestobits(b);

    PROCESS(bit_array)
        VARIABLE x : NATURAL RANGE 0 TO eta;
        VARIABLE y : NATURAL RANGE 0 TO eta;
        VARIABLE diff : INTEGER RANGE -eta TO eta;
    BEGIN
        FOR coeff_index IN f'RANGE LOOP
            x := 0;
            y := 0;
            FOR j IN 0 TO eta LOOP
                IF bit_array(2*coeff_index*eta + j) = '1' THEN
                    x := x + 1;
                END IF;
                IF bit_array(2*coeff_index*eta + eta + j) = '1' THEN
                    y := y + 1;
                END IF;
            END LOOP;
            diff := x-y;

            f(coeff_index) <= STD_LOGIC_VECTOR(TO_SIGNED(diff, COEFF_WL)) when (diff > 0) else
                              STD_LOGIC_VECTOR(TO_SIGNED(diff + MLKEM_Q, COEFF_WL));
        END LOOP;
    END PROCESS;

END ARCHITECTURE behavioral;