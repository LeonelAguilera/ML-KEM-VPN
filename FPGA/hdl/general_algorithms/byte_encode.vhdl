-- description: 
-- author:      Julia Müller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mlkem_types_pkg.all;

entity byte_encode is 
    generic (
        D : unsigned range 0 to 11
    );

    port (
        f : in  poly_t;
        b : out byte_array_t(0 to 32*D)
    );
end entity byte_encode;

architecture parallel of byte_encode is
begin
    process(all) is
    begin
        for index in 0 to 
    end process;
end architecture parallel;

-- entity byte_encode is 
--     generic (
--         D : unsigned range 0 to 11
--     );

--     port (
--         f : in  coeff_t;
--         b : out coeff_t
--     );
-- end entity byte_encode;

-- architecture serial of byte_encode is

-- end architecture serial;