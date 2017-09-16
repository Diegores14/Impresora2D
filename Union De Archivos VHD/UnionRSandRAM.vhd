library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity Union1 is
	Port ( clk : in  STD_LOGIC;
			 salida : out std_logic_vector(7 downto 0);
			 ini_pau :  out std_logic;
			 modo : in std_logic_vector (1 downto 0); 
           rx : in  STD_LOGIC
			  );
end Union1;

architecture Behavioral of Union1 is
	COMPONENT Receiver
	PORT(
		Line : IN std_logic;
		div : IN std_logic;
		clk : IN std_logic;          
		Data : OUT std_logic_vector(7 downto 0);
		receive : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT Div_F
	PORT(
		CLK : IN std_logic;          
		D_UART : OUT std_logic
		);
	END COMPONENT;


	COMPONENT MemoriaRam
	PORT(
		clk : IN std_logic;
		WR : IN std_logic;
		Address : IN std_logic_vector(14 downto 0);
		Data_in : IN std_logic_vector(7 downto 0);          
		Data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	signal aux : STD_LOGIC;                  -- la señal de div de frecuencia 
	signal camr : STD_LOGIC;
	signal datosr : STD_LOGIC_VECTOR (7 downto 0);
	
	
	signal direccion : std_logic_vector(14 downto 0):=(others=>'0');
	signal write_read : STD_LOGIC;

	signal ini_pausa : STD_LOGIC := '0';
	
begin

	Inst_Receiver: Receiver PORT MAP(
		Line => rx,
		div => aux,
		clk => clk,
		Data => datosr,
		receive => camr
	);
	
	Inst_Div_F: Div_F PORT MAP(
		CLK => clk,
		D_UART => aux
	);
	
	Inst_MemoriaRam: MemoriaRam PORT MAP(
		clk => clk,
		WR => write_read,
		Address => direccion,
		Data_in => datosr,
		Data_out => salida
		);
		
	ini_pau <= ini_pausa;

process(clk, camr, ini_pausa, modo)
begin
	if (clk'event and clk = '1') then
		if write_read = '1' then
			direccion <= direccion + 1;
			write_read <= '0';
		end if;
		
		if (camr = '1' and ini_pausa = '0') then
			case datosr is
				when "00110000" =>ini_pausa <= '0';
				when "00110001" =>ini_pausa <= '1';
										direccion <=(others=>'0');
				when "00110010" =>write_read <= '1';
				when "00110011" =>write_read <= '1';
				when "00110100" =>write_read <= '1';
				when "00110101" =>write_read <= '1';
				when "00110110" =>write_read <= '1';
				when others => end case;
		end if;
		
		case modo is
				when "01" =>direccion <= direccion + 1;
				when "10" =>direccion <= (others=>'0');
								ini_pausa <= '0';
				when others => end case;
		
	end if;
end process; 

end Behavioral;