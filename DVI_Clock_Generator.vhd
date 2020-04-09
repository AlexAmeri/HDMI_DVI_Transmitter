----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2020 12:58:19 AM
-- Design Name: 
-- Module Name: DVI_Clock_Generator - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DVI_Clock_Generator is
  Port (
        reset : in std_logic;
        base_clk : in std_logic;                --125 MHz base clock
        out_clk_base : out std_logic;           --125 MHz base clock, phase matched to 250 MHz clock
        out_clk_serializer : out std_logic;     --250 MHz serializer clock
        out_clk_en : out std_logic              --25 MHZ clock enable chirp, phase matched to 250 MHz clock
   );
end DVI_Clock_Generator;

architecture Behavioral of DVI_Clock_Generator is

    --Components
    --Fast clock generator
    component serializer_clock is
    Port (
        clk_out1 : out std_logic;
        reset : in std_logic;
        locked : out std_logic;
        clk_in1 : in std_logic
     );
    end component;
    
    --Clock Enable
    component clock_div_dvi is
        Port ( clk : in STD_LOGIC;
           div : out STD_LOGIC);
    end component;
    
    --Signals
    signal fast_clock, new_base_clk : std_logic;
    signal counter : STD_LOGIC_VECTOR (1 downto 0) := "01";
       
begin
    --Glue logic
    new_base_clk <= counter(0);
    out_clk_base <= new_base_clk;
    out_clk_serializer <= fast_clock;

    --Fast clock generator
    serial_clock_gen : serializer_clock port map(
        clk_out1 => fast_clock,
        reset => reset,
        clk_in1 => base_clk
    );

    --Clock divider 1 to 2 process
    clock_divider : process(fast_clock)
    begin
        if(rising_edge(fast_clock)) then
            counter <= std_logic_vector(unsigned(counter) ror 1);
        end if;
    end process;
    
    --Clock enable
    clock_enable_gen : clock_div_dvi port map(
        clk => new_base_clk,
        div => out_clk_en
    );
    
end Behavioral;
