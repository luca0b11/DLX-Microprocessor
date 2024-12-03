library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fetch_stage is
  generic (NBIT: integer := 32);
  port (CLK:          in std_logic;
        RST:          in std_logic;
        EN:           in std_logic;
        BRANCH:       in std_logic;

        MUX_PC_SEL:   in std_logic;
        NPC_FROM_ALU: in std_logic_vector(NBIT-1 downto 0);
        IR_REG_OUT:   out std_logic_vector(NBIT-1 downto 0);
        NPC_REG_OUT:  out std_logic_vector(NBIT-1 downto 0);

        -- I_Mem signals
        MEM_DATA:     in std_logic_vector(NBIT-1 downto 0);
        MEM_ADDR:     out std_logic_vector(NBIT-1 downto 0)
  );
end fetch_stage;

architecture arch of fetch_stage is

  -- pc_reg_out is the output of the PC register, it is used to address the instruction memory and tocompute the next PC
  signal pc_to_mem: std_logic_vector(NBIT-1 downto 0);
  signal pc_incremented: std_logic_vector(NBIT-1 downto 0);
  signal mux_pc: std_logic_vector(NBIT-1 downto 0);

begin

  reg_proc: process(CLK)
    begin
      if rising_edge(CLK) then
        if RST = '0' then
          IR_REG_OUT <= (others => '0');
          NPC_REG_OUT <= (others => '0');
          pc_to_mem <= (others => '0');
        else
          if EN = '1' then
            IR_REG_OUT <= MEM_DATA;
            NPC_REG_OUT <= mux_pc;
            pc_to_mem <= mux_pc;
          end if;
        end if;
      end if;
    end process;

  mux_proc: process(NPC_FROM_ALU, pc_incremented, MUX_PC_SEL)
    begin
      if MUX_PC_SEL = '1' and BRANCH ='1' then
        mux_pc <= NPC_FROM_ALU;
      else
        mux_pc <= pc_incremented;
      end if;
    end process;

  pc_incremented <= std_logic_vector(unsigned(pc_to_mem) + 4);  -- Incremented by 1 to fit memory index
  MEM_ADDR <= pc_to_mem;

end arch;
