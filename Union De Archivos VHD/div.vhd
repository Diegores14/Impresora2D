library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity Div_F is
 port(
   CLK: in std_logic;
         D_UART : out std_logic
   );
end Div_F;


architecture Div of Div_F is
 signal tmp: integer range 0 to 5208 := 0;
begin
 
	process (CLK)
	begin
		if(CLK'event and CLK='1') then
			if(tmp = 5208) then
				tmp <= 0;
				D_UART <= '1';
			else
		  		tmp <= tmp + 1;
				D_UART <='0';

			end if;
		end if;
	end process;
 
   

end Div;