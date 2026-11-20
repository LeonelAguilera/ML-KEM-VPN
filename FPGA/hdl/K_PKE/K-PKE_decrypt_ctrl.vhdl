LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.mlkem_types_pkg.ALL;

ENTITY kpke_decrypt_ctrl IS
    PORT(
        clk : IN STD_LOGIC;
        start : IN STD_LOGIC;
        k     : IN INTEGER RANGE 2 TO 4;
        op_start : OUT STD_LOGIC;
        
        op_code : OUT INTEGER RANGE 0 TO 8;

        poly_index : OUT INTEGER RANGE 0 TO 3;

        op_done : IN STD_LOGIC;

        done : OUT STD_LOGIC
    );
END ENTITY kpke_decrypt_ctrl;

ARCHITECTURE rtl OF kpke_decrypt_ctrl IS

    TYPE state_t IS(
        idle,
        issue_op,
        wait_result,
        finish
    );

    TYPE step_t IS (
        decode_sk,      -- 0
        decode_u,       -- 1
        decode_v,       -- 2
        clear_acc,      -- 3
        ntt_u,          -- 4
        mul_acc,        -- 5
        intt_acc,       -- 6
        subtract_v,     -- 7
        pack_message    -- 8
    );
    
    SIGNAL state : state_t := idle;
    SIGNAL step  : step_t  := decode_sk;

    SIGNAL idx   : integer Range 0 To 3 := 0;
    SIGNAL k_reg : integer Range 2 To 4 := 2;

    BEGIN
        op_start   <= '1' WHEN state = issue_op ELSE '0';
        done       <= '1' WHEN state = finish   ELSE '0';
        op_code    <= step_t'pos(step);
        poly_index <= idx;

        fsm : PROCESS (clk)
        BEGIN
            IF rising_edge(clk) THEN
                CASE state IS

                    WHEN idle =>
                        IF start = '1' THEN
                            k_reg <= k;         -- k is sampled once, at start
                            step  <= decode_sk;
                            idx   <= 0;
                            state <= issue_op;
                        END IF;

                    WHEN issue_op =>
                        state <= wait_result;

                    WHEN wait_result =>
                        IF op_done = '1' THEN
                            state <= issue_op;  -- default, overridden after the last step

                            CASE step IS
                                WHEN decode_sk =>
                                    IF idx = k_reg - 1 THEN
                                        idx  <= 0;
                                        step <= decode_u;
                                    ELSE
                                        idx <= idx + 1;
                                    END IF;

                                WHEN decode_u =>
                                    IF idx = k_reg - 1 THEN
                                        idx  <= 0;
                                        step <= decode_v;
                                    ELSE
                                        idx <= idx + 1;
                                    END IF;

                                WHEN decode_v =>
                                    step <= clear_acc;

                                WHEN clear_acc =>
                                    idx  <= 0;
                                    step <= ntt_u;

                                WHEN ntt_u =>
                                    step <= mul_acc;    -- same idx

                                WHEN mul_acc =>
                                    IF idx = k_reg - 1 THEN
                                        idx  <= 0;
                                        step <= intt_acc;
                                    ELSE
                                        idx  <= idx + 1;
                                        step <= ntt_u;
                                    END IF;

                                WHEN intt_acc =>
                                    step <= subtract_v;

                                WHEN subtract_v =>
                                    step <= pack_message;

                                WHEN pack_message =>
                                    state <= finish;
                            END CASE;
                        END IF;

                    WHEN finish =>
                        step  <= decode_sk;
                        idx   <= 0;
                        state <= idle;

                END CASE;
            END IF;
        END PROCESS fsm;

END ARCHITECTURE;