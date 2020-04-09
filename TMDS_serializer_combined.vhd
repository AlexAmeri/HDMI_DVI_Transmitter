----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2020 11:55:48 PM
-- Design Name: 
-- Module Name: tdms_serializer - Behavioral
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

entity tdms_serializer_combined is
    Port (
        data_red, data_green, data_blue : in std_logic_vector(9 downto 0);
        clk : in std_logic; 
        
        --Blue is 0, Green is 1, Red is 2
        TDMS_out, TDMS_out_not : out std_logic_vector (2 downto 0);
        new_character_clock : out std_logic;
        en : in std_logic
     );
end tdms_serializer_combined;

architecture Behavioral of tdms_serializer_combined is
    signal index : std_logic_vector(3 downto 0) := (others => '0');
    signal queueCounter : std_logic_vector(3 downto 0) := (others => '0');
    signal dataToSend : std_logic_vector(29 downto 0) := (others => '0');
    signal bitToSend_r, bitToSend_g, bitToSend_b : std_logic := '0';
    
    --FIFO Queue for clock domain crossing 
    --Needed because data is coming from a 125 MHz domain into
    --this 250 MHz domain.
    signal stage1 : std_logic_vector(29 downto 0) := (others => '0');
    
begin

    --Glue logic
    TDMS_out(0) <= bitToSend_b;
    TDMS_out_not(0) <= not bitToSend_b;
    TDMS_out(1) <= bitToSend_g;
    TDMS_out_not(1) <= not bitToSend_g;
    TDMS_out(2) <= bitToSend_r;
    TDMS_out_not(2) <= not bitToSend_r;


    --Main process
    main : process(clk) is
    begin
        if(rising_edge(clk)) then          
                --Move the pipeline along
                stage1 <= data_red & data_green & data_blue;         
                    
                --Load new data if the counter is at 0
                if(unsigned(index) = 0 and en = '1') then
                    dataToSend <= stage1;
                    bitToSend_b <= stage1(0);
                    bitToSend_g <= stage1(10);
                    bitToSend_r <= stage1(20);
                    
                    --Increment the counter
                    index <= std_logic_vector(unsigned(index) + 1);  
                end if;
                
                --Send data
                if(unsigned(index) > 0) then
                    --Increment the counter
                    index <= std_logic_vector(unsigned(index) + 1);  
                    
                    if(unsigned(index) < 9) then
                        bitToSend_b <= dataToSend(to_integer(unsigned(index)));
                        bitToSend_g <= dataToSend(to_integer(unsigned(index)) + 10);
                        bitToSend_r <= dataToSend(to_integer(unsigned(index)) + 20);                    
                    else
                        bitToSend_b <= dataToSend(to_integer(unsigned(index)));
                        bitToSend_g <= dataToSend(to_integer(unsigned(index)) + 10);
                        bitToSend_r <= dataToSend(to_integer(unsigned(index)) + 20);     
                        index <= (others => '0');
                    end if;
                end if;
            
                --Character clock 
                if(unsigned(index) < 5) then
                    new_character_clock <= '1';
                else
                    new_character_clock <= '0';
                end if;
            end if;    
    end process;

end Behavioral;
