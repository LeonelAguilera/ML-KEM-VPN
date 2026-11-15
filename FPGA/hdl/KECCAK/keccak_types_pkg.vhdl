-- description: 
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE keccak_types_pkg IS

    type keccac_mode_t IS (h, g, j, xof, prf);
    
END PACKAGE keccak_types_pkg;