LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
LIBRARY work;
USE work.mlkem_types_pkg.ALL;
USE work.ntt_helper_functions.ALL;

ENTITY ntt IS
    PORT (
        f: IN poly_t;
        fp: OUT poly_t 
    );
END ENTITY;

ARCHITECTURE behavioral OF ntt IS
    CONSTANT layer_count: INTEGER := INTEGER(CEIL(LOG2(REAL(MLKEM_N))));
    TYPE layers_t IS ARRAY(layer_count - 1 DOWNTO 0) OF poly_t;

    SIGNAL layers: layers_t;

    COMPONENT butterfly IS
        GENERIC(
            zeta: coeff_t
        );
        PORT (
            x0: IN coeff_t;
            x1: IN coeff_t;
            y0: OUT coeff_t;
            y1: OUT coeff_t
        );
    END COMPONENT;
BEGIN
    layers(0) <= f;
    ntt_layers: FOR len_i IN 1 TO layer_count GENERATE
        ntt_sections: FOR start_i IN 0 TO (256/(2*(2**len_i)) - 1) GENERATE
            ntt_butterflies: FOR j IN (2*(2**len_i)*start_i) TO ((2*(2**len_i)*start_i) + (2**len_i) - 1) GENERATE
                ntt_butterfly: butterfly
                    GENERIC MAP (
                        zeta => compute_ntt_zeta(start_i + (2**(7 - len_i)))
                    )
                    PORT MAP (
                        x0 => layers(7 - len_i)(j),
                        x1 => layers(7 - len_i)(j + (2**len_i)),
                        y0 => layers(8 - len_i)(j),
                        y1 => layers(8 - len_i)(j + (2**len_i))
                    );
            END GENERATE;
        END GENERATE;
    END GENERATE;
    fp <= layers(layer_count - 1);
END ARCHITECTURE;

