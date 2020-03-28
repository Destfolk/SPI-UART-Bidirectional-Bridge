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

    Port (clk        : in std_logic;
          rst        : in std_logic;
      
          establish  : in std_logic;
          slave      : in std_logic_vector(1 downto 0);
          
          data_width : in unsigned(6 downto 0);
          
          data_in    : in std_logic_vector(7 downto 0);
          data_out: out std_logic_vector(7 downto 0)
    );
    
end SPI_UART;

architecture Behavioral of SPI_UART is

signal ss                              :std_logic_vector(3 downto 0);
signal mosi, miso,Rx_in, Tx_out        : std_logic;
signal Rx_done, Tx_done                : std_logic;
signal rx_ready, spi_ready, data_ready : std_logic;
signal dout1, dout2                    : std_logic_vector(7 downto 0);

begin

    send: entity work.SPI_Master(Behavioral)
          generic map (N=>8)
          port map ( clk=>clk, rst=>rst, miso=>miso, mosi=>mosi,establish=>establish, data_ready=>data_ready,
                     ss=>ss, slave=>slave, qin=>data_in,qout=>dout1);
    
    Bridge_test: entity work.Bidirectional_Bridge(Behavioral)
        generic map (M=>8)
        port map ( clk=>clk, rst=>rst, ss=>ss, establish=>establish,data_ready=>data_ready, mosi_in=>mosi, miso_in=>tx_out,
                    miso_out=>miso,mosi_out=>rx_in);

     txtrial: entity work.Tx(Behavioral)
        generic map (data_width=>8, stop_ticks=>16)
        port map ( clk=>clk, rst=>rst, Tx_start=>establish, qin=>data_in, Tx_out=>Tx_out, done=>Tx_done);
                            
                    
    recieve: entity work.Rx(Behavioral)
        generic map (data_width=>8, stop_ticks=>16)
        port map ( clk=>clk, rst=>rst, Rx_ready=>establish, Rx_in=>Rx_in, qout=>dout2, done=>Rx_done);
        
    data_out <= dout1 when slave = "01" else dout2;
                
end Behavioral;
