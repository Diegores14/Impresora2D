library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;



entity MemoriaRam is
    Port ( clk : in  STD_LOGIC;
           WR : in  STD_LOGIC;
           Address : in  STD_LOGIC_VECTOR (14 downto 0);
           Data_in : in  STD_LOGIC_VECTOR (7 downto 0);
           Data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end MemoriaRam;

architecture Behavioral of MemoriaRam is

type ram_type is array (32767 downto 0) of std_logic_vector (7 downto 0);
signal myRam: ram_type;



begin

process (clk)
begin
   if (clk'event and clk = '1') then
      if (WR = '1') then
            myRam(conv_integer(Address)) <= Data_in;
         else
            Data_out <= myRam(conv_integer(Address));
      end if;
   end if;
end process;


end Behavioral;
