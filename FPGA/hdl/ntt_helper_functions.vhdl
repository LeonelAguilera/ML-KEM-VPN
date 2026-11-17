LIBRARY ieee; 
USE ieee.numeric_std.ALL;
USE ieee.std_logic_1164.ALL;
LIBRARY work;
USE work.mlkem_types_pkg.ALL;

PACKAGE ntt_helper_functions IS
    PURE FUNCTION bit_reverse(data_in: IN INTEGER) RETURN INTEGER;
    PURE FUNCTION compute_ntt_zeta(i : IN INTEGER) RETURN coeff_t;
END PACKAGE ntt_helper_functions;


PACKAGE BODY ntt_helper_functions IS
    PURE FUNCTION bit_reverse(data_in: IN INTEGER) RETURN INTEGER IS
        VARIABLE bit_representation: UNSIGNED(6 DOWNTO 0);
        VARIABLE data_out: UNSIGNED(6 DOWNTO 0);
    BEGIN
        bit_representation := TO_UNSIGNED(data_in, 7);
        FOR i IN 0 TO 6 LOOP
            data_out(6 - i) := bit_representation(i);
        END LOOP;
        RETURN TO_INTEGER(data_out);
    END FUNCTION bit_reverse;

    PURE FUNCTION compute_ntt_zeta(i : IN INTEGER) RETURN coeff_t IS
        CONSTANT zeta_base: INTEGER := 17;
        VARIABLE exponent: INTEGER;
        VARIABLE result: INTEGER;
    BEGIN
        result := 1;
        exponent := bit_reverse(i);

        FOR i IN 1 TO exponent LOOP
            result := (result * zeta_base) MOD MLKEM_Q;
        END LOOP;

        REPORT "exponent = " & INTEGER'IMAGE(exponent) & " \t result = " & INTEGER'IMAGE(result);

        RETURN STD_LOGIC_VECTOR(TO_UNSIGNED(result, COEFF_WL));
    END FUNCTION;
END PACKAGE BODY ntt_helper_functions;
