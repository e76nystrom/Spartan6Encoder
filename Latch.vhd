--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:34:36 01/24/2015 
-- Design Name: 
-- Module Name:    Latch - Behavioral 
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

entity Latch is
 generic (n0 : positive;
          n1 : positive);
 port (
  clk : in std_logic;
  clr : in std_logic;
  ena : in std_logic;
  input : in unsigned (n0-1 downto 0);
  latch : out unsigned (n1-1 downto 0));
end Latch;

architecture Behavioral of Latch is

begin

 latchProc: process(clk)
 begin
  if (rising_edge(clk)) then
   if (clr = '1') then
    latch <= (n1-1 downto 0 => '0');
   else
    if (ena = '1') then
     latch <= input(n1-1 downto 0);
    end if;
   end if;
  end if;
 end process latchProc;

end Behavioral;
