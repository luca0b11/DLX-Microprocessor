library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity writeback_stage is
  generic (NBIT: integer := 32;
          RF_ADDR_SIZE: integer := 5
  );
  port (CLK: in std_logic;
        RST: in std_logic;
        EN: in std_logic; -- ACTIVE HIGH TO DO: non serve
        LMD: in std_logic_vector(NBIT-1 downto 0);
        ALU_OUT: in std_logic_vector(NBIT-1 downto 0);
        WB_ADDR_IN: in std_logic_vector(RF_ADDR_SIZE-1 downto 0);
        MUX_WB_SEL: in std_logic_vector(1 downto 0);
        WB_REG_OUT: out std_logic_vector(NBIT-1 downto 0);
        WB_ADDR_OUT: out std_logic_vector(RF_ADDR_SIZE-1 downto 0);
        NPC_IN: in std_logic_vector(NBIT-1 downto 0)
  );
end writeback_stage;


architecture arch of writeback_stage is
  
begin

  mux_proc: process(LMD, ALU_OUT, MUX_WB_SEL)
  begin
    if MUX_WB_SEL = "00" then
      WB_REG_OUT <= ALU_OUT;
    elsif MUX_WB_SEL = "01" then
      WB_REG_OUT <= LMD;
    else 
      WB_REG_OUT <= NPC_IN;
    end if;
  end process;

  WB_ADDR_OUT <= WB_ADDR_IN;

end arch;
