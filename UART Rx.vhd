----------------------------------------------------------------------------
--UART-SPI BIDIRECTIONAL BRIDGE
--UART Rx.vhd
--
--GSoC 2020
--
--Copyright (C) 2020 Seif Eldeen Emad Abdalazeem
--Email: destfolk@gmail.com
----------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Rx is
    
    generic( data_width : integer := 8;
             stop_ticks: integer := 16
    );
            
    port( clk      : in std_logic;
          rst      : in std_logic;
    
          Rx_ready : in std_logic_vector(1 downto 0);
          Rx_in    : in std_logic;
          
          qout     : out std_logic_vector (data_width-1 downto 0);
          done     : out std_logic
    );
          
end Rx;

architecture Behavioral of Rx is

    type statetype is (ideal, start, data, stop);

    signal state     : statetype; 
    signal nextstate : statetype;
    signal clk_out   : std_logic;
    
    --------------------------
    -- Registers 
    --------------------------
    
    signal data_reg  : std_logic_vector(data_width-1 downto 0);
    signal data_next : std_logic_vector(data_width-1 downto 0);
    
        --------------------------
    -- Counters 
    --------------------------
    
    signal width    : integer;
    --
    signal sum_reg  : unsigned (3 downto 0);
    signal sum_next : unsigned (3 downto 0);
    --
    signal num_reg  : unsigned (3 downto 0);
    signal num_next : unsigned (3 downto 0);
    
    
    
begin

    counter: entity work.Counter(Behavioral)
              generic map (
                  M => 162,
                  N => 8)
              port map ( 
                  clk => clk, 
                  rst => rst, 
                  clk_out => clk_out);
        
    process(clk)
    begin
        
        if rising_edge(clk) then
        
            if (rst = '1') then
                state <= ideal;
                sum_reg <= (others => '0');
                num_reg <= (others => '0');
                data_reg <= (others => '0');
            else 
                state <= nextstate;
                sum_reg <= sum_next;
                num_reg <= num_next;
                data_reg <= data_next;
            end if;
        
        end if;
        
    end process;
     
     
     process(clk)
     begin
     
        case state is
     
        when ideal =>
        
            sum_next <= sum_reg;
            num_next <= num_reg;
            data_next <= data_reg;
            done <= '0';
            
            if (Rx_in = '0' and Rx_ready(1) = '1') then 
                nextstate <= start;
            end if;
        
     
        when start =>  
              
            if (clk_out = '1') then 
                
                if (sum_reg = 7) then  
                    nextstate <= data; 
                    sum_next <= (others => '0');
                else 
                    sum_next <= sum_reg + 1;
                end if;
                
            end if;
        
       
        when data =>
        
            if (clk_out = '1') then 
               
               if(Rx_ready(0) = '1') then
                    width <= data_width/2;
               else 
                    width <= data_width;
               end if;
                 
               if (sum_reg = 15) then 
               
                    sum_next <= (others => '0');
                    
                    if(Rx_ready(0) = '1') then
                        data_next <= "00000000"  & Rx_in & data_reg(data_width/2-1 downto 1);
                    else 
                        data_next <= Rx_in & data_reg(data_width-1 downto 1);
                    end if;
                    
                    if (num_reg = width - 1 ) then 
                        nextstate <= stop;
                    else 
                        num_next <= num_reg + 1;
                    end if;
                    
                 else
                    sum_next <= sum_reg + 1;
                end if;
                
            end if;
        
        
            when stop =>
            
            if (clk_out = '1') then 
            
                if (sum_reg = (stop_ticks - 1)) then 
                    nextstate <= ideal;
                    sum_next <= (others => '0');
                    num_next <= (others => '0');
                    done <= '1';
                else 
                    sum_next <= sum_reg + 1;
                    
                end if;
            end if;
        
        end case;
        
     end process;
     
     qout <= data_reg;
     
end Behavioral;      
