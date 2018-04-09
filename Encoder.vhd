--------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:59:16 04/24/2015 
-- Design Name: 
-- Module Name:    Encoder - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity Encoder is
 Port (
  sysClk : in std_logic;
  
  sw1 : in std_logic;
  sw0 : in std_logic;
  sw2 : in std_logic;
  sw3 : in std_logic;
  
  led : out std_logic_vector(7 downto 0);

  j1_p04 : out std_logic;
  j1_p06 : out std_logic;
  j1_p08 : out std_logic;
  j1_p10 : out std_logic;

  j1_p12 : in std_logic;
  j1_p14 : out std_logic;
  j1_p16 : in std_logic;
  j1_p18 : in std_logic
  );
end Encoder;

architecture Behavioral of Encoder is

 component latheClk is
  port (
   CLK_IN           : in     std_logic;
   CLK_OUT          : out    std_logic;
   RESET            : in     std_logic;
   LOCKED           : out    std_logic
   );
 end component;

 component SPI
  generic (op_bits : positive := 8);
  port (
   clk : in std_logic;
   dclk : in std_logic;
   dsel : in std_logic;
   din : in std_logic;
   op : inout unsigned(op_bits-1 downto 0);
   copy : out std_logic;
   shift : out std_logic;
   load : out std_logic;
   header : inout std_logic
   );
 end component;

 alias ja1 : std_logic is j1_p04;
 alias ja2 : std_logic is j1_p06;
 alias ja3 : std_logic is j1_p08;
 alias ja4 : std_logic is j1_p10;

 alias jb1 : std_logic is j1_p12;
 alias jb2 : std_logic is j1_p14;
 alias jb3 : std_logic is j1_p16;
 alias jb4 : std_logic is j1_p18;

 -- spi interface signals

 signal dclk : std_logic;               --data clock
 signal din : std_logic;                --data in mosi
 signal dsel : std_logic;               --select line
 signal dout : std_logic;               --data out miso

 -- system clock

 signal clk1 : std_logic;
 signal locked : std_logic;

 -- clock divider

 constant div_range : integer := 26;
 signal div : unsigned(div_range downto 0);

 -- spi interface

 constant opb : positive := 8;

 constant out_bits : positive := 32;
 signal copy : std_logic;               --copy to output register
 signal dshift : std_logic;             --shift data
 signal load : std_logic;               --load to register
 signal op : unsigned(opb-1 downto 0);  --operation code
 signal outReg : unsigned(out_bits-1 downto 0); --output register
 signal header : std_logic;

begin

 led(7) <= locked;
 led(6) <= div(div_range);
 led(5) <= div(div_range-1);
 led(4) <= div(div_range-2);
 led(3) <= not sw3;
 led(2) <= not sw2;
 led(1) <= not sw1;
 led(0) <= not sw0;

 ja1 <= div(div_range-3);
 ja2 <= div(div_range-4);
 -- ja3 <= div(div_range-5);
 -- ja4 <= div(div_range-6);

 ja3 <= header;
 ja4 <= load;

 dclk <= jb1;
 jb2  <= dout;
 din  <= jb3;
 dsel <= jb4;

 -- system clock

 sys_Clk: latheClk
  port map (
   CLK_IN  => sysClk,
   CLK_OUT => clk1,
   RESET    => '0',
   LOCKED   => locked
   );

 -- clock divider

 clk_div: process(clk1)
 begin
  if (rising_edge(clk1)) then
   div <= div + 1;
  end if;
 end process;

 -- spi interface

 spi_int : SPI
  generic map (op_bits => opb)
  port map (
   clk => clk1,
   dclk => dclk,
   dsel => dsel,
   din => din,
   op => op,
   copy => copy,
   shift => dshift,
   load => load,
   header => header
   --info => spiInfo
   );

 -- spi return data

 dout <= outReg(out_bits-1);

 outReg_proc : process(clk1)
 begin
  if (rising_edge(clk1)) then
--   if (copy = '1') or ((dspUpd = '1') and (dsel = '1')) then
   if (copy = '1') then
    case op is
     when x"00" => 
      outReg <= (out_bits-1 downto 0 => '0');
     when others =>
      outReg <= x"55aa55aa";
    end case;
   else
    if (dshift = '1') then
     outReg <= outReg(out_bits-2 downto 0) & outReg(out_bits-1);
    end if;
   end if;
  end if;
 end process;

 
end Behavioral;

