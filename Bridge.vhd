----------------------------------------------------------------------------

--UART-SPI BIDIRECTIONAL BRIDGE

--Bridge.vhd

--

--GSoC 2020

--

--Copyright (C) 2020 Seif Eldeen Emad Abdalazeem

--Email: destfolk@gmail.com

----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity Bidirectional_Bridge is
    generic( M : integer := 8
    );
    
    port( clk        : in std_logic;
          rst        : in std_logic;
          
          establish  : in std_logic_vector(1 downto 0);
          ss         : in std_logic_vector(3 downto 0);
          data_ready : in std_logic;
          
          mosi_in    : in std_logic;
          miso_in    : in std_logic;
          
          miso_out   : out std_logic;
          mosi_out   : out std_logic
    );
          
end Bidirectional_Bridge;

architecture Behavioral of Bidirectional_Bridge is

type statetype is (ideal, start, MOSI, MISO, stop);

    signal state     : statetype; 
    signal nextstate : statetype;
    signal clk_out   : std_logic;

    --------------------------
    -- MOSI Signals
    --------------------------

    signal Tx_ready      : std_logic_vector(1 downto 0);
    signal Tx_ready_next : std_logic_vector(1 downto 0);
    --
    signal reg1          : std_logic_vector(M-1 downto 0);
    signal mem_reg1      : std_logic_vector(M-1 downto 0);
    --
    signal Tx_done       : std_logic;

    --------------------------
    -- MISO Signals
    --------------------------    
    
    signal Rx_ready      : std_logic_vector(1 downto 0);
    signal Rx_ready_next : std_logic_vector(1 downto 0);
    --
    signal reg2          : std_logic_vector(M downto 0);
    signal mem_reg2      : std_logic_vector(M-1 downto 0);
    --
    signal Rx_done       : std_logic;
    
    --------------------------
    -- Counters 
    --------------------------

    signal n      : integer;
    signal n_next : integer;



begin
    
     counter: entity work.Counter(Behavioral)
               generic map (
                   M => 162,
                   N => 8)
               port map (
                   clk => clk,
                   rst => rst,
                   clk_out => clk_out);
            
            
            
     Btx: entity work.Tx(Behavioral)
           generic map (
               data_width => M,
               stop_ticks => 16)
           port map ( 
               clk => clk,
               rst => rst,
               -- 
               Tx_start => Tx_ready, 
               --
               qin => mem_reg1, 
               Tx_out => mosi_out,
               --
               done => Tx_done);
     
     
     
     Brx: entity work.Rx(Behavioral)
           generic map (
               data_width => M, 
               stop_ticks => 16)
           port map ( 
               clk => clk, 
               rst => rst,
               --
               Rx_ready => Rx_ready,
               --
               Rx_in => miso_in, 
               qout => mem_reg2, 
               done => Rx_done);
               
               
         
    process(clk)
    begin
    
        if rising_edge(clk) then
            
            if(rst = '1') then
            
                state <= ideal;
            
            else
                
                state <= nextstate;
                Tx_ready <= Tx_ready_next;
                Rx_ready <= Rx_ready_next;
                n <= n_next;
                
            end if;

        end if;
        
    end process;
    
    
    process(clk)
    begin
    
        case state is
     
        when ideal =>
            
            nextstate <= state;
            n_next <= M;
                    
            if(clk_out = '1') then
                
                if(establish(0) = '1') then
                    n_next <= M/2;
                    Tx_ready_next(0) <= '1';
                    Rx_ready_next(0) <= '1';
                    else
                    Tx_ready_next(0) <= '0';
                    Rx_ready_next(0) <= '0';
                end if;
                        
                if(establish(1)= '1') then
                    nextstate <= start;
                end if;
                
            end if;
            
            
        when start =>
        
            if(clk_out = '1') then
            
                case ss is
                
                    when  "0001" =>
                        if (data_ready = '1') then
                            nextstate <= MOSI; end if;
                
                    when  "0010" =>
                        Rx_ready_next(1) <= '1';
                        if(Rx_done = '1') then
                            nextstate <= MISO; end if;
                    
                    when others =>
                        Tx_ready_next(1) <= '0';
                        Rx_ready_next(1) <= '0';         
        
                end case;
                
                if(establish(1) = '0') then
                    nextstate <= ideal;
                end if;
                
            end if;
            
            
        when MOSI =>
            
            if(clk_out = '1') then
                
                if(n > 0) then
                    reg1(n-1) <= mosi_in;
                    n_next <= n-1;                    
                else
                    
                    if(mem_reg1/=reg1)then
                        Tx_ready_next(1) <= '1';
                        mem_reg1<=reg1;
                    else 
                        nextstate <= stop;
                    end if;
                    
                end if;
                
                if(Tx_done = '1') then
                    Tx_ready_next(1) <= '0';
                    nextstate <= stop;
                end if;
                
            end if;
            
            
        when MISO =>
            
            if(clk_out = '1') then
            
                reg2 <= '0' & mem_reg2;
                
                if(n>=0) then
                    miso_out <= reg2(n);
                    n_next <= n-1;
                else
                    nextstate <= stop;
                    miso_out <= '1';
                end if;
              
            end if;
            
        
        when stop =>
        
            if(clk_out = '1') then
            
                Tx_ready_next(1) <= '0';
                Rx_ready_next(1) <= '0';
                nextstate <= ideal;
                
            end if;  
        
        end case;        
        
    end process;
                    
end Behavioral;
