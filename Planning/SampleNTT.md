ENTITY sample_ntt IS 
    PORT (
        clk     : IN  STD_LOGIC;
        start   : IN  STD_LOGIC;
        b       : IN  byte_array_t(0 TO 33);
        a       : OUT poly_t;
        done    : OUT STD_LOGIC
    );
END ENTITY sample_ntt;

- fixed input (34 byte)
- fixed output (one polynomial)

[[XOF.Init]]: no params
[[XOF.Absorb]]: unimportant
[[XOF.Squeeze]]: serial


