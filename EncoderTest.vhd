--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:20:29 04/19/2018
-- Design Name:   
-- Module Name:   C:/Development/Xilinx/Spartan6Encoder/EncoderTest.vhd
-- Project Name:  Spartan6Encoder
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Encoder
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
 
ENTITY EncoderTest IS
END EncoderTest;
 
ARCHITECTURE behavior OF EncoderTest IS 
 
 -- Component Declaration for the Unit Under Test (UUT)
 
 component Encoder
  port(
   sysClk : in  std_logic;
   sw1 : in  std_logic;
   sw0 : in  std_logic;
   sw2 : in  std_logic;
   sw3 : in  std_logic;
   led : out  std_logic_vector(7 downto 0);
   j1_p04 : out  std_logic;
   j1_p06 : out  std_logic;
   j1_p08 : out  std_logic;
   j1_p10 : out  std_logic;
   j1_p12 : in  std_logic;
   j1_p14 : out  std_logic;
   j1_p16 : in  std_logic;
   j1_p18 : in  std_logic;
   jc1 : out  std_logic;
   jc2 : in  std_logic;
   jc3 : in  std_logic;
   jc4 : in  std_logic
   );
 end component;

 --Inputs
 signal sysClk : std_logic := '0';
 signal sw1 : std_logic := '0';
 signal sw0 : std_logic := '0';
 signal sw2 : std_logic := '0';
 signal sw3 : std_logic := '0';
 signal j1_p12 : std_logic := '0';
 signal j1_p16 : std_logic := '0';
 signal j1_p18 : std_logic := '0';
 signal jc2 : std_logic := '0';
 signal jc3 : std_logic := '0';
 signal jc4 : std_logic := '0';

 --Outputs
 signal led : std_logic_vector(7 downto 0);
 signal j1_p04 : std_logic;
 signal j1_p06 : std_logic;
 signal j1_p08 : std_logic;
 signal j1_p10 : std_logic;
 signal j1_p14 : std_logic;
 signal jc1 : std_logic;

 -- Clock period definitions
 constant sysClk_period : time := 10 ns;
 
 alias dclk : std_logic is j1_p12;
 alias dout : std_logic is j1_p14;
 alias din : std_logic is j1_p16;
 alias dsel : std_logic is j1_p18;

 -- dclk <= jb1;
 -- jb2  <= dout;
 -- din  <= jb3;
 -- dsel <= jb4;
 
 procedure delay(constant n : in integer) is
 begin
  for i in 0 to n-1 loop
   wait until sysClk = '1';
   wait until sysClk = '0';
  end loop;
 end procedure delay;

 constant cycleLenBits : positive := 16;
 constant encClkBits : positive := 24;
 constant cycleClkBits : positive := 32;

 constant encCycle : positive := 5;
 constant intCycle : unsigned(cycleLenBits-1 downto 0) := to_unsigned(4, cycleLenBits);

 shared variable op : integer;
 constant opb : positive := 8;

-- constant XLDENCCYCLE : unsigned(opb-1 downto 0) := x"01";
 constant XLDENCCYCLE : unsigned(opb-1 downto 0) := x"55";
 constant XLDINTCYCLE : unsigned(opb-1 downto 0) := x"02";

 signal parmIdx : unsigned(opb-1 downto 0) :=  (opb-1 downto 0 => '0');
 signal parmVal : unsigned(cycleLenBits-1 downto 0) :=
  (cycleLenBits-1 downto 0 => '0');

begin
 
 -- Instantiate the Unit Under Test (UUT)

 uut: Encoder
  port map (
   sysClk => sysClk,
   sw1 => sw1,
   sw0 => sw0,
   sw2 => sw2,
   sw3 => sw3,
   led => led,
   j1_p04 => j1_p04,
   j1_p06 => j1_p06,
   j1_p08 => j1_p08,
   j1_p10 => j1_p10,
   j1_p12 => j1_p12,
   j1_p14 => j1_p14,
   j1_p16 => j1_p16,
   j1_p18 => j1_p18,
   jc1 => jc1,
   jc2 => jc2,
   jc3 => jc3,
   jc4 => jc4
   );

 -- Clock process definitions

 sysClk_process : process
 begin
  sysClk <= '0';
  wait for sysClk_period/2;
  sysClk <= '1';
  wait for sysClk_period/2;
 end process;
 
 -- Stimulus process

 stim_proc : process
 begin		
  dsel <= '1';
  -- hold reset state for 100 ns.
  wait for 100 ns;	

  wait for sysClk_period*10;

  -- insert stimulus here

  parmIdx <= XLDENCCYCLE;
  parmVal <= to_unsigned(encCycle, cycleLenBits);

  dsel <= '0';
  delay(10);

  for i in 0 to opb-1 loop
   dclk <= '0';
   din <= parmIdx(opb-1);
   parmIdx <= shift_left(parmIdx, 1);
   delay(8);
   dclk <= '1';
   delay(8);
  end loop;

  delay(10);
  parmIdx <= XLDINTCYCLE;

  for i in 0 to cycleLenBits-1 loop
   dclk <= '0';
   din <= parmVal(cycleLenBits-1);
   parmVal <= shift_left(parmVal, 1);
   delay(8);
   dclk <= '1';
   delay(8);
  end loop;

  dsel <= '1';

  wait;
 end process;

end;
