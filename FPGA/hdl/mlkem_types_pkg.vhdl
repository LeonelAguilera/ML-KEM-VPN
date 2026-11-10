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
  subtype   byte_t          is std_logic_vector(0 to 7);
  subtype   coeff_t         is unsigned(0 to 11);
  type      poly_t          is array (0 to MLKEM_N - 1) of coeff_t;
  type      byte_array_t    is array (natural range <>) of byte_t;

  -----------------------------------------------------------
  -- FUNCTIONS
  -----------------------------------------------------------
  function bytestobits(b_in: in byte_array_t(0 to l-1); l: in unsigned) return std_logic_vector;
  function bitstobytes(b_in: in std_logic_vector; l: in unsigned) return byte_array_t;

end package mlkem_types_pkg;

package body mlkem_types_pkg is

  function bytestobits(
    b_in: in byte_array_t(0 to l-1); 
    l: in natural
  ) return std_logic_vector is 
    variable b_out : std_logic_vector(0 to 8*l-1);
  begin
    for i in 0 to l-1 loop
        for j in 0 to 7 loop
            b_out(8*i + j) := b_in(i)(j);
        end loop;
    end loop;
    return b_out;
  end bytestobits;

  function bitstobytes(
    b_in: in std_logic_vector; 
    l: in natural
  ) return byte_array_t is
    variable b_out : byte_array_t(0 to l-1);
  begin
    assert (l mod 8 = 0)
      report "bitstobytes: Input length must be a multiple of 8"
      severity warning;

    b_out := (others => (others => '0'));

    for i in 0 to l-1 loop
        b_out(i / 8)(i mod 8) := b_in(i);
    end loop;

    return b_out;
  end bitstobytes;

end package body mlkem_types_pkg;