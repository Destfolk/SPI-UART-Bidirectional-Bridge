----------------------------------------------------------------------------
--UART-SPI BIDIRECTIONAL BRIDGE
--UART Tx.vhd
--
--GSoC 2020
--
--Copyright (C) 2020 Seif Eldeen Emad Abdalazeem
--Email: destfolk@gmail.com
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Tx is
    
    generic( data_width : integer := 8;
             stop_ticks: integer  := 16
    );
            
    port( clk      : in std_logic;
          rst      : in std_logic;
    
          Tx_start : in std_logic_vector(1 downto 0);
          qin      : in std_logic_vector(data_width-1 downto 0);
          
          Tx_out   : out std_logic;
          done     : out std_logic
    );
          
end Tx;

architecture Behavioral of Tx is

    type statetype is (ideal, start, data, stop);

    signal state     : statetype; 
    signal nextstate : statetype;
    signal clk_out   : std_logic;
    
    --------------------------
    -- Registers 
    --------------------------
    
    signal data_reg  : std_logic;
    signal data_next : std_logic;
    signal tst       : std_logic_vector(data_width-1 downto 0) := "00000000";

    --------------------------
    -- Counters 
    --------------------------
    
    signal width    : integer;
    --
    signal sum_reg  : unsigned(3 downto 0);
    signal sum_next : unsigned(3 downto 0);
    --
    signal n        : integer;
    signal n_next   : integer;
    
    

begin
    counter: entity work.Counter(Behavioral)
        generic map (
            M => 162,
            N => 8)
        port map ( 
            clk     => clk, 
            rst     => rst, 
            clk_out => clk_out);
            
    process(clk)
    begin
        if rising_edge(clk) then 
            if (rst = '1') then
                n        <= 0;
                data_reg <= '1';
                state    <= ideal;
                sum_reg  <= (others => '0');
            else 
                n        <= n_next;
                data_reg <= data_next;
                state    <= nextstate;
                sum_reg  <= sum_next;
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        case state is
            when ideal =>
                n_next    <= n;
                done      <= '0';
                data_next <= '1';
                nextstate <= state;
                sum_next  <= sum_reg;
                width     <= data_width;
            
                if (clk_out = '1') then
                    if (Tx_start(0) = '1') then
                        width <= data_width/2;
                    end if;
                
                    if (Tx_start(1) = '1' and tst /= qin) then
                        nextstate <= start;
                    end if;
                end if; 
       
            when start =>
                tst       <= qin;
                data_next <= '0';
            
                if (clk_out = '1') then
                    if (sum_reg = 15) then
                        sum_next  <= (others => '0');
                        nextstate <= data;
                    else
                        sum_next <= sum_reg + 1;
                    end if;     
                end if;
            
            when data =>
                data_next <=  qin(n);
            
                if (clk_out = '1') then 
                    if (sum_reg = 15) then
                        if (n = width - 1) then
                            nextstate <= stop;
                        else
                            n_next <= n+1;
                        end if;
                    
                        sum_next <= (others => '0');
                    else
                        sum_next <= sum_reg + 1;
                    end if;   
                end if;  
                    
            when stop =>
                data_next <= '1';
            
                if (clk_out = '1') then  
                    if (sum_reg = 15) then 
                        done      <= '1';
                        n_next    <= 0;
                        nextstate <= ideal;
                        sum_next  <= (others => '0');
                    else
                        sum_next <= sum_reg + 1;
                    end if;
                end if;
        end case;
    end process;
                 
    Tx_out <= data_reg;
end Behavioral;
