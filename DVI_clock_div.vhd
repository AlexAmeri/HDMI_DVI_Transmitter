----------------------------------------------------------------------------------
-- CLOCK DIVIDER
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2019 02:41:30 AM
-- Design Name: 
-- Module Name: clock_div - Behavioral
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

entity clock_div_dvi is
    Port ( clk : in STD_LOGIC;
           div : out STD_LOGIC);
end clock_div_dvi;

architecture Behavioral of clock_div_dvi is
    signal counter : STD_LOGIC_VECTOR (26 downto 0) := (others => '0');
begin
    main : process (clk)
    begin  
        if (rising_edge(clk)) then
             --PRODUCED 25 MHz on a 125 MHz source
            -- Are we within one period?
            if (unsigned(counter) < 3) then
                 --increment the counter
                counter <= std_logic_vector(unsigned(counter) + 1);           
                div <= '0';
            elsif (unsigned(counter) = 3) then
                counter <= std_logic_vector(unsigned(counter) + 1);  
                div <= '1';  
            elsif (unsigned(counter) > 3) then
                counter <= (others => '0');
                div <= '0'; 
            else
                counter <= std_logic_vector(unsigned(counter) + 1);           
                div <= '0';
            end if;
        end if;
    end process;

end Behavioral;

