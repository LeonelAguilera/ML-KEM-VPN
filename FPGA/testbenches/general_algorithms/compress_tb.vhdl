LIBRARY vunit_lib;
USE vunit_lib.run_pkg.ALL;
USE vunit_lib.string_ops.ALL;
context vunit_lib.vunit_context;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.textio.ALL;

USE work.mlkem_types_pkg.ALL;

ENTITY compress_tb IS
  GENERIC (
    runner_cfg       : STRING;
    pipeline         : INTEGER := 0;
    clk_period       : TIME := 20 ns
    );
END ENTITY;

ARCHITECTURE behavioral OF compress_tb is
    CONSTANT number_of_bits     : NATURAL := 5;

    TYPE test_data IS RECORD
        x       : poly_t;
        comp    : poly_t;
    END RECORD test_data;

    TYPE out_data IS RECORD
        comp    : poly_t;
    END RECORD out_data;

    TYPE pipeddata IS ARRAY(INTEGER RANGE <>) OF test_data;

    SIGNAL pipedout                         : pipeddata(0 TO pipeline);
    SIGNAL pipeddone                        : STD_LOGIC_VECTOR(0 TO pipeline);
    SIGNAL actual_data, out_conn            : out_data;
    SIGNAL ref_data, delayed_ref_data       : test_data;
    SIGNAL done, delayed_done               : STD_LOGIC := '0';
    SIGNAL data_count                       : INTEGER   := 0;

    SIGNAL clk                              : STD_LOGIC := '0';
BEGIN
    -- --------------------------------------------------------------
    -- Connections to unit under test
    -- --------------------------------------------------------------
    UUT : ENTITY work.compress
        GENERIC MAP(
            d => number_of_bits
          )
        PORT MAP(
            x       => ref_data.x,
            comp    => out_conn.comp
          );

    -- --------------------------------------------------------------
    -- Main process
    -- --------------------------------------------------------------    
    main : PROCESS
    BEGIN
      test_runner_setup(runner, runner_cfg);  --Vunit test simulation starts
      WHILE delayed_done /= '1' LOOP
        WAIT UNTIL RISING_EDGE(clk);
        WAIT FOR 0.1 ns;
        IF data_count >= pipeline + 1 AND delayed_done = '0' THEN
            REPORT "TEST #" & to_string(data_count-pipeline) & 
                ": comp(0) = " & to_string(delayed_ref_data.comp(0));
            FOR i IN 0 TO 5 LOOP
                check_equal(UNSIGNED(actual_data.comp(i)), UNSIGNED(delayed_ref_data.comp(i)));
            END LOOP;
        END IF;
      END LOOP;

      test_runner_cleanup(runner);      -- Simulation ends here
    END PROCESS;

    -- --------------------------------------------------------------
    -- Create test data
    -- --------------------------------------------------------------
    create_test : PROCESS
        CONSTANT number_of_tests    : INTEGER := 3;

        TYPE test_array_t IS ARRAY (0 TO number_of_tests-1) of coeff_t;

        VARIABLE input_x_array : test_array_t := (
            "101110111000", -- 3000
            "000000010111", -- 23
            "011000011111" -- 1567
        );

        VARIABLE comp_array : test_array_t := (
            "000000011101", -- 29
            "000000000000", -- 0
            "000000001111" -- 15
        );

    BEGIN
        WAIT UNTIL RISING_EDGE(clk);
        IF data_count = number_of_tests THEN
            done <= '1';
        ELSE
            FOR i IN 0 TO 255 LOOP  
                ref_data.x(i) <= input_x_array(data_count);
                ref_data.comp(i) <= comp_array(data_count);
            END LOOP;
            data_count <= data_count + 1;
        END IF;        
    END PROCESS;

    storeoutput : PROCESS(clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
            actual_data.comp <= out_conn.comp;
        END IF;
    END PROCESS;

    -- --------------------------------------------------------------
    -- Delay block for pipeline and clock generation
    -- --------------------------------------------------------------
    delayblock : PROCESS(clk)
        VARIABLE i : INTEGER;
    BEGIN
        IF RISING_EDGE(clk) THEN
        pipedout(0)  <= ref_data;
        pipeddone(0) <= done;
        IF pipeline >= 1 THEN

            FOR i IN 1 TO pipeline LOOP
            pipedout(i)  <= pipedout(i-1);
            pipeddone(i) <= pipeddone(i-1);
            END LOOP;
        END IF;
        END IF;
    END PROCESS;

    delayed_done <= pipeddone(pipeline);
    delayed_ref_data <= pipedout(pipeline);

    clk_gen : PROCESS
    BEGIN
        clk <= not(clk);
        WAIT FOR clk_period;
    END PROCESS clk_gen;

    -- --------------------------------------------------------------
    -- Vunit settings
    -- --------------------------------------------------------------
    -- Show information about passing tests as well
    show(get_logger(default_checker), display_handler, pass);
    -- Do not stop on failing tests. Useful here as we test many dIFferent inputs.
    disable_stop(get_logger(default_checker), error);

END ARCHITECTURE;