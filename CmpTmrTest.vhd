--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:59:12 04/09/2018
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6Encoder/CmpTmrTest.vhd
-- Project Name:  Spartan6Encoder
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: CmpTmr
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

ENTITY CmpTmrTest IS
END CmpTmrTest;

ARCHITECTURE behavior OF CmpTmrTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component CmpTmr
  generic (cycleLenBits : positive;
           encClkBits : positive;
           cycleClkbits : positive);
  port(
   clk : IN  std_logic;
   din : IN  std_logic;
   dshift : IN  std_logic;
   init : IN  std_logic;
   ena : IN  std_logic;
   encClk : IN  std_logic;
   cycleSel : IN  std_logic;
   startInt : IN  std_logic;
   clrStartInt : OUT  std_logic;
   cycleClocks : INOUT  unsigned(cycleClkBits-1 downto 0)
   );
 end component;

 constant cycleLenBits : positive := 16;
 constant encClkBits : positive := 24;
 constant cycleClkbits : positive := 32;

 --Inputs
 signal clk : std_logic := '0';
 signal din : std_logic := '0';
 signal dshift : std_logic := '0';
 signal init : std_logic := '0';
 signal ena : std_logic := '0';
 signal encClk : std_logic := '0';
 signal cycleSel : std_logic := '0';
 signal startInt : std_logic := '0';

 --BiDirs
 signal cycleClocks : unsigned(31 downto 0);

 --Outputs
 signal clrStartInt : std_logic;

 -- Clock period definitions
 constant clk_period : time := 10 ns;
 
 signal tmp : signed(cycleLenBits-1 downto 0);

 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n loop
   wait until clk = '1';
   wait until clk = '0';
  end loop;
 end procedure delay;

 shared variable encCycle : integer;

BEGIN
 
 -- Instantiate the Unit Under Test (UUT)
 uut: CmpTmr
  generic map(cycleLenBits => cycleLenBits,
              encClkBits => encClkBits,
              cycleClkbits => cycleClkBits)
  port map (
   clk => clk,
   din => din,
   dshift => dshift,
   init => init,
   ena => ena,
   encClk => encClk,
   cycleSel => cycleSel,
   startInt => startInt,
   clrStartInt => clrStartInt,
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

  encCycle := 5;

  tmp <= to_signed(5, cycleLenBits);
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

  init <= '1';
  ena <= '0';

  delay(5);

  init <= '0';

  delay(5);

  ena <= '1';
  startInt <= '1';

  delay(10);

  for j in 0 to 40 loop
   encClk <= '1';
   delay(2);
   encClk <= '0';
   delay(10);
  end loop;

  wait;
 end process;

END;
