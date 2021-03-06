--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:34:36 01/24/2015 
-- Design Name: 
-- Module Name:    Divider - Behavioral 
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

entity Divider is
 generic (nBits : positive;
          dBits : positive;
          qBits : positive);
  port (
   clk : in std_logic;
   ena : in std_logic;
   done: out std_logic;
   n : in std_logic_vector(nBits-1 downto 0);
   d: in std_logic_vector(dBits-1 downto 0);
   q : out std_logic_vector(qBits-1 downto 0));
end Divider;

architecture Behavioral of Divider is

begin

 divProcess: process(clk)
 begin
  if (rising_edge(clk)) then
   if (ena = '1') then
    
   end if;
  end if;
 end process divProcess;

end Behavioral;
