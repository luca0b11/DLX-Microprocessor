library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity P4_ADDER is
  generic (
    NBIT           : integer := 32;
    NBIT_PER_BLOCK : integer := 4
    );
  port (
    A :		in	std_logic_vector(NBIT-1 downto 0);
    B :		in	std_logic_vector(NBIT-1 downto 0);
    Cin :	in	std_logic;
    S :		out	std_logic_vector(NBIT-1 downto 0);
    Cout :	out	std_logic
  );
end P4_ADDER;

architecture STRUCTURAL of P4_ADDER is
  
  component sum_generator is
  generic (
    NBIT_PER_BLOCK : integer;
    NBLOCKS : integer
  );
  port (
    A:      in      std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
    B:      in      std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
    CIN:    in      std_logic_vector(NBLOCKS-1 downto 0);
    SUM:    out     std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0)
    );
  end component;

  component carry_generator is
  generic (
    data_width  : integer;
    bit_blocks  : integer
    );
  port (
    a :		in	std_logic_vector(data_width-1 downto 0);
    b :		in	std_logic_vector(data_width-1 downto 0);
    c_in :	in	std_logic;
    c_out :	out	std_logic_vector(data_width/bit_blocks downto 0)
  );
  end component;

  signal Cgen : std_logic_vector((NBIT/ NBIT_PER_BLOCK) downto 0);
	
begin

  CG: carry_generator
    generic map(
      data_width => NBIT,
      bit_blocks => NBIT_PER_BLOCK
      )
    port map(
      a     => A,
      b     => B,
      c_in  => Cin,
      c_out => Cgen);
  
  SG: sum_generator
    generic map(
      NBIT_PER_BLOCK =>  NBIT_PER_BLOCK,
      NBLOCKS => (NBIT/ NBIT_PER_BLOCK)
    )
    port map(
      A    => A,
      B    => B,
      CIN  => Cgen((NBIT/ NBIT_PER_BLOCK)-1 downto 0),
      SUM  => S
   );

  Cout <= Cgen(NBIT/ NBIT_PER_BLOCK);  
	
end STRUCTURAL;

