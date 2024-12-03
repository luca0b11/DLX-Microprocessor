library ieee;
use ieee.std_logic_1164.all;

entity carry_select_block is
  generic (DATA_WIDTH : integer);
  port   ( A:       in      std_logic_vector(DATA_WIDTH-1 downto 0);
           B:       in      std_logic_vector(DATA_WIDTH-1 downto 0);
           CIN:     in      std_logic;
           SUM:     out     std_logic_vector(DATA_WIDTH-1 downto 0)
         );
end carry_select_block;

architecture STRUCTURAL of carry_select_block is

  component RCA
    generic (data_width : integer);
    port    (A:	        In	std_logic_vector(data_width-1 downto 0);
	     B:	        In	std_logic_vector(data_width-1 downto 0);
	     Ci:	In	std_logic;
	     S:	        Out	std_logic_vector(data_width-1 downto 0);
	     Co:	Out	std_logic);
  end component;

  
  component MUX21_GENERIC
    generic (NBIT: integer);
    port    (A:	        In	std_logic_vector(NBIT-1 downto 0) ;
             B:	        In	std_logic_vector(NBIT-1 downto 0);
             SEL:	In	std_logic;
             Y:	        Out	std_logic_vector(NBIT-1 downto 0));
  
  end component;

  signal sum_rca_0, sum_rca_1: std_logic_vector(DATA_WIDTH-1 downto 0);
                         
begin

  RCA_0: RCA
    generic map(data_width => DATA_WIDTH)
    port map(A,
             B,
             '0',
             sum_rca_0,
             open);

  RCA_1: RCA
    generic map(data_width => DATA_WIDTH)
    port map(A,
             B,
             '1',
             sum_rca_1,
             open);

  MUX: MUX21_GENERIC
    generic map(NBIT => DATA_WIDTH)
    port map(sum_rca_0,
             sum_rca_1,
             CIN,
             SUM);

end STRUCTURAL;
      
