Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use work.mlkem_types_pkg.all;

Entity kpke_keygen Is
    Port(
        clk   : In std_logic;
        start : In std_logic;
        k     : In integer range 2 to 4;

        d : In byte_array_t(31 downto 0);
        
        ek  : Out byte_array_t(31 downto 0);
        dk  : Out byte_array_t(31 downto 0);

        done : Out std_logic
    );
    End Entity kpke_keygen;