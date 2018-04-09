library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

package RegDef is

constant opb : positive := 8;


-- skip register zero

constant XNOOP        : unsigned(opb-1 downto 0) := x"00"; -- register 0

-- load control registers


end RegDef;

package body RegDef is

end RegDef;
