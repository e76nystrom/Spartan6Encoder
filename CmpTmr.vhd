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

 component UpCounterOne is
  generic(n : positive);
  port (
   clk : in std_logic;
   init : in std_logic;
   ena : in std_logic;
   counter : inout  unsigned (n-1 downto 0));
 end component;

 component UpCounterLoad is
  generic(n : positive);
  port (
   clk : in std_logic;
   clr : in std_logic;
   load : in std_logic;
   inc : in std_logic;
   preset : in  unsigned (n-1 downto 0);
   counter : inout unsigned (n-1 downto 0));
 end component;

 component AccumPlusClr is
  generic(n : positive);
  port (
   clk : in std_logic;
   clr : in std_logic;
   ena : in std_logic;
   a : in unsigned (n-1 downto 0);
   sum : inout unsigned (n-1 downto 0));
 end component;

 component multiplier is
  port (
   clk : in std_logic;
   ce : in std_logic;
   a : in std_logic_vector(15 downto 0);
   b : in std_logic_vector(23 downto 0);
   p : out std_logic_vector(31 downto 0));
 end component;

 component AdderTwoInp is
  generic(n : positive := 32);
  port (
   clk : in std_logic;
   clr : in std_logic;
   ena : in std_logic;
   a : in unsigned (n-1 downto 0);
   b : in unsigned (n-1 downto 0);
   sum : out unsigned (n-1 downto 0));
  end component;

 -- enable state machine

 type enaFSM is (waitEna, waitEnc, run);
 signal enaState : enaFSM := waitEna;

 -- control signals from enable state machine

 signal clkCtrEna : std_logic;          --clock counter enable

 -- cmp statue machine

 type fsm is (idle, cycleCalc, cycEndChk, cycleEnd);
 signal state : fsm := idle;

 -- control signals from state machine

 signal initClear : std_logic;          --initialization clear
 signal encPulseUpd : std_logic;        --encoder pulse update
 signal cycCalcUpd : std_logic;         --cycle calculation update
 signal cycChkUpd : std_logic;          --cycle check update
 signal cycDoneUpd : std_logic;         --cycle done update
 signal cycEndUpd : std_logic;          --cycle end update

 -- cycle length register

 signal cycleLenShift : std_logic;      --shift into cycle len register
 signal encCycle : unsigned(cycleLenBits-1 downto 0); --cycle length value

 -- cycle length counter

 signal loadCycCtr : std_logic;         --load cycle counter
 signal cycleDone : std_logic;          --encoder cycle done
 signal encCount : unsigned(cycleLenBits-1 downto 0); --cycle length counter

 -- clock up counter

 signal clkCtrClr : std_logic;          --clock counter clear
 signal clockCounter : unsigned(encClkBits-1 downto 0); --clock counter

 -- encoder clocks

 signal encoderClocks : unsigned(encClkBits-1 downto 0); --encoder clocks reg

 -- counters and register for clock counting

 signal clrClockTotal : std_logic;      --clear clock accumulator
 signal clockTotal : unsigned(cycleClkBits-1 downto 0);  --clock accumulator
 signal encClksExt : unsigned(cycleClkBits-1 downto 0);  --enc clks extended
  
 -- multiplier

 signal encCntCLks : std_logic_vector(cycleClkBits-1 downto 0); --mult output

begin

 cycleLenShift <= cycleSel and dshift;
 
 cycleLenReg: Shift                     --register for cycle length
  generic map(cycleLenBits)
  port map(
   clk => clk,
   shift => cycleLenShift,
   din => din,
   data => encCycle);

 loadCycCtr <= initClear or cycDoneUpd;

 encCounter: DownCounter                --counter to count down cycle length
  generic map(cycleLenBits)
  port map(
   clk => clk,
   ena => cycCalcUpd,
   load => loadCycCtr,
   preset => encCycle,
   counter => encCount,
   zero => cycleDone);

 clkCtrClr <= initClear or encPulseUpd;
 
 encClkCtr: UpCounterOne            	--count clocks between encoder pulses
 generic map(encClkBits)
  port map(
   clk => clk,
   init => clkCtrClr,
   ena => clkCtrEna,
   counter => clockCounter);

 encClks: UpCounterLoad                 --register for clock counts
  generic map(encClkBits)
  port map(
   clk => clk,
   clr => initClear,
   load => encPulseUpd,
   inc => '0',
   preset => clockCounter,
  counter => encoderClocks);

 encClksExt <= (cycleClkBits-1 downto encClkBits => '0') & encoderClocks;
 clrClockTotal <= initClear or cycEndUpd;

 clockAccum: AccumPlusClr               --accumulate clock count
  generic map(cycleClkBits)
  port map(
   clk => clk,
   clr => clrClockTotal,
   ena => cycCalcUpd,
   a => encClksExt,
   sum => clockTotal);

 clockMult: multiplier                  --multiply encoder count encoder clocks
  port map(
   clk => clk,
   ce => cycCalcUpd,
   a => std_logic_vector(encCount),
   b => std_logic_vector(encoderClocks),
   p => encCntClks);

 cycleClockAdder: AdderTwoInp           --cycle counter
  generic map(cycleClkBits)
  port map(
   clk => clk,
   clr => initClear,
   ena => cycChkUpd,
   a => clockTotal,
   b => unsigned(encCntClks),
   sum => cycleClocks);

 ena_process: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (init = '1') then                 --initialize variables
    initClear <= '1';                   --perform initialization clear
    clkCtrEna <= '0';                   --disable clock counter
    enaState <= waitEna;                --wait for enable
   else
    case enaState is                    --select state
     when  waitEna =>                   --wait for enable
      if (ena = '1') then               --if enabled
       enaState <= waitEnc;             --wait for encoder pulse
      end if;

     when  waitEnc =>                   --wait for encoder
      initClear <= '0';                 --initialization done
      if (encClk = '1') then            --if encoder pulse
       enaState <= run;                 --run
      end if;

     when  run =>                       --run
      if (ena = '0') then               --if enabled cleared
       clkCtrEna <= '0';                --disable counting
       initClear <= '1';                --perform initialzation clear
       enaState <= waitEna;             --wait for enable
      else
       clkCtrEna <= '1';                --enable clock counter
      end if;

    end case;
   end if;
  end if;
 end process;

 cmp_process: process(clk)
 begin
  if (rising_edge(clk)) then            --if clock active
   if (init = '1') then                 --initialize variables
    clrStartInt <= '0';
    encPulseUpd <= '0';
    cycCalcUpd <= '0';
    cycChkUpd <= '0';
    cycDoneUpd <= '0';
    cycEndUpd <= '0';
    state <= idle;                      --set to idle
   else
    if (clkCtrEna = '1') then           --if clock counter enabled
     case state is                      --select state
      when idle =>                      --idle
       cycChkUpd <= '0';
       cycEndUpd <= '0';
       if (encClk = '1') then           --if encoder clock
        encPulseUpd <= '1';
        state <= cycleCalc;             --update tick
       end if;

      when cycleCalc =>                 --calc cycle length
       encPulseUpd <= '0';
       cycCalcUpd <= '1';
       state <= cycEndChk;              --return to idle state

      when cycEndChk =>                 --cycle end check
       cycCalcUpd <= '0';
       if (cycleDone = '1') then        --if cycle done
        cycDoneUpd <= '1';
        if (startInt = '1') then        --if time to start output
         clrStartInt <= '1';            --clear start flag
        end if;
        state <= cycleEnd;              --end of cycle processing
       else                             --if not done
        cycChkUpd <= '1';
        state <= idle;             	--return to idle
       end if;

      when cycleEnd =>                  --end of cycle
       cycDoneUpd <= '0';
       cycEndUpd <= '1';
       clrStartInt <= '0';              --disable start clear
       state <= idle;                   --return to idle state

     end case;
    end if;
   end if;
  end if;
 end process;

end Behavioral;

