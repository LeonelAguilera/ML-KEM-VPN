-- https://arxiv.org/pdf/2209.04423

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY random_number_generator IS
    PORT (
        clk: INPUT STD_LOGIC;
        random_number: OUTPUT byte_array_t(31 DOWNTO 0);
    );
END ENTITY;

ARCHITECTURE behavioral OF random_number_generator IS
    SIGNAL a, b, c, d, e, f, g: STD_LOGIC;
    SIGNAL seed: STD_LOGIC_VECTOR((32 * 8) - 1 DOWNTO 0);
    SIGNAL temp0: byte_array_t(31 DOWNTO 0);
    SIGNAL temp1: byte_array_t(31 DOWNTO 0);
    SIGNAL temp2: byte_array_t(31 DOWNTO 0);
    SIGNAL temp3: byte_array_t(31 DOWNTO 0);
BEGIN
    a = NOT g;
    b = NOT a;
    c = NOT b;
    d = NOT c;
    e = NOT d;
    f = NOT e;
    g = NOT f;

    PROCESS (clk, a) IS
    BEGIN
        IF RISING_EDGE(clk) THEN
            seed((32 * 8) - 1 DOWNTO 1) <= rand_output((32 * 8) - 2 DOWNTO 0);
            seed(0) <= a;
        END IF;
    END PROCESS;

    PROCESS(seed, temp0, temp1, temp2, temp3) IS
    BEGIN
        FOR i IN 0 TO 31 LOOP
            temp0(i) <= seed((8 * (i + 1)) - 1 DOWNTO 8 * i);

            FOR j IN 0 TO 7 LOOP
                temp0(i)(j) <= 
            END LOOP;
        END LOOP;
    END PROCESS;
END ARCHITECTURE;
