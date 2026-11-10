-- description: 
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;

ENTITY sample_ntt IS 
    PORT (
        clk     : IN  STD_LOGIC;
        start   : IN  STD_LOGIC;
        b       : IN  byte_array_t(0 TO 33);
        a       : OUT poly_t;
        done    : OUT STD_LOGIC
    );
END ENTITY sample_ntt;