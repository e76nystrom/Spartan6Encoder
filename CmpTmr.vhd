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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CmpTmr is
 generic (cycleLenBits : positive := 16;
          encClkBits : positive := 24;
          cycleClkbits : positive := 32);
 port (
  clk : in std_logic;                   --system clock
  din : in std_logic;                   --spi data in
  dshift : in std_logic;                --spi shift signal
  init : in std_logic;                  --init signal
  ena : in std_logic;                   --enable input
  encClk : in std_logic;                --encoder clock
  cycleSel: in std_logic;               --cycle length register select
  startInt: in std_logic;               --start internal timer flag
  clrStartInt: out std_logic;           --clear start timer
  cycleClocks: inout unsigned (cycleClkBits-1 downto 0) --cycle counter
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

 component UpCounter is
  generic(n : positive);
  port (
   clk : in std_logic;
   clr : in std_logic;
   ena : in std_logic;
   counter : inout  unsigned (n-1 downto 0));
 end component;

 component AccumPlusClr is
  generic (n : positive);
  port ( clk : in std_logic;
         ena : in std_logic;
         clr : in std_logic;
         a : in unsigned (n-1 downto 0);
         sum : inout unsigned (n-1 downto 0));
 end component;

 component multiplier is
  port (
   clk : in std_logic;
   a : in std_logic_vector(15 downto 0);
   b : in std_logic_vector(23 downto 0);
   ce : in std_logic;
   p : out std_logic_vector(31 downto 0));
 end component;

 type fsm is (idle, tickUpd, cycEndchk, calcCyc, endCyc);
 signal state : fsm := idle;

 -- cycle length register

 signal cycleLenShift : std_logic;      --shift into cycle len register
 signal encCycle : unsigned(cycleLenBits-1 downto 0); --cycle length value

 -- cycle length counter

 signal updLenCount : std_logic;        --update cycle length
 signal loadCycCtr : std_logic;         --load cycle counter
 signal cycleDone : std_logic;          --encoder cycle done
 signal encCount : unsigned(cycleLenBits-1 downto 0); --cycle length counter

 -- clock up counter

 signal cycCtrClr : std_logic;          --cycle counter clear
 signal clockCounter : unsigned(encClkBits-1 downto 0); --clock counter

 -- counters and register for clock counting

 signal clrClockTotal : std_logic;      --clear clock accumulator
 signal accumClocks : std_logic;        --add encoder clocks to total
 signal encoderClocks : unsigned(encClkBits-1 downto 0); --encoder clocks reg
 signal clockTotal : unsigned(cycleClkBits-1 downto 0);  --clock accumulator
 signal tmp0 : unsigned(cycleClkBits-1 downto 0);
  
 -- multiplier

 signal multEna : std_logic;            --enable multiplier
 signal tmp : std_logic_vector(cycleClkBits-1 downto 0); --multiplier output
 -- signal tmp : unsigned(39 downto 0); --multiplier output

begin

 cycleLenShift <= cycleSel and dshift;
 
 cycleLenReg: Shift                     --register for cycle length
  generic map(cycleLenBits)
  port map(
   clk => clk,
   shift => cycleLenShift,
   din => din,
   data => encCycle);

 encCounter: DownCounter                --counter to count down cycle lenght
  generic map(cycleLenBits)
  port map(
   clk => clk,
   ena => updLenCount,
   load => loadCycCtr,
   preset => encCycle,
   counter => encCount,
   zero => cycleDone);

 cycCounter: UpCounter                  --up counter for clocks
  generic map(encClkBits)
  port map(
   clk => clk,
   clr => cycCtrClr,
   ena => ena,
   counter => clockCounter);

 tmp0 <= (cycleClkBits-1 downto encClkBits => '0') & clockCounter;

 clockAccum: AccumPlusClr
  generic map(cycleClkBits)
  port map(
   clk => clk,
   ena => accumClocks,
   clr => clrClockTotal,
   a => tmp0,
   sum => clockTotal);

 clockMult: multiplier
  port map(
   clk => clk,
   a => std_logic_vector(encCount),
   b => std_logic_vector(encoderClocks),
   ce => multEna,
   p => tmp);

 cmp_process: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (init = '1') then                 --initialize variables
    clrStartInt <= '0';                 --set clear line to inactive
    cycCtrClr <= '1';                   --clear cycle counter
    loadCycCtr <= '1';                  --load cycle counter
    clrClockTotal <= '1';               --initialize clock total
    cycleClocks <= (cycleClkBits-1 downto 0 => '0'); --clear cycle clocks
    state <= idle;                      --set to idle
   else
    loadCycCtr <= '0';                  --clear load signal
    clrClockTotal <= '0';               --release clear signal
    case state is                       --select state
     when idle =>                       --idle
      if (ena = '1') then               --if enabled
       if (encClk = '1') then           --if encoder clock
        accumClocks <= '1';             --accumulate clocks
        encoderClocks <= clockCounter;  --copy clock counter
        cycCtrClr <= '1';               --clear counter
        updLenCount <= '1';             --update cycle length count
        state <= tickUpd;               --update tick
       else
         cycCtrClr <= '0';              --release clear
       end if;
      end if;

     when tickUpd =>                    --tick update
      accumClocks <= '0';               --clear accumulate flag
      cycCtrClr <= '0';                 --release clear
      updLenCount <= '0';               --clear update
      state <= cycEndChk;               --check for end

     when cycEndChk =>                  --cycle end check
      if (cycleDone = '1') then         --if cycle done
       loadCycCtr <= '1';               --load cycle counter
       clrClockTotal <= '1';            --clear the clock total
       if (startInt = '1') then         --if time to start output
        clrStartInt <= '1';             --clear start flag
       end if;
       state <= endCyc;                 --end of cycle processing
      else                              --if not done
       -- tmp <= encCount * encoderClocks;
       multEna <= '1';                  --start multiply
        
       state <= calcCyc;             	--update cycle length
      end if;

     when calcCyc =>                    --calc cycle length
      loadCycCtr <= '0';                --release clear signal
      multEna <= '0';                   --end multiply
      cycleClocks <= clockTotal + unsigned(tmp); --update cycle clocks
      -- cycleClocks <= clockTotal + tmp(31 downto 0); --update cycle clocks
      state <= idle;                    --return to idle state

     when endCyc =>                     --end of cycle
      loadCycCtr <= '0';                --release clear signal
      clrClockTotal <= '0';             --disable clock clear total
      clrStartInt <= '0';               --disable start clear
      state <= idle;                    --return to idle state

    end case;
   end if;
  end if;
 end process;

end Behavioral;

