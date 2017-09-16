library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity motor_paso_a_paso is
		Port ( stepDrive : out std_logic_vector(3 downto 0):="1111";
		direction : in std_logic;
		stepEnable : in std_logic;
		clk : in std_logic);
end motor_paso_a_paso;

architecture Behavioral of motor_paso_a_paso is
			signal state : std_logic_vector(1 downto 0):="00";
			signal stepCounter : std_logic_vector(17 downto 0):=(others=>'0');
begin
process(clk)
begin
	if ((clk'event) and (clk='1')) then
	stepCounter <= stepCounter + 1;
		if (stepCounter >= "111101000010010000") then
		stepCounter <= "000000000000000000";
		stepDrive <= "0000";
			if (stepEnable = '1') then
				if (direction = '1') then state <= state + "01"; end if;
				if (direction = '0') then state <= state - "01"; end if;
				case state is
				when "00" =>stepDrive <= "1000";
				when "01" =>stepDrive <= "0100";
				when "10" =>stepDrive <= "0010";
				when "11" =>stepDrive <= "0001";
				when others => end case;
			end if;
		end if;
	end if;
end process;

end Behavioral;