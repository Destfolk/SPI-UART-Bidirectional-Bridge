library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter is

    generic( M: integer := 10;
             N: integer := 4);                       --ceil(log2(m)-1)
             
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk_out : out STD_LOGIC);
           
end Counter;

architecture Behavioral of Counter is

signal reg, reg_next : unsigned (N-1 downto 0);

begin

    process(clk)
    begin
    
        if rising_edge(clk) then
            if (rst = '1' or reg = M) then 
                reg <= (others => '0');
            else
                reg <= reg_next;
            end if;
            
       end if;
       
    end process;
       
       reg_next <= reg + 1;
       clk_out <= '1' when reg = M else '0';

end Behavioral;
