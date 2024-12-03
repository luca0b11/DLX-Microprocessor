library ieee;
use ieee.std_logic_1164.all;

entity sum_generator is
  generic (NBIT_PER_BLOCK : integer;
           NBLOCKS : integer);
  port (A:      in      std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
        B:      in      std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
        CIN:    in      std_logic_vector(NBLOCKS-1 downto 0);
        SUM:    out     std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0)
        );
end sum_generator;

architecture STRUCTURAL of sum_generator is
  component carry_select_block
    generic (data_width : integer);
    port(  A:       in      std_logic_vector(data_width-1 downto 0);
           B:       in      std_logic_vector(data_width-1 downto 0);
           CIN:     in      std_logic;
           SUM:     out     std_logic_vector(data_width-1 downto 0)
         );
  end component;

  begin
    SG: for i in 0 to NBLOCKS-1 generate
      CS: carry_select_block
        generic map(data_width => NBIT_PER_BLOCK)
        port map(A => A((i+1)*NBIT_PER_BLOCK-1 downto i*NBIT_PER_BLOCK),
                 B => B((i+1)*NBIT_PER_BLOCK-1  downto i*NBIT_PER_BLOCK),
                 CIN => CIN(i),
                 SUM => SUM((i+1)*NBIT_PER_BLOCK-1  downto i*NBIT_PER_BLOCK)
                 );
      end generate;
end STRUCTURAL;
      
