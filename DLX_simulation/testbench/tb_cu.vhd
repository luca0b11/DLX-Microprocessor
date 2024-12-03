library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.globals.all;

entity TB_CU is
end entity;


-- TO DO


architecture TESTBENCH of TB_CU is
  -- Component Declaration
  
  -- Control Unit
  component dlx_cu is 
  port (
    Clk         : in  std_logic;  -- Clock
    Rst         : in  std_logic;  -- Reset:Active-Low
    -- Instruction Register

    -- fetch stage
    RST_F       : out std_logic;
    EN_F        : out std_logic;
    MUX_PC_SEL  : out std_logic;
    -- decode stage
    EN_D        : out std_logic;
    RST_D       : out std_logic;
    RST_RF      : out std_logic;
    -- exec stage
    EN_E        : out std_logic;
    RST_E       : out std_logic;
    ALU_CODE    : out std_logic_vector(4 downto 0);
    MUX_A_CTR   : out std_logic;
    MUX_B_CTR   : out std_logic;
    ZERO_OUT    : in std_logic;
    -- memory stage
    RST_M       : out std_logic;
    EN_M        : out std_logic;
    W_DATA_EN   : out std_logic; -- output of dlx to data_mem
    R_DATA_EN   : out std_logic; -- output of dlx to data_mem
    -- writeback stage
    RST_W       : out std_logic;
    EN_W        : out std_logic;
    MUX_WB_SEL  : out std_logic_vector(1 downto 0)
    WB_EN       : out std_logic;
    JL_EN       : out std_logic;
  );
end component;
  
  -- Signals Declaration
  
  
end architecture;