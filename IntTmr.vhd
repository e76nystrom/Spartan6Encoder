----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:59:58 04/13/2018 
-- Design Name: 
-- Module Name:    IntTmr - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity IntTmr is
 generic (cycleLenBits : positive := 16;
          encClkBits : positive := 24;
          cycleClkbits : positive := 32);
 port (
  clk : in std_logic;                   --system clock

  din : in std_logic;                   --spi data in
  dshift : in std_logic;                --spi shift in
  init : in std_logic;                  --init signal
  ena : in  std_logic;                  --enable signal
  intClk : out std_logic;               --output clock
  cycleSel : in std_logic;              --cycle length register select
  startInt : in std_logic;              --start internal timer flag
  setStartInt : out std_logic;          --set start internal timer flag
  cycleClocks: in unsigned (cycleClkBits-1 downto 0) --cycle counter
  );
end IntTmr;

architecture Behavioral of IntTmr is

 component Shift is
  generic(n : positive);
  port (
   clk : in std_logic;
   shift : in std_logic;
   din : in std_logic;
   data : inout unsigned (n-1 downto 0));
 end component;

 component DownCounter is
  generic(n : positive);
  port (
   clk : in std_logic;
   ena : in std_logic;
   load : in std_logic;
   preset : in unsigned (n-1 downto 0);
   counter : inout  unsigned (n-1 downto 0);
   zero : out std_logic);
 end component;

 component div_gen_v4_0 is
  port (
   aclk : in std_logic := 'X'; 
   s_axis_divisor_tvalid : in std_logic := 'X'; 
   s_axis_dividend_tvalid : in std_logic := 'X'; 
   s_axis_divisor_tready : out std_logic; 
   s_axis_dividend_tready : out std_logic; 
   m_axis_dout_tvalid : out std_logic; 
   s_axis_divisor_tdata : in std_logic_vector( 15 downto 0 ); 
   s_axis_dividend_tdata : in std_logic_vector( 31 downto 0 ); 
   m_axis_dout_tdata : out std_logic_vector( 31 downto 0 ) 
   );
 end component;

 -- int statue machine

 type fsm is (idle, start, chkCycCtr, calcPer0, calcPer1)
 signal state : fsm := idle;

 -- cycle length register

 signal cycleLenShift : std_logic;      --shift into cycle len register
 signal intCycle : unsigned(cycleLenBits-1 downto 0); --cycle length value

 -- cycle length counter

 signal loadCycCtr : std_logic;         --load cycle counter
 signal cycleDone : std_logic;          --encoder cycle done
 signal intCount : unsigned(cycleLenBits-1 downto 0); --cycle length counter

begin

 cycleLenShift <= cycleSel and dshift;
 
 cycleLenReg: Shift                     --register for cycle length
  generic map(cycleLenBits)
  port map(
   clk => clk,
   shift => cycleLenShift,
   din => din,
   data => intCycle);

 clkCtrClr <= initClear or encPulseUpd;

 intCounter: DownCounter                --counter for cycle length
  generic map(cycleLenBits)
  port map(
   clk => clk,
   ena => cycCalcUpd,
   load => loadCycCtr,
   preset => intcCycle,
   counter => intCount,
   zero => cycleDone);

  int_process: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (init = '1') then                 --initialize variables
   else
   case state is                        --select state
    when idle =>                        --idle

    when start =>                       --wait for staryt

    when chkCycCtr =>                   --check cycle counter

    when calcPer0 =>                    --calculate period part1

    when calcPer1 =>                    --calculate period part2
     
   end case;
  end if;
 end process;

end Behavioral;

