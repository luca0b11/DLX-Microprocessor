-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity PG_generator is
  generic(data_width : integer := 32);
  port (
    a      : in  std_logic_vector(data_width-1 downto 0);
    b      : in  std_logic_vector(data_width-1 downto 0);
    c_in   : in std_logic;
    p      : out  std_logic_vector(data_width-1 downto 0);
    g      : out  std_logic_vector(data_width-1 downto 0)
    );  
end PG_generator;
 
architecture behavioral of PG_generator is
 
begin
 
  g(0) <= (a(0) and b(0)) or ((a(0) xor b(0)) and c_in); 
  p(0) <= a(0) xor b(0);
  
  g_GENERATE_FOR: for i in 1 to data_width-1 generate
    g(i) <= a(i) and b(i); 
    p(i) <= a(i) xor b(i);
  end generate g_GENERATE_FOR;
  
   
end behavioral;
