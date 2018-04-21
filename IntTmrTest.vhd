--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   07:53:15 04/19/2018
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6Encoder/IntTmrTest.vhd
-- Project Name:  Spartan6Encoder
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IntTmr
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY IntTmrTest IS
END IntTmrTest;

ARCHITECTURE behavior OF IntTmrTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 COMPONENT IntTmr
  generic (cycleLenBits : positive;
   encClkBits : positive;
   cycleClkbits : positive);
  PORT(
   clk : IN  std_logic;
   din : IN  std_logic;
   dshift : IN  std_logic;
   init : IN  std_logic;
   intClk : out  std_logic;
   cycleSel : IN  std_logic;
   startInt : IN  std_logic;
   setStartInt : OUT  std_logic;
   cycleClocks : IN  unsigned(cycleClkBits-1 downto 0)
   );
 END COMPONENT;
 
 constant cycleLenBits : positive := 16;
 constant encClkBits : positive := 24;
 constant cycleClkbits : positive := 32;

 constant cycleCount : positive := 10;
 constant cycleLen : positive := 105;
 constant intCycle : positive := 10;

 constant counterBits : positive := 8;

 --Inputs
 signal clk : std_logic := '0';
 signal din : std_logic := '0';
 signal dshift : std_logic := '0';
 signal init : std_logic := '0';
 signal cycleSel : std_logic := '0';
 signal startInt : std_logic := '0';
 signal cycleClocks : unsigned(cycleClkBits-1 downto 0) := (others => '0');

 --Outputs
 signal intClk : std_logic;
 signal setStartInt : std_logic;

 -- Clock period definitions
 constant clk_period : time := 10 ns;
 constant intClk_period : time := 10 ns;
 
 signal tmp : signed(cycleLenBits-1 downto 0);

 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n-1 loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

 signal clks : unsigned(counterBits-1 downto 0);
 signal cycles : unsigned(counterBits-1 downto 0);

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: IntTmr
    generic map(cycleLenBits => cycleLenBits,
              encClkBits => encClkBits,
              cycleClkbits => cycleClkBits)
  PORT MAP (
  clk => clk,
  din => din,
  dshift => dshift,
  init => init,
  intClk => intClk,
  cycleSel => cycleSel,
  startInt => startInt,
  setStartInt => setStartInt,
  cycleClocks => cycleClocks
  );

 -- Clock process definitions
 clk_process :process
 begin
  clk <= '0';
  wait for clk_period/2;
  clk <= '1';
  wait for clk_period/2;
 end process;
 
  -- Stimulus process
 stim_proc: process
 begin		
  -- hold reset state for 100 ns.
  wait for 100 ns;	

  wait for clk_period*10;

  -- insert stimulus here 

  delay(5);

  init <= '0';

  cycleClocks <= to_unsigned(cycleLen-1, cycleClkBits);

  tmp <= to_signed(intCycle, cycleLenBits);
  cycleSel <= '1';
  dshift <= '1';
  for i in 0 to cycleLenBits loop
   wait until clk = '1';
   din <= tmp(cycleLenBits - 1);
   tmp <= shift_left(tmp, 1);
   wait until clk = '0';
  end loop;
  dshift <= '0';
  cycleSel <= '0';

  delay(5);

  init <= '1';

  delay(5);

  init <= '0';  
  startInt <= '1';

  delay(5);

  cycles <= to_unsigned(0, counterBits);
  for i in 0 to cycleCount-1 loop
   clks <= to_unsigned(0, counterBits);
   startInt <= '0';
   for j in 0 to cycleLen-1 loop
    if (setStartInt = '1') then
     startInt <= '1';
    end if;
    delay(1);
    clks <= clks + to_unsigned(1, counterBits);
   end loop;
   cycles <= cycles + to_unsigned(1, counterBits);
  end loop;

  wait;
 end process;

END;
