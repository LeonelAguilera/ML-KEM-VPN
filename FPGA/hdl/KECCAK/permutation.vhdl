-- description: Does a full permutation, so 24 rounds
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.mlkem_types_pkg.ALL;
USE work.keccak_types_pkg.ALL;

ENTITY permutation IS 
    PORT (
        a_in        : IN    keccak_string_t;
        round_index : IN    NATURAL RANGE 0 TO KECCAK_N_R-1;
        a_out       : OUT   keccak_string_t
    );
END ENTITY permutation;

ARCHITECTURE behavioral OF permutation IS 
    -- --------------------------------------
    -- TYPES
    -- --------------------------------------
    TYPE    rotation_matrix_t   IS ARRAY (0 to 4, 0 to 4) OF INTEGER RANGE 0 TO KECCAK_W;
    TYPE    rc_array_t          IS ARRAY (0 TO KECCAK_N_R-1) OF STD_LOGIC_VECTOR(6 DOWNTO 0);
    SUBTYPE lane_t              IS STD_LOGIC_VECTOR(KECCAK_W-1 DOWNTO 0);
    TYPE    lane_array_t        IS ARRAY (NATURAL range <>) of lane_t;
    TYPE    keccak_state_t      IS ARRAY (0 TO 4, 0 TO 4) of lane_t;

    -- --------------------------------------
    -- FUNCTIONS
    -- --------------------------------------
    -- creates a matrix of offset values used in rho step
    FUNCTION create_rho_rotation RETURN rotation_matrix_t IS 
        VARIABLE result : rotation_matrix_t;
        VARIABLE x,y    : NATURAL RANGE 0 TO 4;
    BEGIN 
        x := 1;
        y := 0;
        result(0,0) := 0;
        FOR t IN 0 TO 23 LOOP
            result(x,y) := ((t+1)*(t+2)/2) MOD KECCAK_W;
        END LOOP;
        RETURN result;
    END FUNCTION;

    -- round constant helper function (see rc in FIPS 202)
    FUNCTION rc(
        t : IN INTEGER
    ) RETURN STD_LOGIC IS 
        VARIABLE r : STD_LOGIC_VECTOR(8 DOWNTO 0);
    BEGIN 
        r := "010000000";
        IF t MOD 255 = 0 THEN
            RETURN '1';
        ELSE 
            FOR i IN 1 TO (t MOD 255) LOOP
                r := r(7 DOWNTO 0) & '0';
                r(0) := r(0) XOR r(8);
                r(4) := r(5) XOR r(8);
                r(5) := r(4) XOR r(8);
                r(6) := r(6) XOR r(8);
            END LOOP;
            RETURN r(0);
        END IF;
    END FUNCTION;

    -- creates the array of round constants
    FUNCTION create_round_constant RETURN rc_array_t IS
        VARIABLE result : rc_array_t; 
    BEGIN 
        FOR index IN 0 TO KECCAK_N_R-1 LOOP
            FOR j IN 0 TO KECCAK_L LOOP
                result(index)(j) := rc(j+7*index);
            END LOOP;
        END LOOP;
        RETURN result;
    END FUNCTION;

    FUNCTION string_to_state(
        s: IN keccak_string_t
    ) RETURN keccak_state_t IS 
        VARIABLE a : keccak_state_t;
    BEGIN
        FOR x IN a'RANGE(1) LOOP
            FOR y IN a'RANGE(2) LOOP
                a(x,y) := s(KECCAK_W*(x + 5*y + 1)-1 DOWNTO KECCAK_W*(x + 5*y));
            END LOOP;
        END LOOP;
        RETURN a;
    END string_to_state;

    FUNCTION state_to_string(
        a: IN keccak_state_t
    ) RETURN keccak_string_t IS
        VARIABLE s : keccak_string_t;
    BEGIN
        FOR x IN a'RANGE(1) LOOP
            FOR y IN a'RANGE(2) LOOP
                s(KECCAK_W*(x + 5*y + 1)-1 DOWNTO KECCAK_W*(x + 5*y)) := a(x,y);
            END LOOP;
        END LOOP;
        RETURN s;
    END state_to_string;

    -- --------------------------------------
    -- CONSTANTS
    -- --------------------------------------
    CONSTANT rho_rotation   : rotation_matrix_t := create_rho_rotation;
    CONSTANT round_constant : rc_array_t := create_round_constant;

    -- --------------------------------------
    -- SIGNALS
    -- --------------------------------------
    SIGNAL a_initial, a_theta, a_rho, a_pi, a_chi, a_iota : keccak_state_t;
    SIGNAL c_theta : lane_array_t(0 TO 4);
    SIGNAL d_theta : lane_array_t(0 TO 4);

BEGIN ------------------------------------------------------------------------------------------------------
    a_initial <= string_to_state(a_in);
    a_out <= state_to_string(a_iota);

    -- --------------------------------------
    -- Permutation operations
    -- --------------------------------------
    -- Theta
    PROCESS(all) 
    BEGIN
        FOR x IN 0 TO 4 LOOP
            c_theta(x) <= a_initial(x,0) XOR a_initial(x,1) XOR a_initial(x,2) XOR a_initial(x,3) XOR a_initial(x,4); 
            FOR z IN 0 TO KECCAK_W-1 LOOP
                d_theta(x)(z) <= c_theta((x-1) MOD 5)(z) XOR c_theta((x+1) MOD 5)((z-1) MOD KECCAK_W);
                FOR y IN 0 TO 4 LOOP
                    a_theta(x,y)(z) <= a_initial(x,y)(z) XOR d_theta(x)(z);
                END LOOP;
            END LOOP;
        END LOOP;
    END PROCESS;

    -- Rho
    PROCESS(all) 
    BEGIN
        FOR x IN 0 TO 4 LOOP
            FOR y IN 0 TO 4 LOOP
                FOR z IN 0 TO KECCAK_W-1 LOOP
                    a_rho(x,y)(z) <= a_theta(x,y)((z-rho_rotation(x,y)) MOD KECCAK_W);
                END LOOP;
            END LOOP;
        END LOOP;
    END PROCESS;

    -- Pi
    PROCESS(all) 
    BEGIN
        FOR x IN 0 TO 4 LOOP
            FOR y IN 0 TO 4 LOOP
                a_pi(x,y) <= a_rho((x+3*y) MOD 5, x);
            END LOOP;
        END LOOP; 
    END PROCESS;

    -- Chi
    PROCESS(all) 
    BEGIN
        FOR x IN 0 TO 4 LOOP
            FOR y IN 0 TO 4 LOOP
                a_chi(x,y) <= a_pi(x,y) XOR (NOT a_pi((x+1) MOD 5, y) AND a_pi((x+2) MOD 5, y));
            END LOOP;
        END LOOP;
    END PROCESS;

    -- Iota
    PROCESS(all)
        VARIABLE var_a_iota : keccak_state_t;
    BEGIN 
        var_a_iota := a_chi;
        FOR j IN 0 TO KECCAK_L LOOP
            var_a_iota(0,0)(2**j-1) := var_a_iota(0,0)(2**j-1) XOR round_constant(round_index)(j);
        END LOOP;
        a_iota <= var_a_iota;   
    END PROCESS;


END ARCHITECTURE behavioral;