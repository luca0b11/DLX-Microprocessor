library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_memory_stage is
end tb_memory_stage;


architecture test of tb_memory_stage is

  constant NBIT: integer := 32;
  constant RF_ADDR_SIZE: integer := 5;
  signal CLK: std_logic := '0';
  signal RST: std_logic := '0';
  signal EN: std_logic := '0';
  signal ALU_OUT: std_logic_vector(NBIT-1 downto 0) := (others => '0');
  signal B_REG_FROM_DECODE: std_logic_vector(NBIT-1 downto 0) := (others => '0');
  signal MEM_DATA_READ: std_logic_vector(NBIT-1 downto 0) := (others => '0');
  signal WB_ADDR_IN: std_logic_vector(RF_ADDR_SIZE-1 downto 0) := (others => '0');
  signal MEM_DATA_WRITE: std_logic_vector(NBIT-1 downto 0);
  signal MEM_ADDR: std_logic_vector(NBIT-1 downto 0);
  signal LMD_REG_OUT: std_logic_vector(NBIT-1 downto 0);
  signal WB_ADDR_OUT: std_logic_vector(RF_ADDR_SIZE-1 downto 0);


  component memory_stage is
    generic (NBIT: integer := 32;
            RF_ADDR_SIZE: integer := 5
    );
    port (CLK: in std_logic;
          RST: in std_logic;  -- SYNCHRONOUS RESET ACTIVE LOW
          EN: in std_logic;   -- ENABLE ACTIVE HIGH
          ALU_OUT: in std_logic_vector(NBIT-1 downto 0);
          B_REG_FROM_DECODE: in std_logic_vector(NBIT-1 downto 0);
          MEM_DATA_READ: in std_logic_vector(NBIT-1 downto 0);
          WB_ADDR_IN: in std_logic_vector(RF_ADDR_SIZE-1 downto 0);
          MEM_DATA_WRITE: out std_logic_vector(NBIT-1 downto 0);
          MEM_ADDR: out std_logic_vector(NBIT-1 downto 0);
          LMD_REG_OUT: out std_logic_vector(NBIT-1 downto 0);
          WB_ADDR_OUT: out std_logic_vector(RF_ADDR_SIZE-1 downto 0)
    );
  end component;

begin

  dut: memory_stage
    generic map (NBIT => NBIT,
                RF_ADDR_SIZE => RF_ADDR_SIZE)
    port map (CLK => CLK,
              RST => RST,
              EN => EN,
              ALU_OUT => ALU_OUT,
              B_REG_FROM_DECODE => B_REG_FROM_DECODE,
              MEM_DATA_READ => MEM_DATA_READ,
              WB_ADDR_IN => WB_ADDR_IN,
              MEM_DATA_WRITE => MEM_DATA_WRITE,
              MEM_ADDR => MEM_ADDR,
              LMD_REG_OUT => LMD_REG_OUT,
              WB_ADDR_OUT => WB_ADDR_OUT
    );


  clk_proc: process(CLK)
    begin
      CLK <= not(CLK) after 0.5 ns;
    end process;

  RST <= '1' after 2 ns, '0' after 6 ns;
  EN <= '1' after 5 ns;
  ALU_OUT <= std_logic_vector(to_unsigned(1, NBIT)) after 3 ns; 
  B_REG_FROM_DECODE <= std_logic_vector(to_unsigned(2, NBIT)) after 3 ns;
  MEM_DATA_READ <= std_logic_vector(to_unsigned(3, NBIT)) after 3 ns;
  WB_ADDR_IN <= (others => '1') after 4 ns;

end test;
