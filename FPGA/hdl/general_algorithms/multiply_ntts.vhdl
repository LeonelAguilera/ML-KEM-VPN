LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.mlkem_types_pkg.ALL;

ENTITY multiply_ntts IS
    PORT (
        f: IN poly_t;
        g: IN poly_t;
        h: OUT poly_t
    );
END ENTITY;

ARCHITECTURE behavioral OF multiply_ntts IS
    COMPONENT base_case_multiply IS
        GENERIC(
            i: INTEGER
        );
        PORT (
            a0: IN coeff_t;
            a1: IN coeff_t;
            b0: IN coeff_t;
            b1: IN coeff_t;
            c0: OUT coeff_t;
            c1: OUT coeff_t
        );
    END COMPONENT;
BEGIN
    ntt_multiplications: FOR i IN 0 TO 127 GENERATE
        multiplier: base_case_multiply
            GENERIC MAP (
                i => i
            )
            PORT MAP (
                a0 => f((2 * i) + 0),
                a1 => f((2 * i) + 1),
                b0 => g((2 * i) + 0),
                b1 => g((2 * i) + 1),
                c0 => h((2 * i) + 0),
                c1 => h((2 * i) + 1)
            );
    END GENERATE;
END ARCHITECTURE;
