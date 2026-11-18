LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.mlkem_types_pkg.ALL;
USE work.ntt_helper_functions.ALL;

ENTITY base_case_multiply IS
    GENERIC(
        i: INTEGER := 0
    );
    PORT (
        a0: IN coeff_t;
        a1: IN coeff_t;
        b0: IN coeff_t;
        b1: IN coeff_t;
        c0: OUT coeff_t;
        c1: OUT coeff_t
    );
END ENTITY;

ARCHITECTURE behavioral OF base_case_multiply IS
    CONSTANT gamma: coeff_t := compute_mul_ntt_zeta(i);
BEGIN
    c0 <= (a0 * b0) + (a1 * b1 * gamma) WHEN (i MOD 2) = 0 ELSE
          (a0 * b0) - (a1 * b1 * gamma);
    c1 <= (a0 * b1) + (a1 * b0);
END ARCHITECTURE;
