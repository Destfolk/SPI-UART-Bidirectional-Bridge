----------------------------------------------------------------------------
--UART-SPI BIDIRECTIONAL BRIDGE
--tb.vhd
--
--GSoC 2020
--
--Copyright (C) 2020 Seif Eldeen Emad Abdalazeem
--Email: destfolk@gmail.com
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity tb is
end tb;

architecture Behavioral of tb is

    Constant T: time := 20 ns;
    Constant N : integer := 8;
    signal clk, rst, establish: std_logic;
    signal slave : std_logic_vector(1 downto 0);
    signal data_in, data_out : std_logic_vector(N-1 downto 0);
    signal data_width : unsigned(6 downto 0);
    
begin
    
    yarb : entity work.SPI_UART(Behavioral)
            port map(clk=>clk, rst=>rst, establish=>establish, data_width=>data_width,data_in=>data_in, data_out=>data_out, slave=>slave);


    process
    begin
    
    clk<='0';
    wait for T/2;
   
    clk<='1';
    wait for T/2;
        
    end process;        
    
    
    process
    begin
    
    rst<='1';
    wait for 2*T;
   
    rst<='0';
    wait for 3*T;
    data_width<="0001000";
    slave<="01";
    data_in<="11001100";
    establish<='1';
    wait for 800us;
    data_in<="01010101";
    wait for 800us;
    data_in<="11001100";
    establish<='1';
    wait for 800us;
    data_in<="01010101";
    
    wait for 800us;
    end process;
    
end Behavioral;
