----------------------------------------------------------------------------
--UART-SPI BIDIRECTIONAL BRIDGE
--SPI_Master.vhd
--
--GSoC 2020
--
--Copyright (C) 2020 Seif Eldeen Emad Abdalazeem
--Email: destfolk@gmail.com
----------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity SPI_Master is
    
    generic ( N : integer := 8
    );
    
    Port ( clk        : in std_logic;
           rst        : in std_logic;
           
           establish  : in  std_logic_vector(1 downto 0);
           slave      : in std_logic_vector(1 downto 0);
           
           qin        : in std_logic_vector(N-1 downto 0);
           miso       : in  std_logic;
           
           ss         : out std_logic_vector(3 downto 0);
           data_ready : out  std_logic;
           mosi       : out std_logic;
           qout       : out std_logic_vector(N-1 downto 0)
    );
           
    
end SPI_Master;

architecture Behavioral of SPI_Master is

    type statetype is (ideal, slave_select, connected, stop);

    signal state     : statetype; 
    signal nextstate : statetype;
    signal clk_out   : std_logic;

    --------------------------
    -- MOSI Signals
    --------------------------

    signal mosi_next     : std_logic;
    signal Tx_ready      : std_logic;
    signal Tx_ready_next : std_logic;
    signal Tx_reg        : std_logic_vector(N-1 downto 0);

    --------------------------
    -- MISO Signals
    --------------------------    

    signal miso_next : std_logic;

    --------------------------
    -- Counters 
    --------------------------

    signal i      : integer;
    signal i_next : integer;

    signal j      : integer;
    signal j_next : integer;

    signal x      : integer;
    signal x_next : integer;

    signal width  : integer;



begin
    
    counter: entity work.Counter(Behavioral)
        generic map (
            M => 162,
            N => 8)
        port map ( 
            clk => clk,
            rst => rst, 
            clk_out => clk_out);

    
    process (clk)
    begin
    
        if rising_edge(clk) then
            if (rst = '1') then
                state <= ideal;
                i <= N;
                j <= N;
                x<=0;
                Tx_ready <= '0';       
            else 
                state <= nextstate;
                i <= i_next;
                j <= j_next;
                x <= x_next;
                Tx_ready <= Tx_ready_next;
                mosi <= mosi_next;
                miso_next <= miso;
            end if;
        end if;    
    end process;  
    
    
    process(clk)
    begin
    
        case state is
            when ideal =>
                nextstate <= state;
                i_next <= i;
                j_next <= j;
                x_next <= 0;
                Tx_ready_next <= '0';
                width<=N;
                    
                if (clk_out <= '1') then 
                    if (establish(0) = '1') then
                        i_next <= N/2;
                        j_next <= N/2;
                        width<= N/2;
                    end if;
                        
                    if (establish(1) = '1') then
                        nextstate <= slave_select;
                    end if;
                end if;

            when slave_select =>
                if (clk_out = '1') then
                    case slave is
                        when "00" =>
                            ss <= "0001";
                                
                        when "01" =>
                            ss <= "0010";
                            
                        when "10" =>
                            ss <= "0100";
                                
                        when "11" =>
                            ss <= "1000";
                            
                        when others =>
                            ss <= "0000";
                    end case;
                                
                    nextstate <= connected;
                end if;
                
            when connected =>
                if (clk_out = '1') then
                    if (establish(1) = '0') then
                        nextstate <= stop;
                    else
                        if (slave = "00") then
                            Tx_ready_next <= '1';
                                
                            if (Tx_ready <= '1') then 
                                if (i = width) then
                                    Tx_reg <= qin;
                                    data_ready <= '1';
                                end if;
                                    
                                if (i = width - 1) then
                                    data_ready <= '0';
                                end if;
                                    
                                if (i = 0) then
                                    i_next <= i-1;
                                elsif (i=-1) then 
                                    nextstate <= stop;
                                    data_ready <= '0';
                                else
                                    mosi_next <= Tx_reg(i-1);
                                    i_next <= i-1;
                                end if;
                             end if;   
                        end if;
                            
                        if (slave = "01") then
                            if (miso_next = '0') then 
                                x_next <= 1;
                            end if;
                                
                            if (x = 1) then
                                if (establish(0)='1') then 
                                    qout(15 downto 8) <= "00000000"; 
                                end if;
                                    
                                if (j = 0) then
                                    j_next <= width;
                                    nextstate <= stop;
                                else 
                                    qout(j-1) <= miso_next;
                                    j_next <= j-1;
                                end if;
                           end if;
                        end if;
                    end if;
                end if;
                 
            when stop =>
                if (clk_out = '1') then   
                    i_next <= N;
                    j_next <= N;
                    x_next <= 0;
                    nextstate <= ideal;
                end if;
        end case;
    end process;     
            
end Behavioral;
