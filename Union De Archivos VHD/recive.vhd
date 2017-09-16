library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Receiver is
    Port ( Line : in  STD_LOGIC; --lo que le entra, recibe de a bit
           div : in  STD_LOGIC; --divisor de frecuencia 
			  clk : in  STD_LOGIC; --reloj de la FPGA
			  Data : out  STD_LOGIC_VECTOR (7 downto 0); --datos recibidos en registro
			  receive : out STD_LOGIC 
			  );
end Receiver;

architecture Behavioral of Receiver is


signal estado : STD_LOGIC_VECTOR (3 downto 0):="0000"; --inicio,datos a recibir, parada --2^3=8 estados
signal registro : STD_LOGIC_VECTOR (7 downto 0):="00000000";--bits de datos que se reciben
signal receive_aux: STD_LOGIC := '0';--este es el que controla, si es en 1 entonces ya recibió todos los datos


begin
 
process(Line, div,estado,registro,receive_aux,clk) -- lista de sensibilidad 
begin

if(rising_edge(clk)) then
	receive_aux<='0'; --conserva en 0 hasta que se termina de llenar
	if (div ='1') then --divisor de frecuencia
	case estado is
	   
		when 	"0000" => if (Line='0')  then --bit de inicio
									estado<="0001";--siguiente estado
									end if;
									
		when 	"0001" => if (Line='0' or Line='1')  then	--Estado 1 --primer bit de dato
									estado<="0010";
									registro(0) <= Line; --decrementa el tamaño del vector y le concatena el bit que traiga line 							
									end if;
		
		when 	"0010" => if (Line='0' or Line='1')  then	--Estado 2
									estado<="0011";
									registro(1) <=Line;							
									end if;
		
		when 	"0011" => if (Line='0' or Line='1')  then	--Estado 3
									estado<="0100";
									registro(2) <=Line;							
									end if;
		
		when 	"0100" => if (Line='0' or Line='1')  then	--Estado 4
									estado<="0101";
									registro(3) <=Line;						
									end if;
								
		
		when 	"0101" => if (Line='0' or Line='1')  then	--Estado 5
									estado<="0110";
									registro(4) <=Line;						
									end if;
									
	   when 	"0110" => if (Line='0' or Line='1')  then	--Estado 6
									estado<="0111";
									registro(5) <=Line;						
									end if;
	   
		when 	"0111" => if (Line='0' or Line='1')  then	--Estado 7
									estado<="1000";
									registro(6) <=Line;						
									end if;
									
		when "1000" => if (Line='0' or Line='1')  then		--Estado 8, Retorna a Idle
								   estado<="1001";				
									registro(7) <=Line;
									end if;
									
		when "1001" => if(Line='1') then --bit de parada
							receive_aux<='1';
							end if;
							estado<="0000";--vuelve al estado inicial
							
		when OTHERS => estado <= "0000";
		
		end case;
	end if;
end if;
data<=registro;
receive <= receive_aux;	--cuando receive_aux=1 significa que llegó al bit de parada
end process;	
																		
end Behavioral;