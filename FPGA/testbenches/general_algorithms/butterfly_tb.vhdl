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


ENTITY butterfly_tb IS
    GENERIC (
		zeta:	coeff_t;

        runner_cfg       : STRING;
        pipeline         : INTEGER := 0;
        file_name        : STRING;
        clk_period       : TIME := 20 NS
    );
END butterfly_tb;

ARCHITECTURE tb OF butterfly_tb IS
    TYPE butterfly_data IS RECORD
        x0: coeff_t;
		x1: coeff_t;
		y0: coeff_t;
		y1: coeff_t;
		
    END RECORD butterfly_data;

    SIGNAL data1, ref_data: butterfly_data;
    SIGNAL done, delayeddone: STD_LOGIC := '0';
    SIGNAL clk: STD_LOGIC := '0';
    SIGNAL data_count : INTEGER := 0;
    
    SIGNAL y0, y0_d : coeff_t;
		SIGNAL y1, y1_d : coeff_t;
		

    FILE intext: TEXT OPEN read_mode IS file_name;
    TYPE pipeddata IS ARRAY(INTEGER RANGE <>) OF butterfly_data;
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
        VARIABLE file_x0: COEFF_T;
VARIABLE file_x1: COEFF_T;
VARIABLE file_y0: COEFF_T;
VARIABLE file_y1: COEFF_T;

    BEGIN
        WAIT UNTIL rising_edge(clk);
        IF NOT(ENDFILE(intext)) THEN
            READLINE(intext, iline);
            chk_line := SPLIT(STRIP(iline.ALL), ";");

READ(chk_line(0), file_x0);
data1.x0 <= file_x0;
READ(chk_line(1), file_x1);
data1.x1 <= file_x1;
READ(chk_line(2), file_y0);
data1.y0 <= file_y0;
READ(chk_line(3), file_y1);
data1.y1 <= file_y1;


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
						y0_d <= y0;
y1_d <= y1;

        END IF;
    END PROCESS;

    clk_gen: PROCESS
    BEGIN
        clk <= NOT(clk);
        WAIT FOR clk_period;
    END PROCESS clk_gen;

    dut: ENTITY work.butterfly
        GENERIC MAP(
			zeta => zeta
		)

        PORT MAP(
			x0 => data1.x0,
			x1 => data1.x1,
			y0 => y0,
			y1 => y1
        );

    main: PROCESS
    BEGIN
        TEST_RUNNER_SETUP(RUNNER, RUNNER_CFG);
        WHILE delayeddone /= '1' LOOP
            WAIT UNTIL RISING_EDGE(clk);
            IF data_count >= PIPELINE + 1 AND delayeddone = '0' THEN
                WAIT FOR 0.1 NS;
                FOR index IN 0 TO 255 LOOP
					CHECK_EQUAL(y0_d, ref_data.y0, "Inputs: [THIS IS A PLACEHOLDER, TO GET INPUT DISPLAY MODIFY THE TESTBENCH DIRECTLY]");
					CHECK_EQUAL(y1_d, ref_data.y1, "Inputs: [THIS IS A PLACEHOLDER, TO GET INPUT DISPLAY MODIFY THE TESTBENCH DIRECTLY]");

                END LOOP;
            END IF;
        END LOOP;

        TEST_RUNNER_CLEANUP(RUNNER);
    END PROCESS main;
END ARCHITECTURE;
