LIBRARY ieee; 
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;

PACKAGE mlkem_types_pkg IS
  
  -----------------------------------------------------------
  -- CONSTANTS 
  -----------------------------------------------------------
  CONSTANT MLKEM_Q     : POSITIVE := 3329;
  CONSTANT MLKEM_N     : POSITIVE := 256;

  -----------------------------------------------------------
  -- TYPES
  -----------------------------------------------------------
  SUBTYPE   byte_t          IS STD_LOGIC_VECTOR(0 TO 7);
  SUBTYPE   coeff_t         IS UNSIGNED(0 TO 11);
  TYPE      poly_t          IS ARRAY (0 TO MLKEM_N - 1) of coeff_t;
  TYPE      byte_array_t    IS ARRAY (NATURAL range <>) of byte_t;

  -----------------------------------------------------------
  -- FUNCTIONS
  -----------------------------------------------------------
  FUNCTION bytestobits(b_in: IN byte_array_t) RETURN STD_LOGIC_VECTOR;
  FUNCTION bitstobytes(b_in: IN STD_LOGIC_VECTOR) RETURN byte_array_t;

END PACKAGE mlkem_types_pkg;

PACKAGE BODY mlkem_types_pkg IS

  FUNCTION bytestobits(
    b_in: IN byte_array_t
  ) RETURN STD_LOGIC_VECTOR IS 
    VARIABLE b_out : STD_LOGIC_VECTOR(0 TO 8*b_in'LENGTH-1);
  begin
    FOR i IN 0 TO b_in'RANGE LOOP
        FOR j IN 0 TO 7 LOOP
            b_out(8*i + j) := b_in(i)(j);
        END LOOP;
    END LOOP;
    RETURN b_out;
  END bytestobits;

  FUNCTION bitstobytes(
    b_in: IN STD_LOGIC_VECTOR
  ) RETURN byte_array_t IS
    VARIABLE b_out : byte_array_t;
  begin
    ASSERT (b_in'LENGTH mod 8 = 0)
      REPORT "bitstobytes: Input length must be a multiple of 8"
      SEVERITY warning;

    b_out := (OTHERS => (OTHERS => '0'));

    FOR i IN 0 TO b_in'RANGE LOOP
        b_out(i / 8)(i mod 8) := b_in(i);
    END LOOP;

    RETURN b_out;
  END bitstobytes;

END PACKAGE BODY mlkem_types_pkg;