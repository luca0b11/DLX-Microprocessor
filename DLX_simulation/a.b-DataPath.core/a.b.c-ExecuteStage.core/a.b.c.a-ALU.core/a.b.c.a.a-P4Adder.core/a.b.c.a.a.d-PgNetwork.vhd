-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;

entity PG_network is
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
end PG_network;
 
architecture behavioral of PG_network is

  component PG is
  port (
    pik        : in  std_logic;
    pk_1j      : in  std_logic;
    gik        : in  std_logic;
    gk_1j      : in  std_logic;
    gij        : out std_logic;
    pij        : out std_logic
    );  
  end component;

  component G is
  port (
    pik        : in  std_logic;
    gik        : in  std_logic;
    gk_1j      : in  std_logic;
    gij        : out std_logic
    );  
  end component;
  
  type SignalMatrix is array (data_width-1 downto 0) of std_logic_vector(data_width-1 downto 0);
  signal Gmatrix : SignalMatrix;
  signal Pmatrix : SignalMatrix;
  
  constant prelevels: integer := integer(log2(real(bit_blocks)));
  constant nlenevels: integer := integer(log2(real(data_width))) - 1;
  
begin
  
  for_inputs: for aa in data_width-1 downto 0 generate
    Gmatrix(aa)(aa) <= g_in(aa);
    Pmatrix(aa)(aa) <= p_in(aa);
  end generate for_inputs;

  for_outputs: for aa in data_width/bit_blocks downto 1 generate
    c_out(aa) <= Gmatrix((aa * bit_blocks)-1)(0);
  end generate for_outputs;
  c_out(0) <= c_in;

  --Generation of prelevels
  for_ext1: for aa in 0 to prelevels-1 generate
    constant ceck_index : integer := (2 ** (aa + 1)) - 1 ;
    begin
    for_int1: for bb in data_width-1 downto 0 generate
      constant i : integer := bb;
      constant k : integer := integer(floor(real(bb/(2 ** aa)))) * (2 ** aa);
      constant j : integer := (integer(floor(real(bb/(2 ** aa))))-1) * (2 ** aa);

      begin
      if1: if (bb mod (ceck_index + 1)) = ceck_index generate
        if2: if bb = ceck_index generate
          --Blocco G
          G_BLOCK: G
          port map (pik   => Pmatrix(i)(k), 
                    gik   => Gmatrix(i)(k),
                    gk_1j => Gmatrix(k-1)(j),
                    gij   => Gmatrix(i)(j)
                    );
        end generate if2;
        if3: if bb /= ceck_index generate
          --Blocco PG
          PG_BLOCK: PG
          port map (pik   => Pmatrix(i)(k),
                    pk_1j => Pmatrix(k-1)(j),
                    gik   => Gmatrix(i)(k),
                    gk_1j => Gmatrix(k-1)(j),
                    gij   => Gmatrix(i)(j),
                    pij   => Pmatrix(i)(j) 
                    );
        end generate if3;
      end generate if1;
      
    end generate for_int1;
  end generate for_ext1;

  --Generation of after levels
  for_ext2: for aa in prelevels to nlenevels generate
    for_int2: for bb in data_width-1 downto 0 generate
      constant i : integer := bb;
      constant k : integer := integer(floor(real(bb/(2 ** aa)))) * (2 ** aa);
      constant j : integer := (integer(floor(real(bb/(2 ** aa))))-1) * (2 ** aa);

      begin
      if4: if (bb mod bit_blocks) = (bit_blocks - 1) generate -- select only one evry 4 (8,16)
        if5: if ((bb / (bit_blocks * (2 ** (aa - prelevels)))) mod 2) = 1 generate --1 yes 1 not, 2 yes 2 not ...
          if6: if bb < (2 ** (aa + 1)) generate
            --Blocco G
            G_BLOCK: G
              port map (pik   => Pmatrix(i)(k), 
                        gik   => Gmatrix(i)(k),
                        gk_1j => Gmatrix(k-1)(j),
                        gij   => Gmatrix(i)(j)
                        );
          end generate if6;
          if7: if bb >= (2 ** (aa + 1)) generate
            --Blocco PG
            PG_BLOCK: PG
              port map (pik   => Pmatrix(i)(k),
                        pk_1j => Pmatrix(k-1)(j),
                        gik   => Gmatrix(i)(k),
                        gk_1j => Gmatrix(k-1)(j),
                        gij   => Gmatrix(i)(j),
                        pij   => Pmatrix(i)(j) 
                        );
          end generate if7;
        end generate if5;
      end generate if4;
    end generate for_int2;
  end generate for_ext2;
  
   
end behavioral;
