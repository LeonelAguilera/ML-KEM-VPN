LIBRARY ieee; 
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.math_real.ALL;

PACKAGE mlkem_types_pkg IS
  
  -----------------------------------------------------------
  -- CONSTANTS 
  -----------------------------------------------------------
  CONSTANT MLKEM_Q     : POSITIVE := 3329;
  CONSTANT MLKEM_N     : POSITIVE := 256;
  CONSTANT COEFF_WL    : POSITIVE := INTEGER(CEIL(LOG2(REAL(MLKEM_Q - 1))));

  -----------------------------------------------------------
  -- TYPES
  -----------------------------------------------------------
  SUBTYPE   byte_t          IS STD_LOGIC_VECTOR(7 DOWNTO 0);
  SUBTYPE   coeff_t         IS STD_LOGIC_VECTOR(COEFF_WL - 1 DOWNTO 0);
  TYPE      poly_t          IS ARRAY (MLKEM_N - 1 DOWNTO 0) of coeff_t;
  TYPE      byte_array_t    IS ARRAY (NATURAL range <>) of byte_t;

  -----------------------------------------------------------
  -- FUNCTIONS
  -----------------------------------------------------------
  FUNCTION bytestobits(b_in: IN byte_array_t) RETURN STD_LOGIC_VECTOR;
  FUNCTION bitstobytes(b_in: IN STD_LOGIC_VECTOR) RETURN byte_array_t;

  FUNCTION "+" (lhs: coeff_t; rhs: coeff_t) RETURN coeff_t;
  FUNCTION "-" (lhs: coeff_t; rhs: coeff_t) RETURN coeff_t;
  FUNCTION "*" (lhs: coeff_t; rhs: coeff_t) RETURN coeff_t;

END PACKAGE mlkem_types_pkg;

PACKAGE BODY mlkem_types_pkg IS

  FUNCTION bytestobits(
    b_in: IN byte_array_t
  ) RETURN STD_LOGIC_VECTOR IS 
    VARIABLE b_out : STD_LOGIC_VECTOR(8*b_in'LENGTH-1 DOWNTO 0);
  begin
    FOR i IN b_in'LOW TO b_in'HIGH LOOP
        FOR j IN 0 TO 7 LOOP
            b_out(8*i + j) := b_in(i)(j);
        END LOOP;
    END LOOP;
    RETURN b_out;
  END bytestobits;

  FUNCTION bitstobytes(
    b_in: IN STD_LOGIC_VECTOR
  ) RETURN byte_array_t IS
    VARIABLE b_out : byte_array_t(b_in'LENGTH/8-1 DOWNTO 0);
  begin
    ASSERT (b_in'LENGTH mod 8 = 0)
      REPORT "bitstobytes: Input length must be a multiple of 8"
      SEVERITY warning;

    b_out := (OTHERS => (OTHERS => '0'));

    FOR i IN b_in'LOW TO b_in'HIGH LOOP
        b_out(i / 8)(i mod 8) := b_in(i);
    END LOOP;

    RETURN b_out;
  END bitstobytes;

    FUNCTION "+" (
        lhs: coeff_t;
        rhs: coeff_t
    ) RETURN coeff_t IS
        VARIABLE intermediate_result: UNSIGNED(0 TO COEFF_WL);
    BEGIN
        intermediate_result := UNSIGNED(lhs & '0') + UNSIGNED(rhs & '0');
        IF intermediate_result >= MLKEM_Q THEN
            intermediate_result := intermediate_result - MLKEM_Q;
        END IF;
        RETURN STD_LOGIC_VECTOR(intermediate_result(0 TO COEFF_WL - 1));
    END FUNCTION "+";

    FUNCTION "-" (
        lhs: coeff_t;
        rhs: coeff_t
    ) RETURN coeff_t IS
        VARIABLE intermediate_result: UNSIGNED(0 TO COEFF_WL);
    BEGIN
        intermediate_result := UNSIGNED(lhs & '0') - UNSIGNED(rhs & '0');
        IF intermediate_result < 0 THEN
            intermediate_result := intermediate_result + MLKEM_Q;
        END IF;
        RETURN STD_LOGIC_VECTOR(intermediate_result(0 TO COEFF_WL - 1));
    END FUNCTION "-";

    FUNCTION "*" (
        lhs: coeff_t;
        rhs: coeff_t
    ) RETURN coeff_t IS
        CONSTANT mmwl: INTEGER := 18; -- MMWL means: Minimum Multiplier Word Length
        CONSTANT wl_difference: INTEGER := mmwl - COEFF_WL;
        CONSTANT reciprocal: UNSIGNED(0 TO (mmwl - 1)) := TO_UNSIGNED(161270, mmwl); -- Obtained via ((2^6)/MLKEM_Q)*2^23
        -- where 6=(2*COEFF_WL - mmwl)
        -- where 23 = bit-shift required to move the MSB of the previous operation to the MSB of MMWL
        CONSTANT padding: STD_LOGIC_VECTOR(0 TO wl_difference - 1) := STD_LOGIC_VECTOR(TO_UNSIGNED(0, wl_difference));

        VARIABLE product: UNSIGNED(0 TO (2 * mmwl) - 1);
        VARIABLE shifted_product: UNSIGNED(0 TO (2 * mmwl) - 1);
        VARIABLE n_p_temp: UNSIGNED(0 TO (2 * mmwl) - 1);
        VARIABLE n_p: UNSIGNED(0 TO COEFF_WL - 1);
        VARIABLE pre_modulo: UNSIGNED(0 TO (2 * mmwl) - 1);
        VARIABLE modulo: UNSIGNED(0 TO COEFF_WL - 1);
    BEGIN
        product := UNSIGNED(STD_LOGIC_VECTOR'(lhs & padding)) * UNSIGNED(STD_LOGIC_VECTOR'(rhs & padding));
        shifted_product := SHIFT_RIGHT(product, 6);
        n_p_temp := SHIFT_RIGHT(shifted_product(0 TO mmwl - 1) * reciprocal, 23);
        n_p := n_p_temp(0 TO COEFF_WL - 1);
        pre_modulo := product - (MLKEM_Q * n_p);
        modulo := pre_modulo(0 TO COEFF_WL - 1);
        IF modulo > MLKEM_Q THEN
            RETURN STD_LOGIC_VECTOR(modulo - MLKEM_Q);
        ELSE
            RETURN STD_LOGIC_VECTOR(modulo);
        END IF;
    END FUNCTION "*";
END PACKAGE BODY mlkem_types_pkg;