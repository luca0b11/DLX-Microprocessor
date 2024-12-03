library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity TB_P4_ADDER is
end TB_P4_ADDER;

architecture TEST of TB_P4_ADDER is
	
  component P4_ADDER is
    generic (
      NBIT           : integer := 32;
      NBIT_PER_BLOCK : integer := 4
    );
    port (
      A :       in	std_logic_vector(NBIT-1 downto 0);
      B :     	in	std_logic_vector(NBIT-1 downto 0);
      Cin :	in	std_logic;
      S :	out	std_logic_vector(NBIT-1 downto 0);
      Cout :	out	std_logic);
  end component;

  signal A_tb, B_tb, S_tb :  std_logic_vector(15 downto 0);
  signal Cin_tb, Cout_tb : std_logic;
	
begin

  P4: P4_ADDER
    generic map(NBIT => 16, NBIT_PER_BLOCK => 4)
    port map (A_tb, B_tb, Cin_tb, S_tb, Cout_tb);


  STIMULUS1: process
  begin
    A_tb <= x"0A0A";
    B_tb <= x"0A0A";
    Cin_tb <= '0';
    wait for 10 ns;
    A_tb <= x"4CFA";
    B_tb <= x"0A3D";
    Cin_tb <= '1';
    wait for 10 ns;
    A_tb <= x"FFFF";
    B_tb <= x"0001";
    Cin_tb <= '0';
    wait;
  end process STIMULUS1;
  
end TEST;

