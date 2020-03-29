----------------------------------------------------------------------------
--UART-SPI BIDIRECTIONAL BRIDGE
--SPI_UART.vhd
--
--GSoC 2020
--
--Copyright (C) 2020 Seif Eldeen Emad Abdalazeem
--Email: destfolk@gmail.com
----------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity SPI_UART is

    Port (clk         : in std_logic;
          rst         : in std_logic;
          
          start       : in std_logic;
          slave_width : in std_logic;
          slave       : in std_logic_vector(1 downto 0);
          
          data_in     : in std_logic_vector(15 downto 0);
          data_out    : out std_logic_vector(15 downto 0)
    );
    
end SPI_UART;

architecture Behavioral of SPI_UART is

    signal establish : std_logic_vector(1 downto 0);
    
    --------------------------
    -- SPI Signals
    --------------------------

    signal data_ready : std_logic;
    signal din1       : std_logic_vector(15 downto 0);
    signal dout1      : std_logic_vector(15 downto 0);

    --------------------------
    -- Bridge Signals
    --------------------------

    signal mosi   : std_logic;
    signal miso   : std_logic;
    signal Rx_in  : std_logic;
    signal Tx_out : std_logic;
    signal ss     :std_logic_vector(3 downto 0);

    --------------------------
    -- Tx Signals
    --------------------------

    signal din2    : std_logic_vector(15 downto 0);
    signal Tx_done : std_logic;

    --------------------------
    -- Rx Signals
    --------------------------

    signal dout2   : std_logic_vector(15 downto 0);
    signal Rx_done : std_logic;

begin

    SPI: entity work.SPI_Master(Behavioral)
        generic map (
            N => 16)
        port map (
            clk => clk,
            rst => rst, 
            --
            miso => miso,
            mosi => mosi,
            --
            establish => establish,
            data_ready => data_ready,
            --
            ss => ss, 
            slave => slave,
            -- 
            qin => din1,
            qout => dout1);
    
    Bridge: entity work.Bidirectional_Bridge(Behavioral)
        generic map (
            M => 16)
        port map ( 
            clk => clk,
            rst => rst,
            --
            ss => ss, 
            establish => establish,
            data_ready => data_ready,
            -- 
            mosi_in => mosi, 
            miso_in => tx_out,
            miso_out => miso,
            mosi_out => rx_in);

    Tx: entity work.Tx(Behavioral)
        generic map (
            data_width => 16,
            stop_ticks => 16)
        port map ( 
            clk => clk,
            rst => rst,
            -- 
            Tx_start => establish,
            -- 
            qin => din2, 
            Tx_out => Tx_out,
            -- 
            done => Tx_done);
                         
    Rx: entity work.Rx(Behavioral)
        generic map (
            data_width => 16,
            stop_ticks => 16)
        port map ( 
            clk => clk, 
            rst => rst, 
            --
            Rx_ready => establish, 
            --
            Rx_in => Rx_in, 
            qout => dout2, 
            --
            done => Rx_done);
             
    process(clk)
    begin
        case start is
            when '1' =>
                establish(1) <= '1';
            
            when others =>
                establish(1) <= '0';
        end case;
        
        case slave_width is
            when '1' =>
                establish(0) <= '1';    -- 8-bit
            
            when '0' =>
                establish(0) <= '0';    -- 16-bit
            
            when others =>
                null;
        end case;
    
        case slave is
            when "00" =>
                din1 <= data_in;
                data_out <= dout2;
        
            when "01" =>
                din2 <= data_in;
                data_out <= dout1;
            
            when others =>
                null;
        end case;
    end process;       
    
end Behavioral;
