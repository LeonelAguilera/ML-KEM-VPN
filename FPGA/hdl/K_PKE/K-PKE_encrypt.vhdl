Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;

Entity kpke_decrypt_ctrl Is
    Port(
        clk   : In std_logic;
        start : In std_logic;
        k     : In integer Range 2 To 4;

        ek : In byte_array_t(31 Downto 0);
        m  : In byte_array_t(31 Downto 0);
        r  : In byte_array_t(31 Downto 0);

        ciphertext : Out byte_array_t(31 Downto 0);

        done : Out std_logic
    );
    End Entity;
