library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity kpke_decrypt_ctrl is
    generic(
        K; integer range 2 to 4 := 2

    );
    port
    (
        clk : in std_logic;
        rst : in std_logic;

        start : in  std_logic;
        busy  : out std_logic;
        done  : out std_logic;
        
        --command interface, which goes to other blocks
        cmd_valid : out std_logic;
        cmd_ready : in  std_logic;
        cmd_code  : out std_logic_vector(3 downto 0);

        poly_index : out integer range 0 to K-1;

        op_done : in std_logic
    );
    end entity;
    