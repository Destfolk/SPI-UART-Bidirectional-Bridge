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
    
    signal clk : std_logic;
    signal rst : std_logic;
    --
    signal start       : std_logic;
    signal slave_width : std_logic;
    signal slave       : std_logic_vector(1 downto 0);
    --
    signal data_in   : std_logic_vector(15 downto 0);
    signal data_out  : std_logic_vector(15 downto 0);
    
begin
    SPI_UART_Communication : entity work.SPI_UART(Behavioral)
        port map(
            clk => clk, 
            rst => rst, 
            --
            start => start,
            slave_width => slave_width,
            slave => slave,
            --
            data_in => data_in, 
            data_out => data_out);

    process
    begin
        clk <= '0';
        wait for T/2;
   
        clk <= '1';
        wait for T/2;   
    end process;        
    
        
    process
    begin
        rst <= '1';
        wait for 2*T;
   
        rst <= '0';
        start <= '1';
        slave <= "01";
        slave_width <= '1';
    
        data_in <= "0000000011001100";
        wait for 2ms;
    
        data_in <= "0000000001010101";
        wait for 2ms;
    
        rst <= '1';
        wait for 2*T;
   
        rst <= '0';
        slave_width <= '0';
    
        data_in <= "1100010011001100";
        wait for 2ms;
    
        data_in <= "1101011010101010";
        wait for 2ms;
    end process;
    
end Behavioral;
