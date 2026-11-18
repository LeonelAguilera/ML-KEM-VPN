-- description: 
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE keccak_types_pkg IS

    type keccac_mode_t IS (mode_h, mode_g, mode_j, mode_xof, mode_prf);
    
END PACKAGE keccak_types_pkg;