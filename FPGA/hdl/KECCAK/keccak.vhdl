-- description: The keccak unit implements the functions H, G, XOF, J and PRF, which are
--              based on SHA3-256, SHA3-512, SHAKE128 and SHAKE256. 
--              Because those use the same underlying keccak algorithms with different
--              input and output sizes as well as rates, this unit is called keccak.
-- author:      Julia Müller

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE work.keccak_types_pkg.ALL;

-- GENERIC description
-- data_in_size:    Defines size of input data (meaning number of parallel bits)
-- data_out_size:   Defines size of output data (meaning number of parallel bits)


-- PORT description
-- clk:         Wow, look at this! A clock!
-- reset:       used to reset internal permutation state
--              active low reset
--              -> for H, G, J, PRF: reset at start of each "function call"
--              -> for XOF: reset only when new context is used
-- mode:        selects the SHA3 function that is used, defined in keccak_types_pkg
-- data_in:     input_data -> data_in_size bits
-- in_len:      length of valid bits of current input = index of first invalid bit
--              (valid bits are expected at LSB end)
-- absorb:      set high for one clock cycle to indicate that data_in is ready 
--              (only valid if next_in is high, next_in goes low after the entity 
--              recognizes the next absorb and reads the input bits)
--              Staying high while next_in is low won't do anything.
-- squeeze:     set high for one clock cycle to indicate that data_out should be given
--              (wait for out_ready to read data_out)
--              Staying high while out_ready is low won't do anything.
-- data_out:    hashed output data, all data_out_size bits are valid always
--              (only throw them away when you know what you're doing)
-- next_in:     stays high as long as the unit is ready to read new input data and 
--              previous command was absorb or after reset
-- out_ready:   stays high as long as the current output is ready and unchanged and
--              previous command was squeeze

ENTITY keccak IS 
    GENERIC (
        data_in_size    : NATURAL;
        data_out_size   : NATURAL;
    )
    PORT (
        clk         : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC;
        mode        : IN  keccac_mode_t;
        data_in     : IN  STD_LOGIC_VECTOR (0 TO data_in_size-1);
        in_len      : IN  NATURAL RANGE 1 TO data_in_size;
        absorb      : IN  STD_LOGIC;
        squeeze     : IN  STD_LOGIC;
        data_out    : OUT STD_LOGIC_VECTOR (0 TO data_out_size);
        next_in     : OUT STD_LOGIC;
        out_ready   : OUT STD_LOGIC;
    );
END ENTITY keccak;