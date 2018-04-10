--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:34:36 01/24/2015 
-- Design Name: 
-- Module Name:    Multiplier - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Multiplier is
  port (
   clk : in std_logic;
   a : in std_logic_vector(15 downto 0);
   b : in std_logic_vector(23 downto 0);
   ce : in std_logic;
   p : out std_logic_vector(31 downto 0));
end Multiplier;

architecture Behavioral of Multiplier is

begin

 multiplier: process(clk)
 begin
  if (rising_edge(clk)) then
   if (ce = '1') then
    p <= std_logic_vector(unsigned(a) * unsigned(b));
   end if;
  end if;
 end process multiplier;

end Behavioral;
