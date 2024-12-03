library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_fetch_stage is
end tb_fetch_stage;


architecture test of tb_fetch_stage is

  constant NBIT: integer := 32;
  signal CLK: std_logic := '0';
  signal RST: std_logic := '0';
  signal EN: std_logic := '0';
  signal PC_REG_IN: std_logic_vector(NBIT-1 downto 0) := (others => '0');
  signal MEM_DATA: std_logic_vector(NBIT-1 downto 0) := (others => '0');
  signal MUX_PC_SEL: std_logic := '0';
  signal NPC_FROM_ALU: std_logic_vector(NBIT-1 downto 0) := (others => '0');
  signal MEM_ADDR: std_logic_vector(NBIT-1 downto 0);
  signal IR_REG_OUT: std_logic_vector(NBIT-1 downto 0);  
  signal NPC_REG_OUT: std_logic_vector(NBIT-1 downto 0);  

  component fetch_stage is
    generic (NBIT: integer := 32);
    port (CLK: in std_logic;
          RST: in std_logic;
          EN: in std_logic; -- ACTIVE HIGH
          --PC_REG_IN: in std_logic_vector(NBIT-1 downto 0);
          MEM_DATA: in std_logic_vector(NBIT-1 downto 0);
          MUX_PC_SEL: in std_logic;
          NPC_FROM_ALU: in std_logic_vector(NBIT-1 downto 0);
          MEM_ADDR: out std_logic_vector(NBIT-1 downto 0);
          IR_REG_OUT: out std_logic_vector(NBIT-1 downto 0);
          NPC_REG_OUT: out std_logic_vector(NBIT-1 downto 0) 
    );
  end component;
  
begin

  dut: fetch_stage
    generic map (NBIT => NBIT)
    port map (CLK => CLK,
              RST => RST,
              EN => EN,
              --PC_REG_IN => PC_REG_IN,
              MEM_DATA => MEM_DATA,
              MUX_PC_SEL => MUX_PC_SEL,
              NPC_FROM_ALU => NPC_FROM_ALU,
              MEM_ADDR => MEM_ADDR,
              IR_REG_OUT => IR_REG_OUT,
              NPC_REG_OUT => NPC_REG_OUT
              );

  clk_proc: process(CLK)
    begin
      CLK <= not(CLK) after 0.5 ns;
    end process clk_proc;
  
  
  RST <= '1' after 2 ns;
  EN <= '1' after 5 ns;
  --PC_REG_IN <= std_logic_vector(unsigned(PC_REG_IN) + 4) after 1 ns;
  MEM_DATA <= std_logic_vector(unsigned(MEM_DATA) + 1) after 1 ns;
  MUX_PC_SEL <= '1' after 7 ns;

end test;
