library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package mlkem_types_pkg is
  
  -----------------------------------------------------------
  -- CONSTANTS 
  -----------------------------------------------------------
  constant MLKEM_Q     : positive := 3329;
  constant MLKEM_N     : positive := 256;

  -----------------------------------------------------------
  -- TYPES
  -----------------------------------------------------------
  subtype   byte_t      is std_logic_vector(0 to 7);
  subtype   coeff_t     is unsigned(11 downto 0);
  type      poly_t      is array (0 to MLKEM_N - 1) of coeff_t;

end package mlkem_types_pkg;