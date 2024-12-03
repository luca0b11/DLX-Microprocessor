-- Code your testbench here
library IEEE;
use IEEE.std_logic_1164.all;

entity carry_generator is
  generic (
    data_width  : integer := 32;
    bit_blocks  : integer := 4
    );
  port (
    a     :	in	std_logic_vector(data_width-1 downto 0);
    b     :	in	std_logic_vector(data_width-1 downto 0);
    c_in  :	in	std_logic;
    c_out :	out	std_logic_vector(data_width/bit_blocks downto 0)
  );
end carry_generator;

architecture structural of carry_generator is

  component PG_generator is
    generic(
      data_width : integer := 32
    );
    port (
    	a      : in  std_logic_vector(data_width-1 downto 0);
    	b      : in  std_logic_vector(data_width-1 downto 0);
    	c_in   : in std_logic;
    	p      : out  std_logic_vector(data_width-1 downto 0);
    	g      : out  std_logic_vector(data_width-1 downto 0)
    );
  end component;

  component PG_network is
    generic(
      data_width : integer := 32;
      bit_blocks : integer := 4
      );
    port (
      p_in    : in  std_logic_vector(data_width-1 downto 0);
      g_in    : in  std_logic_vector(data_width-1 downto 0);
      c_in    : in  std_logic;
      c_out   : out  std_logic_vector(data_width/bit_blocks downto 0)
      );
  end component;
  
  signal p_gen  : std_logic_vector(data_width-1 downto 0);
  signal g_gen  : std_logic_vector(data_width-1 downto 0);

  begin
  
    PG_GEN: PG_generator
      generic map(
        data_width => data_width
      )
      port map(
        a => a,
        b => b,
        c_in => c_in,
        p => p_gen,
        g => g_gen
      );

    PG_NET: PG_network
      generic map(
        data_width => data_width,
        bit_blocks => bit_blocks
      )
      port map(
        p_in  => p_gen,
        g_in  => g_gen,
        c_in  => c_in,
        c_out => c_out
      );
    
end architecture;
