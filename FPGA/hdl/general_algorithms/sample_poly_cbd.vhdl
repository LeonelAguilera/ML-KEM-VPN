-- description: 
-- author:      Julia Müller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mlkem_types_pkg.all;

entity sample_poly_cbd is 
    generic (
        ETA : unsigned range 2 to 3
    );
    
    port (
        b : in  byte_array_t(0 to 64*ETA);
        f : out poly_t
    );
end entity sample_poly_cbd;

architecture parallel of sample_poly_cbd is
    signal bit_array : std_logic_vector(0 to 8*64*ETA);
begin
    bit_array <= bytestobits(b, 64*ETA);

end architecture parallel;