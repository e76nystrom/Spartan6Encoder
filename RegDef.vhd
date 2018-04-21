library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package RegDef is

constant opb : positive := 8;
constant opBits : positive := 8;

-- skip register zero

constant XNOOP        : unsigned(opb-1 downto 0) := x"00"; -- register 0

constant XLDENCCYCLE : unsigned (opBits-1 downto 0) := x"01";
constant XLDINTCYCLE : unsigned (opBits-1 downto 0) := x"02";
constant XLDCTL : unsigned (opBits-1 downto 0) := x"03";

end RegDef;

package body RegDef is

end RegDef;
