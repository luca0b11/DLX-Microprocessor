library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memory_stage is
  generic (NBIT: integer := 32;
          RF_ADDR_SIZE: integer := 5
  );
  port (CLK:            in std_logic;
        RST:            in std_logic;  -- SYNCHRONOUS RESET ACTIVE LOW
        EN:             in std_logic;  -- ENABLE ACTIVE HIGH

        ALU_RES_IN:     in std_logic_vector(NBIT-1 downto 0);
        B_REG_FROM_EXE: in std_logic_vector(NBIT-1 downto 0);
        WB_ADDR_IN:     in std_logic_vector(RF_ADDR_SIZE-1 downto 0);
        NPC_IN:         in std_logic_vector(NBIT-1 downto 0);
        MUX_PC_SEL_IN:  in std_logic;

        LMD_REG_OUT:    out std_logic_vector(NBIT-1 downto 0);
        WB_ADDR_OUT:    out std_logic_vector(RF_ADDR_SIZE-1 downto 0);
        ALU_OUT_REG:    out std_logic_vector(NBIT-1 downto 0);
        NPC_OUT:        out std_logic_vector(NBIT-1 downto 0);
        MUX_PC_SEL_OUT: out std_logic;

        -- signals to D_Mem
        MEM_DATA_READ:  in std_logic_vector(NBIT-1 downto 0);
        MEM_DATA_WRITE: out std_logic_vector(NBIT-1 downto 0);
        MEM_ADDR:       out std_logic_vector(NBIT-1 downto 0)
  );
end memory_stage;


architecture arch of memory_stage is

begin
  reg_proc: process(CLK)
    begin
      if rising_edge(CLK) then
        if RST = '0' then
          LMD_REG_OUT <= (others => '0');
          WB_ADDR_OUT <= (others => '0');
          ALU_OUT_REG <= (others => '0');
          NPC_OUT     <= (others => '0');
        else
          if EN = '1' then
            LMD_REG_OUT     <= MEM_DATA_READ;
            WB_ADDR_OUT     <= WB_ADDR_IN;
            ALU_OUT_REG     <= ALU_RES_IN;
            NPC_OUT         <= NPC_IN;
            MUX_PC_SEL_OUT  <= MUX_PC_SEL_IN;
          end if;
        end if;
      end if;
    end process;

    MEM_ADDR <= ALU_RES_IN;
    MEM_DATA_WRITE <= B_REG_FROM_EXE;

   
end arch;
