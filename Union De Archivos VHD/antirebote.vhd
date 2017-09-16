library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity antirebote is
    Port ( clk: in STD_LOGIC;
			  pul : in  STD_LOGIC;
           salida : out  STD_LOGIC);
end antirebote;

 architecture Behavioral of antirebote is
			signal aux: STD_LOGIC := '0';
			signal contador: STD_LOGIC_VECTOR(24 downto 0) := (others => '0');
begin
	process(clk)
	begin
	if(clk = '1' and clk'event)then
		salida <= '0';
		if(pul = '1' and aux = '0') then
			aux<= '1';
		end if;
		if(aux = '1')then
			contador <= contador +1;
			if contador = "100110001001011010000000" then
				if(pul='1') then
					salida <= '1';
				end if;
				contador<=(others => '0');
				aux <= '0';
			end if;
		end if;
	end if;
end process;

end Behavioral;


