library vunit_lib;
use vunit_lib.run_pkg.all;
use vunit_lib.string_ops.all;
context vunit_lib.vunit_context;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
LIBRARY work;
USE work.mlkem_types_pkg.ALL;

ENTITY tb_ntt IS
    GENERIC (
        runner_cfg       : STRING;
        pipeline         : INTEGER := 0;
        file_name        : STRING;
        clk_period       : TIME := 20 NS
    );
END tb_ntt;

ARCHITECTURE tb OF tb_ntt IS
    TYPE ntt_data IS RECORD
        f: poly_t;
        f_hat: poly_t;
    END RECORD ntt_data;

    SIGNAL data1, ref_data: ntt_data;
    SIGNAL done, delayeddone: STD_LOGIC := '0';
    SIGNAL clk: STD_LOGIC := '0';
    SIGNAL data_count : INTEGER := 0;

    SIGNAL f_hat, f_hat_d : poly_t;

    SIGNAL f  : poly_t;
    SIGNAL fp : poly_t;

    FILE intext: TEXT OPEN read_mode IS file_name;
    TYPE pipeddata IS ARRAY(INTEGER RANGE <>) OF ntt_data;
    SIGNAL pipedout : pipeddata(0 TO pipeline);
    SIGNAL pipeddone : STD_LOGIC_VECTOR(0 TO pipeline);
BEGIN
    -- Show information about passing tests as well
    SHOW(GET_LOGGER(DEFAULT_CHECKER), DISPLAY_HANDLER, PASS);

    -- Do not stop on failing tests. Useful here as we test many different inputs.
    DISABLE_STOP(GET_LOGGER(DEFAULT_CHECKER), ERROR);

    -- Read inputs, operation, and expected outputs from file
    read_inputs : PROCESS
        VARIABLE iline: LINE;
        VARIABLE chk_line: LINES_T;
        VARIABLE array_elements: LINES_T;
        VARIABLE file_f_element, file_f_hat_element: INTEGER;
    BEGIN
        WAIT UNTIL rising_edge(clk);
        IF NOT(ENDFILE(intext)) THEN
            READLINE(intext, iline);
            REPORT iline.ALL;
            chk_line := SPLIT(STRIP(iline.ALL), ";");
            REPORT chk_line(0).ALL;
            REPORT chk_line(1).ALL;

            array_elements := SPLIT(STRIP(chk_line(0).ALL), ",");
            FOR i IN 0 TO 255 LOOP
                READ(array_elements(i), file_f_element);
                data1.f(i) <= STD_LOGIC_VECTOR(TO_UNSIGNED(file_f_element, COEFF_WL));
            END LOOP;

            array_elements := SPLIT(STRIP(chk_line(1).ALL), ",");
            FOR i IN 0 TO 255 LOOP
                READ(array_elements(i), file_f_hat_element);
                data1.f_hat(i) <= STD_LOGIC_VECTOR(TO_UNSIGNED(file_f_hat_element, COEFF_WL));
            END LOOP;

            data_count <= data_count + 1;
        ELSE
            done <= '1';
        END IF;
    END PROCESS;

    delayblock: PROCESS(clk)
        VARIABLE i: INTEGER;
    BEGIN
        IF RISING_EDGE(clk) THEN
            pipedout(0) <= data1;
            pipeddone(0) <= done;

            IF pipeline >= 1 THEN
                FOR i IN 1 TO pipeline LOOP
                    pipedout(i) <= pipedout(i - 1);
                    pipeddone(i) <= pipeddone(i - 1);
                END LOOP;
            END IF;
        END IF;
    END PROCESS;

    delayeddone <= pipeddone(pipeline);
    ref_data    <= pipedout(pipeline);

    storeoutput: PROCESS(clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
            f_hat_d <= f_hat;
        END IF;
    END PROCESS;

    clk_gen: PROCESS
    BEGIN
        clk <= NOT(clk);
        WAIT FOR clk_period;
    END PROCESS clk_gen;

    dut: ENTITY work.ntt
        PORT MAP(
            f => data1.f,
            fp => f_hat
        );

    main: PROCESS
    BEGIN
        TEST_RUNNER_SETUP(RUNNER, RUNNER_CFG);
        WHILE delayeddone /= '1' LOOP
            WAIT UNTIL RISING_EDGE(clk);
            IF data_count >= PIPELINE + 1 AND delayeddone = '0' THEN
                WAIT FOR 0.1 NS;
                FOR index IN 0 TO 255 LOOP
                    CHECK_EQUAL(UNSIGNED(f_hat_d(index)), UNSIGNED(ref_data.f_hat(index)), "Inputs: " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(ref_data.f(index)))));
                END LOOP;
            END IF;
        END LOOP;

        TEST_RUNNER_CLEANUP(RUNNER);
    END PROCESS main;
END ARCHITECTURE;
