LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.mlkem_types_pkg.ALL;
USE work.kpke_pkg.ALL;

ENTITY kpke_keygen IS
    PORT(
        clk   : IN STD_LOGIC;
        start : IN STD_LOGIC;
        k     : IN INTEGER RANGE 2 TO 4;

        d : IN byte_array_t(0 TO KPKE_SEED_BYTES - 1);

        ek : OUT byte_array_t(0 TO KPKE_EK_MAX_BYTES - 1);  -- 384*k + 32 bytes used
        dk : OUT byte_array_t(0 TO KPKE_DK_MAX_BYTES - 1);  -- 384*k bytes used

        done : OUT STD_LOGIC
    );
END ENTITY kpke_keygen;