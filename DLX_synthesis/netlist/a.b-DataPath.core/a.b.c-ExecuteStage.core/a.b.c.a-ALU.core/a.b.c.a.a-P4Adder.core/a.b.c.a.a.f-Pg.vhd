-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;

entity PG is
  port (
    pik        : in  std_logic;
    pk_1j      : in  std_logic;
    gik        : in  std_logic;
    gk_1j      : in  std_logic;
    gij        : out std_logic;
    pij        : out std_logic
    );  
end PG;
 
architecture behavioral of PG is
 
begin
  
  gij <= gik or (pik and gk_1j);
  pij <= pik and pk_1j;
  
end behavioral;

library IEEE;
use IEEE.std_logic_1164.all;

entity G is
  port (
    pik        : in  std_logic;
    gik        : in  std_logic;
    gk_1j      : in  std_logic;
    gij        : out std_logic
    );  
end G;
 
architecture behavioral of G is
 
begin
  
  gij <= gik or (pik and gk_1j);
  
end behavioral;
