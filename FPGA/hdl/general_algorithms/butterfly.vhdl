LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY work;
USE work.mlkem_types_pkg.ALL;

ENTITY butterfly IS
    GENERIC(
        zeta: coeff_t := "000000000001"
    );
    PORT (
        x0: IN coeff_t;
        x1: IN coeff_t;
        y0: OUT coeff_t;
        y1: OUT coeff_t
    );
END ENTITY;

ARCHITECTURE behavioral OF butterfly IS
    SIGNAL t: coeff_t;
BEGIN
    t <= zeta * x1;
    y0 <= x0 + t;
    y1 <= x0 - t;
END ARCHITECTURE;
