library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;

entity dlx_cu is 
  port (
    CLK         : in std_logic;  -- Clock
    RST         : in std_logic;  -- Reset:Active-Low
    IR_IN       : in std_logic_vector(IR_SIZE - 1 downto 0);

    JUMP        : in std_logic;
    BRANCH      : out std_logic;
    -- Instruction Register

    -- fetch stage
    EN_F        : out std_logic;
    EN_MEM_I    : out std_logic;
    -- decode stage
    EN_D        : out std_logic;
    -- exec stage
    EN_E        : out std_logic;
    ALU_CODE    : out std_logic_vector(4 downto 0);
    MUX_A_CTR   : out std_logic;
    MUX_B_CTR   : out std_logic;

    J_EN        : out std_logic; --
    J_COND      : out std_logic; --
    -- memory stage
    EN_M        : out std_logic;
    MEM_DATA_EN : out std_logic; -- output of dlx to data_mem
    RDNOTWR     : out std_logic; -- output of dlx to data_mem
    -- writeback stage
    EN_W        : out std_logic;
    MUX_WB_SEL  : out std_logic_vector(1 downto 0);
    WB_EN       : out std_logic;
    JL_EN       : out std_logic
  );
end dlx_cu;

architecture dlx_cu_rtl of dlx_cu is                         
                                
  signal IR_opcode  : std_logic_vector(OP_CODE_SIZE - 1 downto 0);  -- OpCode part of IR
  signal IR_func    : std_logic_vector(FUNC_SIZE - 1 downto 0);   -- Func part of IR when Rtype
  signal cw         : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem

  -- control word is shifted to the correct stage
  signal cw1 : std_logic_vector(CW_SIZE - 1 downto 0); -- DEC
  signal cw2 : std_logic_vector(CW_SIZE - 2 downto 0); -- EXE
  signal cw3 : std_logic_vector(CW_SIZE - 7 downto 0); -- MEM
  signal cw4 : std_logic_vector(CW_SIZE - 10 downto 0); -- WB

  signal aluOpcode_i : std_logic_vector(4 downto 0) := OP_ALU_NOP;
  signal aluOpcode1  : std_logic_vector(4 downto 0) := OP_ALU_NOP;
  signal aluOpcode2  : std_logic_vector(4 downto 0) := OP_ALU_NOP;

  signal jump_i  : std_logic;
  signal jump1 : std_logic;
  signal jump2 : std_logic;
  signal jump3 : std_logic;
 
  begin  -- dlx_cu_rtl

  IR_opcode(5 downto 0) <= IR_IN(IR_SIZE - 1 downto IR_SIZE - OP_CODE_SIZE);
  IR_func(10 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);

  cw <= cw_mem(conv_integer(IR_opcode));

  EN_MEM_I      <= '1';

  -- fetch stage
  EN_F          <= '1';
  -- decode stage
  EN_D          <= cw1(CW_SIZE - 1);
  -- exec stage
  EN_E          <= cw2(CW_SIZE - 1 - 1);
  MUX_A_CTR     <= cw2(CW_SIZE - 1 - 2);
  MUX_B_CTR     <= cw2(CW_SIZE - 1 - 3);
  J_EN          <= cw2(CW_SIZE - 1 - 4); -- if jump = 1
  J_COND        <= cw2(CW_SIZE - 1 - 5); -- branch: if beqz=0, bnez=1
  -- memory stage
  EN_M          <= cw3(CW_SIZE - 1 - 6);
  MEM_DATA_EN   <= cw3(CW_SIZE - 1 - 7);
  RDNOTWR       <= cw3(CW_SIZE - 1 - 8);
  -- writeback stage
  EN_W          <= cw4(CW_SIZE - 1 - 9);
  MUX_WB_SEL(1) <= cw4(CW_SIZE - 1 - 10);
  MUX_WB_SEL(0) <= cw4(CW_SIZE - 1 - 11);
  WB_EN         <= cw4(CW_SIZE - 1 - 12);
  JL_EN         <= cw4(CW_SIZE - 1 - 13);

  -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin
    if RST = '0' then
      -- cw <= (others => '0');
      cw1 <= (others => '0');
      cw2 <= (others => '0');
      cw3 <= (others => '0');
      cw4 <= (others => '0');
      aluOpcode1 <= OP_ALU_NOP;
      aluOpcode2 <= OP_ALU_NOP;
    elsif rising_edge(CLK) then
      if JUMP = '1' then   -- stop the execution of the instruction wrongly fetched
        cw1 <= "11000010010000";
        cw2 <= "1000010010000";
        cw3 <= "10010000";
        cw4 <= cw3(CW_SIZE - 1 - 9 downto 0);
      else
        cw1 <= cw(CW_SIZE - 1 downto 0);
        cw2 <= cw1(CW_SIZE - 1 - 1 downto 0);
        cw3 <= cw2(CW_SIZE - 1 - 6 downto 0);
        cw4 <= cw3(CW_SIZE - 1 - 9 downto 0);

      end if;
      jump1 <= jump_i;
      jump2 <= jump1;
      jump3 <= jump2;
      aluOpcode1 <= aluOpcode_i;
      aluOpcode2 <= aluOpcode1;
    end if;
  end process CW_PIPE;

  ALU_CODE <= aluOpcode2;
  BRANCH <= jump2 or jump3;

  -- Generation of ALU OpCode
  ALU_OP_CODE_P : process (IR_opcode, IR_func)
  begin
	case IR_opcode is
    -- case of R type requires analysis of FUNC
		when RTYPE =>
			case IR_func is
        when FUNC_ADD => aluOpcode_i <= OP_ALU_ADD; jump_i <= '0';
        when FUNC_ADDU => aluOpcode_i <= OP_ALU_ADD; jump_i <= '0';
        when FUNC_SUB => aluOpcode_i <= OP_ALU_SUB; jump_i <= '0';
        when FUNC_SUBU => aluOpcode_i <= OP_ALU_SUB; jump_i <= '0';
				when FUNC_SLL => aluOpcode_i <= OP_ALU_SLL; jump_i <= '0';
				when FUNC_SRL => aluOpcode_i <= OP_ALU_SRL; jump_i <= '0';
        when FUNC_AND => aluOpcode_i <= OP_ALU_AND; jump_i <= '0';
        when FUNC_OR  => aluOpcode_i <= OP_ALU_OR; jump_i <= '0';
        when FUNC_XOR => aluOpcode_i <= OP_ALU_XOR; jump_i <= '0';
        when FUNC_SEQ => aluOpcode_i <= OP_ALU_SEQ; jump_i <= '0';
        when FUNC_SLT => aluOpcode_i <= OP_ALU_SLT; jump_i <= '0';
        when FUNC_SGT => aluOpcode_i <= OP_ALU_SGT; jump_i <= '0';
        when FUNC_SNE => aluOpcode_i <= OP_ALU_SNE; jump_i <= '0';
        when FUNC_SLE => aluOpcode_i <= OP_ALU_SLE; jump_i <= '0';
        when FUNC_SGE => aluOpcode_i <= OP_ALU_SGE; jump_i <= '0';
				when others   => aluOpcode_i <= OP_ALU_NOP; jump_i <= '0';
			end case;

    when FTYPE =>
      case IR_func is
        when FUNC_MULT => aluOpcode_i <= OP_ALU_MULT; jump_i <= '0';
        when FUNC_MULTU => aluOpcode_i <= OP_ALU_MULTU; jump_i <= '0';
        when others => aluOpcode_i <= OP_ALU_NOP; jump_i <= '0';
      end case;
      
    -- case for other instructions
    when OP_J    => aluOpcode_i <= OP_ALU_ADD; jump_i <= '1';
    when OP_JAL  => aluOpcode_i <= OP_ALU_ADD; jump_i <= '1';
    when OP_JR    => aluOpcode_i <= OP_ALU_ADD; jump_i <= '1';
    when OP_JALR  => aluOpcode_i <= OP_ALU_ADD; jump_i <= '1';
    when OP_BEQZ => aluOpcode_i <= OP_ALU_ADD; jump_i <= '1';
    when OP_BNEZ => aluOpcode_i <= OP_ALU_ADD; jump_i <= '1';
    when OP_ADDI => aluOpcode_i <= OP_ALU_ADD; jump_i <= '0';
    when OP_SUBI => aluOpcode_i <= OP_ALU_SUB; jump_i <= '0';
    when OP_ANDI => aluOpcode_i <= OP_ALU_AND; jump_i <= '0';
    when OP_ORI  => aluOpcode_i <= OP_ALU_OR; jump_i <= '0';
    when OP_XORI => aluOpcode_i <= OP_ALU_XOR; jump_i <= '0';
    when OP_SLLI => aluOpcode_i <= OP_ALU_SLL; jump_i <= '0';
    when OP_NOP  => aluOpcode_i <= OP_ALU_NOP; jump_i <= '0';
    when OP_SRLI => aluOpcode_i <= OP_ALU_SRL; jump_i <= '0';
    when OP_SRAI => aluOpcode_i <= OP_ALU_SRA; jump_i <= '0';
    when OP_SEQI => aluOpcode_i <= OP_ALU_SEQ; jump_i <= '0';
    when OP_SLTI => aluOpcode_i <= OP_ALU_SLT; jump_i <= '0';
    when OP_SGTI => aluOpcode_i <= OP_ALU_SGT; jump_i <= '0';
    when OP_SUBUI => aluOpcode_i <= OP_ALU_SUBU; jump_i <= '0';
    when OP_ADDUI => aluOpcode_i <= OP_ALU_ADD; jump_i <= '0';
    when OP_SNEI => aluOpcode_i <= OP_ALU_SNE; jump_i <= '0';
    when OP_SLEI => aluOpcode_i <= OP_ALU_SLE; jump_i <= '0';
    when OP_SGEI => aluOpcode_i <= OP_ALU_SGE; jump_i <= '0';
    when OP_LW   => aluOpcode_i <= OP_ALU_ADD; jump_i <= '0';
    when OP_SW   => aluOpcode_i <= OP_ALU_ADD; jump_i <= '0';
    when others => aluOpcode_i <= OP_ALU_NOP; jump_i <= '0';
	end case;
	end process ALU_OP_CODE_P;

end dlx_cu_rtl;