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

Architecture rtl Of kpke_decrypt_ctrl Is

    Type state_t Is(
        idle,
        issue_op,
        wait_result,
        finish
    );

    Type step_t Is (
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
    
    Signal state : state_t := idle;
    Signal step  : step_t  := decode_sk;

    Signal idx   : integer Range 0 To 3 := 0;
    Signal k_reg : integer Range 2 To 4 := 2;

END ARCHITECTURE;