library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;       -- signed number

entity BOOTHMUL is
  generic (NBIT: integer);
  port ( A: in std_logic_vector(NBIT - 1 downto 0);
         B: in std_logic_vector(NBIT - 1 downto 0);
         P: out std_logic_vector(2*NBIT - 1 downto 0)
       );
end BOOTHMUL;
       

architecture STRUCTURAL of BOOTHMUL is

  -- implementation of a generic number of bit multiplier

  component RCA is
    generic (data_width :   integer);
    Port (A:	In	std_logic_vector(data_width - 1 downto 0);
          B:	In	std_logic_vector(data_width - 1 downto 0);
          Ci:	In	std_logic;
          S:	Out	std_logic_vector(data_width - 1 downto 0);
          Co:	Out	std_logic);
  end component;

  -- definition of the signals arrays used to connnect the sub-blocks of the module
  
  type SignalMatrixLut is array (NBIT/2 - 1 downto 0) of std_logic_vector(2*NBIT - 1 downto 0);
  type SignalMatrixAdd is array (NBIT/2 - 2 downto 0) of std_logic_vector(2*NBIT - 1 downto 0);
  type SignalMatrixSel is array (NBIT/2 - 1 downto 0) of std_logic_vector(2 downto 0);

  signal sel_matrix : SignalMatrixSel;  -- selection signals of the multiplexers
                                        -- output of the encoder
  signal lut_matrix : SignalMatrixLut;  -- output signals of the "lut tables"
                                        -- implemented as encoder + multiplexer
  signal p_matrix : SignalMatrixAdd;    -- output signals of the rcas

  -- B signal extended with a 0 in the position -1, used to implement the encoder
  signal b_enc: std_logic_vector(NBIT downto 0) := (others => '0');

  -- A signal extended on 64 bits, used to implement shifting
  signal a_64: std_logic_vector(2*NBIT - 1 downto 0) := (others => '0');
  
begin

  -- A assigned to the 32 MSBs, the LSBs are all zeros
  a_64(2*NBIT - 1 downto NBIT) <= A;
  -- add a zero in the -1 position
  b_enc(NBIT downto 0) <= B & '0';

  -- generate the multiplier, instantiating the sub-blocks (a process and a component) 
  MUL: for i in 0 to NBIT/2 - 1 generate
    sel_matrix(i) <= b_enc(2*i+2 downto 2*i);

    -- process that implements a LUT containing the values used as input in the
    -- rca
    lut_proc: process(a_64, sel_matrix)
      variable negative: signed(2*NBIT - 1 downto 0);
    begin
      case sel_matrix(i) is
        when "001"|"010"  =>
          lut_matrix(i) <= (others => '0');
          lut_matrix(i)(NBIT + 2*i - 1 downto 0) <= a_64(2*NBIT - 1 downto NBIT - 2*i); --'A'
          
        when "011" =>
          lut_matrix(i) <= (others => '0');
          lut_matrix(i)(NBIT + 2*i downto 0) <= a_64(2*NBIT - 1 downto NBIT - 1 - 2*i); --'2A'

        when "100" =>
          negative := resize(-signed(a_64(2*NBIT - 1 downto NBIT - 1 - 2*i)), 2*NBIT);
          lut_matrix(i) <= std_logic_vector(negative);                                  --'-2A'

        when "101"|"110" =>
          negative := resize(-signed(a_64(2*NBIT - 1 downto NBIT - 2*i)), 2*NBIT);
          lut_matrix(i) <= std_logic_vector(negative);                                  --'-A'

        when others =>
          lut_matrix(i) <= (others => '0');
      end case;
      
    end process lut_proc;

    -- in cycle 0 rca has not to be instantiated
    -- in cycle 1 rca's inputs are both outputs of the LUTs (lut_matrix(0) and
    -- lut_matrix(1))
    if0: if i = 1 generate
      
      rca_block: RCA
        generic map (data_width => 2*NBIT)
        port map (lut_matrix(i-1),
                  lut_matrix(i),
                  '0',
                  p_matrix(i-1),
                  open);
    end generate if0;

    -- in the other cases instantiate the rca, with one input from the ouput of
    -- the previous rca and the other from the LUT
    ifN: if i > 1 generate

      rca_block: RCA
        generic map (data_width => 2*NBIT)
        port map (lut_matrix(i),
                  p_matrix(i-2),
                  '0',
                  p_matrix(i-1),
                  open);
    end generate ifN;
  end generate MUL;

  -- assign the result contained in the last p_matrix signal (output of the
  -- last rca) to the output of the multiplier
  P <= p_matrix(NBIT/2 - 2);

end STRUCTURAL;
