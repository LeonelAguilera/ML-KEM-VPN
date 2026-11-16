LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY butterfly IS
    GENERIC(
        zeta: coeff_t := 1
    );
    PORT (
        x0: IN coeff_t;
        x1: IN coeff_t;
        y0: IN coeff_t;
        y1: IN coeff_t
    );
END ENTITY;

ARCHITECTURE behavioral OF butterfly IS
    SIGNAL t: coeff_t;
BEGIN
    t <= zeta * x1;
    y0 <= x0 + t;
    y1 <= x0 - t;
END ARCHITECTURE;
