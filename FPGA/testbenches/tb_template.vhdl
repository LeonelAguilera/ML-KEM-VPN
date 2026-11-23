LIBRARY vunit_lib;
USE vunit_lib.run_pkg.ALL;
USE vunit_lib.string_ops.ALL;
context vunit_lib.vunit_context;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.textio.ALL;

USE work.mlkem_types_pkg.ALL;

ENTITY tb_name IS
  GENERIC (
    runner_cfg       : STRING;
    pipeline         : INTEGER := 0;
    file_name        : STRING;
    clk_period       : TIME := 20 ns
    );
END ENTITY;

ARCHITECTURE behavioral OF tb_name is
    TYPE test_data IS RECORD
        -- inputa
        -- inputb
        -- outputa
        -- outputb
    END RECORD test_data;

    TYPE out_data IS RECORD
        -- outputa
        -- outputb
    END RECORD out_data;

    TYPE pipeddata IS ARRAY(INTEGER RANGE <>) OF test_data;

    SIGNAL pipedout     : pipeddata(0 TO pipeline);
    SIGNAL pipeddone    : STD_LOGIC_VECTOR(0 TO pipeline);
    SIGNAL actual_data  : out_data;
    SIGNAL ref_data, delayed_ref_data       : test_data;
    SIGNAL done, delayed_done               : STD_LOGIC := '0';
    SIGNAL data_count                       : INTEGER   := 0;

    SIGNAL inputa_conn  : 
BEGIN
    -- --------------------------------------------------------------
    -- Connections to unit under test
    -- --------------------------------------------------------------
    UUT : ENTITY work.<entity_name>
        GENERIC MAP(
          )
        PORT MAP(
          );

    -- --------------------------------------------------------------
    -- Main process
    -- --------------------------------------------------------------    
    main : PROCESS
    BEGIN
      test_runner_setup(runner, runner_cfg);  --Vunit test simulation starts
      WHILE delayed_done /= '1' LOOP
        WAIT UNTIL RISING_EDGE(clk);
        IF data_count >= pipeline + 1 AND delayed_done = '0' THEN
          WAIT FOR 0.1 ns;
          REPORT "TEST #" & to_string(data_count-pipeline) & 
                ": inputa = " & to_string(ref_data.inputa) & 
                ", inputb = " & to_string(ref_data.inputb);
        --   check_equal(SIGNED(actual_data.ouputa), SIGNED(ref_data.outputa));
        --   check_equal(SIGNED(actual_data.ouputb), SIGNED(ref_data.outputb));
        END IF;
      END LOOP;

      test_runner_cleanup(runner);      -- Simulation ends here
    END PROCESS;

    -- --------------------------------------------------------------
    -- Reads one line of test file every clk cycle 
    -- Stores values in record ref_data
    -- --------------------------------------------------------------
    read_inputs : PROCESS
        VARIABLE Iline                                          : line;
        --VARIABLE file_inputa, file_inputb                     : integer;
        VARIABLE chk_line                                       : lines_t;
    BEGIN
        WAIT UNTIL RISING_EDGE(clk);
        IF NOT(ENDFILE(intext)) THEN
        READLINE(intext, Iline);
        chk_line        := split(strip(Iline.all), ",");
        -- Read test file input into record
        -- READ(chk_line(0), file_inputa);
        -- READ(chk_line(1), file_inputb);
        -- READ(chk_line(2), file_outputa);
        -- READ(chk_line(3), file_outputb);
        -- ref_data.inputa      <= std_logic_vector(to_signed(file_inputa, wordlength));
        -- ref_data.inputb      <= std_logic_vector(to_signed(file_inputb, wordlength));
        -- ref_data.outputa     <= std_logic_vector(to_signed(file_outputa, wordlength));
        -- ref_data.outputb     <= std_logic_vector(to_signed(file_outputb, wordlength));
        data_count      <= data_count + 1;
        ELSE
        done <= '1';
        END IF;
    END PROCESS;

    storeoutput : PROCESS(clk)
    BEGIN
        IF RISING_EDGE(clk) THEN
        -- actual_data.outputa <= outa;
        -- actual_data.outputb <= outb;
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