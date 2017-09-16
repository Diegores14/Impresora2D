library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity union is
    Port ( clk : in  STD_LOGIC;
           rx : in  STD_LOGIC;
           motor_x : out  STD_LOGIC_VECTOR (3 downto 0);
			  motor_y : out  STD_LOGIC_VECTOR (3 downto 0);
           reset : in  STD_LOGIC
			  );
end union;

architecture Behavioral of union is

	COMPONENT Union1
	PORT(
		clk : IN std_logic;
		modo : IN std_logic_vector(1 downto 0);
		rx : IN std_logic;          
		salida : OUT std_logic_vector(7 downto 0);
		ini_pau : OUT std_logic
		);
	END COMPONENT;
	
		COMPONENT motor_paso_a_paso
	PORT(
		direction : IN std_logic;
		stepEnable : IN std_logic;
		clk : IN std_logic;          
		stepDrive : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	
	COMPONENT antirebote
	PORT(
		clk : IN std_logic;
		pul : IN std_logic;          
		salida : OUT std_logic
		);
	END COMPONENT;
	
	type ram_type is array (3 downto 0) of std_logic_vector (14 downto 0);
	signal RAM: ram_type:= ("000000000000000",
			"000000000000000",
			"000000000000000",
			"000000000000000");


	signal contador : STD_LOGIC_VECTOR (24 downto 0) :=(others=>'0');
	signal datos_ram : STD_LOGIC_VECTOR (7 downto 0);
	signal direccion_x : STD_LOGIC := '0';
	signal direccion_y : STD_LOGIC := '0';
	signal habilitar_x : STD_LOGIC := '0';
	signal habilitar_y : STD_LOGIC := '0';
	
	signal inicio : STD_LOGIC;
	signal auxModo : STD_LOGIC_VECTOR (1 downto 0) := "00";
	
	signal pulsador : STD_LOGIC;
	signal aux_reset : STD_LOGIC_vector (1 downto 0) := "00";
	signal aux_contador : STD_LOGIC_vector (14 downto 0) :=(others=>'0');

	
begin

	Inst_Union1: Union1 PORT MAP(
		clk => clk,
		salida => datos_ram,
		ini_pau => inicio,
		modo => auxModo,
		rx => rx
	);
	
	Inst_motor_paso_a_paso_x: motor_paso_a_paso PORT MAP(
		stepDrive => motor_x,
		direction => direccion_x ,
		stepEnable => habilitar_x,
		clk => clk
	);
	
		Inst_motor_paso_a_paso_y: motor_paso_a_paso PORT MAP(
		stepDrive => motor_y,
		direction => direccion_y ,
		stepEnable => habilitar_y,
		clk => clk
	);
	
	Inst_antirebote: antirebote PORT MAP(
		clk => clk,
		pul => reset,
		salida => pulsador
	);

process(clk)
begin
	if(clk'event and clk = '1') then
		
		auxModo <= "00";
		contador <= contador + 1;
		
		--		cuando se oprime el boton de reset
		if pulsador = '1' and aux_reset = "00" then
			aux_reset <= "01";
		end if;
		
		if contador >= "1011111010111100001000000" then
			contador <= (others=>'0');
			--			lee la memoria y mueve los motores para donde lo necesita
			if (inicio = '1' and aux_reset = "00") then
				case datos_ram is
					when "00110010" =>direccion_y <= '1';
											habilitar_y <= '1';
											habilitar_x <= '0';
											auxModo <= "01";
											RAM(2) <= RAM(2) + 1;
					when "00110011" =>direccion_y <= '0';
											habilitar_y <= '1';
											habilitar_x <= '0';
											auxModo <= "01";
											RAM(3) <= RAM(3) + 1;
					when "00110100" =>direccion_x <= '1';
											habilitar_x <= '1';
											habilitar_y <= '0';
											auxModo <= "01";
											RAM(0) <= RAM(0) + 1;
					when "00110101" =>direccion_x <= '0';
											habilitar_x <= '1';
											habilitar_y <= '0';
											auxModo <= "01";
											RAM(1) <= RAM(1) + 1;
					when "00110110" =>habilitar_x <= '0';
											habilitar_y <= '0';
											aux_reset <= "01";
					when others => end case;
			end if;
			
			--de aquí para abajo es para volver a la posisicion de inicio
			if aux_reset = "01" then 
				aux_contador <= aux_contador +1;
				if RAM(0)<RAM(1) then
					direccion_x <= '1';
					habilitar_x <= '1';
					habilitar_y <= '0';
					if (aux_contador >RAM(1)-RAM(0)) then
						aux_reset <= "10";
						aux_contador <= (others=>'0');
						RAM(1) <= "000000000000000";
						RAM(0) <= "000000000000000";
					end if;
				else
					direccion_x <= '0';
					habilitar_x <= '1';
					habilitar_y <= '0';
					if (aux_contador >RAM(0)-RAM(1)) then
						aux_reset <= "10";
						aux_contador <= (others=>'0');
						RAM(1) <= "000000000000000";
						RAM(0) <= "000000000000000";
					end if;
				end if;
			end if;
			
			if aux_reset = "10" then 
				aux_contador <= aux_contador +1;
				if RAM(2)<RAM(3) then
					direccion_y <= '1';
					habilitar_y <= '1';
					habilitar_x <= '0';
					if (aux_contador >RAM(1)-RAM(0)) then
						aux_reset <= "00";
						habilitar_x <= '0';
						habilitar_y <= '0';
						aux_contador <= (others=>'0');
						RAM(2) <= "000000000000000";
						RAM(3) <= "000000000000000";
						auxModo <= "10";
					end if;
				else
					direccion_y <= '0';
					habilitar_y <= '1';
					habilitar_x <= '0';
					if (aux_contador >RAM(0)-RAM(1)) then
						aux_reset <= "00";
						habilitar_x <= '0';
						habilitar_y <= '0';
						aux_contador <= (others=>'0');
						RAM(2) <= "000000000000000";
						RAM(3) <= "000000000000000";
						auxModo <= "10";
					end if;
				end if;
			end if;             -- aquí termina de ubicar el cabezal en la posicion de inicio
			
		end if;
		
	end if;
end process;

end Behavioral;

