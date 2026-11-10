-- description: 
-- author:      Julia Müller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mlkem_types_pkg.all;

entity ntt_inv is 
    port (
        f_in    : in  poly_t;
        f_out   : out poly_t
    );
end entity ntt_inv;