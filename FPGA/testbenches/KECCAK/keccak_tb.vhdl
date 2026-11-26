LIBRARY vunit_lib;
USE vunit_lib.run_pkg.ALL;
USE vunit_lib.string_ops.ALL;
context vunit_lib.vunit_context;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.textio.ALL;

USE work.mlkem_types_pkg.ALL;
USE work.keccak_types_pkg.ALL;


ENTITY keccak_tb IS
  GENERIC (
    runner_cfg       : STRING;
    clk_period       : TIME := 20 ns
    );
END ENTITY;

ARCHITECTURE behavioral OF keccak_tb is
    SIGNAL done         : STD_LOGIC := '0';
    SIGNAL data_count   : INTEGER   := 0;

    SIGNAL clk          : STD_LOGIC := '0';

    SIGNAL dummy_in     : byte_array_t(1 DOWNTO 0) := (OTHERS => (OTHERS => '0'));
    SIGNAL data_out     : byte_array_t(1 DOWNTO 0);
    SIGNAL absorb       : STD_LOGIC := '0';
    SIGNAL squeeze      : STD_LOGIC := '0';
    SIGNAL reset        : STD_LOGIC := '0';
    SIGNAL next_in      : STD_LOGIC;
    SIGNAL out_ready    : STD_LOGIC;
    SIGNAL busy         : STD_LOGIC;

    SIGNAL absorb_done  : STD_LOGIC := '0';
    SIGNAL reset_done   : STD_LOGIC := '0';
BEGIN
    -- --------------------------------------------------------------
    -- Connections to unit under test
    -- --------------------------------------------------------------
    UUT : ENTITY work.keccak(dummy)
        GENERIC MAP(
            data_in_size    => 2,
            data_out_size   => 2
          )
        PORT MAP(
            clk         => clk,
            reset       => reset,
            mode        => mode_h,
            data_in     => dummy_in,
            in_len      => 1,
            absorb      => absorb,
            squeeze     => squeeze,
            data_out    => data_out,
            next_in     => next_in,
            out_ready   => out_ready,
            busy        => busy
          );

    -- --------------------------------------------------------------
    -- Main process
    -- --------------------------------------------------------------    
    main : PROCESS
        VARIABLE absorb_cnt : INTEGER := 0;
    BEGIN
        test_runner_setup(runner, runner_cfg);  --Vunit test simulation starts
        WHILE done /= '1' LOOP
            WAIT UNTIL RISING_EDGE(clk);

            IF reset_done = '0' THEN
                reset <= '1';
                reset_done <= '1';
            ELSE
                reset <= '0';
                IF absorb_done = '0' THEN
                    absorb <= '1';
                    IF absorb = '1' AND next_in = '1' THEN
                        absorb_cnt := absorb_cnt + 1;
                        IF absorb_cnt = 2 THEN
                            absorb_done <= '1';
                        END IF;
                        absorb <= '0';
                    END IF;                    
                ELSE
                    squeeze <= '1';
                END IF;

                IF squeeze = '1' AND out_ready = '1' THEN
                    data_count <= data_count + 1;
                    REPORT "TEST #" & to_string(data_count) & 
                        ": output = " & to_string(data_out(1)) & ", " & to_string(data_out(0));
                    IF data_count = 10 THEN 
                        done <= '1';
                    END IF;
                END IF;
            END IF;
        END LOOP;

        test_runner_cleanup(runner);      -- Simulation ends here
    END PROCESS;

    -- --------------------------------------------------------------
    -- clock generation
    -- --------------------------------------------------------------
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