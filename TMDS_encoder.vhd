----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/27/2020 09:28:49 PM
-- Design Name: 
-- Module Name: vga_to_hdmi - Behavioral
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

entity tdmi_transmitter is
    Port ( --Control signals shared with VGA logic
           clk, en : in STD_LOGIC;
           
           --HDMI Control signals
           CTL : in std_logic_vector(1 downto 0);
           DE : in std_logic;
           
           --Data input
           dc : in std_logic_vector(7 downto 0);
           
           --Serial Data output
           TDMI_output : out std_logic_vector(9 downto 0)
           );
end tdmi_transmitter;

architecture Behavioral of tdmi_transmitter is

    --Signals
    --Clocking
    signal new_character : std_logic := '0';
    --Number of excess 0's or 1's transmitted for the current character
    signal cnt_t : std_logic_vector(31 downto 0) := (others => '0');
    --Character we are currently sending
    signal cS : std_logic_vector(7 downto 0) := (others => '0');
    --Output signal, 10 bits wide
    signal q_output : std_logic_vector(9 downto 0) := (others => '0');
    
    --Functions
    function one_count_four(d : std_logic_vector(3 downto 0)) return unsigned is
        variable result : std_logic_vector(31 downto 0) := (others => '0');
    begin
        case d is
            when x"0" => result := std_logic_vector(to_unsigned(0, 32));
            when x"1" => result := std_logic_vector(to_unsigned(1, 32));
            when x"2" => result := std_logic_vector(to_unsigned(1, 32));
            when x"3" => result := std_logic_vector(to_unsigned(2, 32));
            when x"4" => result := std_logic_vector(to_unsigned(1, 32));
            when x"5" => result := std_logic_vector(to_unsigned(2, 32));
            when x"6" => result := std_logic_vector(to_unsigned(2, 32));
            when x"7" => result := std_logic_vector(to_unsigned(3, 32));
            when x"8" => result := std_logic_vector(to_unsigned(1, 32));
            when x"9" => result := std_logic_vector(to_unsigned(2, 32));
            when x"a" => result := std_logic_vector(to_unsigned(2, 32));
            when x"b" => result := std_logic_vector(to_unsigned(3, 32));
            when x"c" => result := std_logic_vector(to_unsigned(2, 32));
            when x"d" => result := std_logic_vector(to_unsigned(3, 32));
            when x"e" => result := std_logic_vector(to_unsigned(3, 32));
            when x"f" => result := std_logic_vector(to_unsigned(4, 32));
        end case;
        return unsigned(result);
    end function;
    
    function zero_count_four(d : std_logic_vector(3 downto 0)) return unsigned is
        variable result : std_logic_vector(31 downto 0) := (others => '0');
    begin
        result := std_logic_vector(one_count_four(d => d));
        return 4 - unsigned(result);
    end function;
    
    --Functions to calculate number of 1's in a std_logic_vector
    function one_count_eight(d : std_logic_vector(7 downto 0)) return unsigned is
        variable result : std_logic_vector(31 downto 0) := (others => '0');
    begin
        result := std_logic_vector((one_count_four(d => d(7 downto 4)) + one_count_four(d => d(3 downto 0))));
        return unsigned(result);
    end function;
    
    --Functions to calculate number of 0's in a std_logic_vector
    function zero_count_eight(d : std_logic_vector(7 downto 0)) return unsigned is
            variable result : std_logic_vector(31 downto 0) := (others => '0');
    begin
        result := std_logic_vector(8 - one_count_eight(d => d));
        return unsigned(result);
    end function;    
   
begin

    --Output process
    output : process(clk)
    begin
        if(rising_edge(clk)) then
            TDMI_output <= q_output;
        end if;
    end process;
    
    --Main process
    main : process(clk)
        variable q_intermediate : std_logic_vector(8 downto 0) := (others => '0');
    begin       
        if(rising_edge(clk) and en = '1') then
            --Read in the character on its own flipflop so as to not break timing
            cS <= dc;
            
            --First stage:            
            if(one_count_eight(d => cS) > 4 or
               (one_count_eight(d => cS) = 4 and cS(0) = '0')) then    
                q_intermediate(0) := cS(0) ;
                q_intermediate(1) := cS(1) xnor q_intermediate(0);
                q_intermediate(2) := cS(2) xnor q_intermediate(1);
                q_intermediate(3) := cS(3) xnor q_intermediate(2);
                q_intermediate(4) := cS(4) xnor q_intermediate(3);
                q_intermediate(5) := cS(5) xnor q_intermediate(4);
                q_intermediate(6) := cS(6) xnor q_intermediate(5);
                q_intermediate(7) := cS(7) xnor q_intermediate(6);
                q_intermediate(8) := '0';               
            else 
                q_intermediate(0) := cS(0) ;
                q_intermediate(1) := cS(1) xor q_intermediate(0);
                q_intermediate(2) := cS(2) xor q_intermediate(1);
                q_intermediate(3) := cS(3) xor q_intermediate(2);
                q_intermediate(4) := cS(4) xor q_intermediate(3);
                q_intermediate(5) := cS(5) xor q_intermediate(4);
                q_intermediate(6) := cS(6) xor q_intermediate(5);
                q_intermediate(7) := cS(7) xor q_intermediate(6);
                q_intermediate(8) := '1';  
            end if;
        
            --Second stage 
            if(de = '0') then
                cnt_t <= (others => '0');
                case CTL is
                    when "00" =>
                        q_output <=	"1101010100";
                    when "01" =>
                        q_output <=	"0010101011";
                    when "10" =>
                        q_output <= "0101010100";		
                    when "11" =>
                        q_output <= "1010101011";	                        
                    when others =>
                        q_output <=	"1010101011"; 
                end case;
            else
                if((cnt_t = "00000000000000000000000000000000") or 
                   (one_count_eight(d => q_intermediate(7 downto 0)) = 4)) then
                                    
                   if(q_intermediate(8) = '1') then
                        q_output(9) <= '0';
                        q_output(8) <= '1';
                        q_output(7 downto 0) <= q_intermediate(7 downto 0);
                        cnt_t <= std_logic_vector(signed(cnt_t) + 
                                                  signed(one_count_eight(d => q_intermediate(7 downto 0))) -
                                                  signed(zero_count_eight(d => q_intermediate(7 downto 0))));
                   else
                        q_output(9) <= '1';
                        q_output(8) <= '0';
                        q_output(7 downto 0) <= not q_intermediate(7 downto 0);
                        cnt_t <= std_logic_vector(signed(cnt_t) - 
                                                  signed(one_count_eight(d => q_intermediate(7 downto 0))) +
                                                  signed(zero_count_eight(d => q_intermediate(7 downto 0))));
                   end if;
                   
                else
                    --Third stage
                    if((signed(cnt_t) > 0 and (one_count_eight(d => q_intermediate(7 downto 0))) > 4)
                       or
                       (signed(cnt_t) < 0 and ((one_count_eight(d => q_intermediate(7 downto 0))) < 4))) then
                        
                        
                        if(q_intermediate(8) = '0') then
                            q_output(9) <= '1';
                            q_output(8) <= '0';
                            q_output(7 downto 0) <= not q_intermediate(7 downto 0);
                            cnt_t <= std_logic_vector(
                                    signed(cnt_t) -
                                    signed(one_count_eight(d => q_intermediate(7 downto 0))) +
                                    signed(zero_count_eight(d => q_intermediate(7 downto 0)))
                                    );
                        else
                            q_output(9) <= '1';
                            q_output(8) <= '1';
                            q_output(7 downto 0) <= not q_intermediate(7 downto 0);
                            cnt_t <= std_logic_vector(
                                    signed(cnt_t) -
                                    signed(one_count_eight(d => q_intermediate(7 downto 0))) +
                                    signed(zero_count_eight(d => q_intermediate(7 downto 0))) +
                                    2
                                    );
                        end if;                   
                    else
                        if(q_intermediate(8) = '0') then
                            q_output(9) <= '0';
                            q_output(8) <= '0';
                            q_output(7 downto 0) <= q_intermediate(7 downto 0);
                            cnt_t <= std_logic_vector(
                                    signed(cnt_t) +
                                    signed(one_count_eight(d => q_intermediate(7 downto 0))) -
                                    signed(zero_count_eight(d => q_intermediate(7 downto 0))) - 
                                    2
                                    );
                        else
                            q_output(9) <= '0';
                            q_output(8) <= '1';
                            q_output(7 downto 0) <= q_intermediate(7 downto 0);
                            cnt_t <= std_logic_vector(
                                    signed(cnt_t) +
                                    signed(one_count_eight(d => q_intermediate(7 downto 0))) -
                                    signed(zero_count_eight(d => q_intermediate(7 downto 0)))
                                    );
                        end if;  
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
