-- description: 
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.ALL;

PACKAGE keccak_types_pkg IS
    -----------------------------------------------------------
    -- CONSTANTS 
    -----------------------------------------------------------
    CONSTANT KECCAK_B       : POSITIVE := 1600;                                 -- permutation width
    CONSTANT KECCAK_W       : POSITIVE := INTEGER(KECCAK_B/25);                 -- lane size
    CONSTANT KECCAK_L       : POSITIVE := INTEGER(CEIL(LOG2(REAL(KECCAK_W))));  -- binary log of lane size
    CONSTANT KECCAK_N_R     : POSITIVE := 24;                                   -- total round number -> max round_index

    -----------------------------------------------------------
    -- TYPES
    -----------------------------------------------------------
    TYPE    keccac_mode_t   IS (mode_h, mode_g, mode_j, mode_xof, mode_prf);
    SUBTYPE keccak_string_t IS STD_LOGIC_VECTOR(KECCAK_B-1 DOWNTO 0);

    
END PACKAGE keccak_types_pkg;