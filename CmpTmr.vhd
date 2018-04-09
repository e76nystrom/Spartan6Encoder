----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:23:10 04/09/2018 
-- Design Name: 
-- Module Name:    CmpTmr - Behavioral 
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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CmpTmr is
 generic (cycleBits : positive := 16;
          tot_bits : positive := 32);
 port (
  clk : in std_logic;
  din : in std_logic;
  dshift : in std_logic;
  cycleSel: in std_logic
  );
end CmpTmr;

architecture Behavioral of CmpTmr is

 component Shift is
  generic(n : positive);
  port (
   clk : in std_logic;
   shift : in std_logic;
   din : in std_logic;
   data : inout unsigned (n-1 downto 0));
 end component;

begin

 cycleLenShift <= cycleSel and dshift;
 
 cycleLenReg: Shift
  generic map(phase_bits)
  port map (
   clk => clk,
   shift => phase_shift,
   din => din,
   data => phaseval);

end Behavioral;

