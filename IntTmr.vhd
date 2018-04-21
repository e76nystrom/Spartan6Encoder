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

 component DownCounterOne is
  generic(n : positive);
  port (
   clk : in std_logic;
   ena : in std_logic;
   load : in std_logic;
   preset : in unsigned (n-1 downto 0);
   counter : inout  unsigned (n-1 downto 0);
   one : out std_logic);
 end component;

 component UpCounter is
  generic(n : positive);
  port (
   clk : in std_logic;
   clr : in std_logic;
   ena : in std_logic;
   counter : inout  unsigned (n-1 downto 0));
 end component;

 component CompareEq is
  generic (n : positive);
  port (
   a : in unsigned (n-1 downto 0);
   b : in unsigned (n-1 downto 0);
   cmp : out std_logic);
 end component;

 component DataSel2 is
  generic(n : positive);
  port ( sel : in std_logic;
         data0 : in unsigned (n-1 downto 0);
         data1 : in unsigned (n-1 downto 0);
         data_out : out unsigned (n-1 downto 0));
 end component;

 component Subtractor is
  generic (n : positive);
  port (
   clk : in std_logic;
   load : in std_logic;
   ena : in std_logic;
   a : in unsigned (n-1 downto 0);
   b : in unsigned (n-1 downto 0);
   diff : inout unsigned (n-1 downto 0));
 end component;

 component CompareLE is
  generic (n : positive);
  port (
   a : in  unsigned (n-1 downto 0);
   b : in  unsigned (n-1 downto 0);
   cmp : out std_logic);
 end component;

 signal initClear : std_logic;
 signal run : std_logic;

 -- cycle length register

 signal cycleLenShift : std_logic;      --shift into cycle len register
 signal intCycle : unsigned (cycleLenBits-1 downto 0); --cycle length value

 -- cycle length counter

 signal intCount : unsigned (cycleLenBits-1 downto 0); --cycle length counter
 signal intCountExt : unsigned (cycleClkBits-1 downto 0); --cycle length counter
 signal cycleDone : std_logic;

 -- clocks in cycle

 -- signal intClocks : unsigned (encClkBits-1 downto 0);

 -- counter for clocks in cycle

 -- signal intClkCtr : unsigned (encClkBits-1 downto 0);

 -- cycle clock counter

 signal intCtrLoad : std_logic;
 signal cycCalcUpd : std_logic;
 signal cycleClkClr : std_logic;
 signal cycleClkCtr : unsigned (cycleClkBits-1 downto 0);

 -- subtractor

 signal subASel : std_logic;
 signal subBSel : std_logic;
 signal subLoad: std_logic;
 signal subA : unsigned (cycleClkBits-1 downto 0);
 signal subB : unsigned (cycleClkBits-1 downto 0);
 signal cycleClkRem : unsigned (cycleClkBits-1 downto 0);

 -- comparator

 signal intClkUpd : std_logic;

begin

 cycleLenShift <= cycleSel and dshift;
 
 cycleLenReg: Shift                     --register for cycle length
  generic map(cycleLenBits)
  port map(
   clk => clk,
   shift => cycleLenShift,
   din => din,
   data => intCycle);
 
 intCtrLoad <= initClear or cycleDone or (not run);

 intCounter: DownCounterOne             --counter for cycle length
  generic map(cycleLenBits)
  port map(
   clk => clk,
   ena => intClkUpd,
   load => intCtrLoad,
   preset => intCycle,
   counter => intCount,
   one => cycleDone);

 cycleClkClr <= cycleDone or initClear or (not run);

 clkCtr: UpCounter
  generic map(cycleClkBits)
  port map(
   clk => clk,
   clr => cycleClkClr,
   ena => '1',
   counter => cycleClkCtr);

 subASel <= cycleDone or intClkUpd or initClear or (not run);

 dataSelA: DataSel2
  generic map(cycleClkBits)
  port map(
   sel => subASel,
   data0 => cycleClkRem,
   data1 => cycleClocks,
   data_out => subA);

 intCountExt <= (cycleClkBits-1 downto cycleLenBits => '0') & intCount;

 subBSel <= initClear or intClkUpd or (not run);

 dataSelB: DataSel2
  generic map(cycleClkBits)
  port map(
   sel => subBSel,
   data0 => intCountExt,
   data1 => cycleClkCtr,
   data_out => subB);

 subLoad <= initClear or (not run);

 cycRem: Subtractor
  generic map(cycleClkBits)
  port map (
   clk => clk,
   load => subLoad,
   ena => '1',
   a => subA,
   b => subB,
   diff => cycleClkRem);

 cmpLE: CompareLE
  generic map(cycleClkBits)
  port map(
   a => cycleClkRem,
   b => intCountExt,
   cmp => intClkUpd);

 int_process: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (init = '1') then                 --initialize variables
    initClear <= '1';
    run <= '0';
   else
    initClear <= '0';
    if (startInt = '0') and (run = '0') then
     run <= '1';
    elsif (cycleDone = '1') then
     run <= '0';
    end if;
    intClk <= intClkUpd or (not startInt and not run);
    setStartInt <= cycleDone;
   end if;
  end if;
 end process;

end Behavioral;

