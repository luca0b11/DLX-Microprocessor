library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_writeback_stage is
end tb_writeback_stage;


architecture test of tb_writeback_stage is

  constant NBIT: integer := 32;
  constant RF_ADDR_SIZE: integer := 5;
  signal CLK: std_logic := '0';
  signal RST: std_logic := '0';
  signal EN: std_logic := '0';
  signal MUX_WB_SEL: std_logic := '0';
  signal LMD: std_logic_vector(NBIT-1 downto 0) := (others=>'1');
  signal ALU_OUT: std_logic_vector(NBIT-1 downto 0) := (others=>'0');
  signal WB_ADDR_IN: std_logic_vector(RF_ADDR_SIZE-1 downto 0) := (others=>'0');
  signal WB_REG_OUT: std_logic_vector(NBIT-1 downto 0);
  signal WB_ADDR_OUT: std_logic_vector(RF_ADDR_SIZE-1 downto 0);

  component writeback_stage is
    generic (NBIT: integer := 32;
            RF_ADDR_SIZE: integer := 5
    );
    port (CLK: in std_logic;
          RST: in std_logic;
          EN: in std_logic; -- ACTIVE HIGH
          LMD: in std_logic_vector(NBIT-1 downto 0);
          ALU_OUT: in std_logic_vector(NBIT-1 downto 0);
          MUX_WB_SEL: in std_logic;
          WB_ADDR_IN: in std_logic_vector(RF_ADDR_SIZE-1 downto 0);
          WB_REG_OUT: out std_logic_vector(NBIT-1 downto 0);
          WB_ADDR_OUT: out std_logic_vector(RF_ADDR_SIZE-1 downto 0)
    );
  end component;

begin

  dut: writeback_stage
    generic map (NBIT => NBIT,
                RF_ADDR_SIZE => RF_ADDR_SIZE
    )
    port map (CLK => CLK,
              RST => RST,
              EN => EN,
              LMD => LMD,
              ALU_OUT => ALU_OUT,
              MUX_WB_SEL => MUX_WB_SEL,
              WB_ADDR_IN => WB_ADDR_IN,
              WB_REG_OUT => WB_REG_OUT,
              WB_ADDR_OUT => WB_ADDR_OUT
              );

  clk_proc: process(CLK)
    begin
      CLK <= not(CLK) after 0.5 ns;
    end process;
  
  RST <= '1' after 2 ns;
  EN <= '1' after 5 ns;
  MUX_WB_SEL <= '1' after 8 ns;
  WB_ADDR_IN <= (others => '1') after 4 ns;

end test;
