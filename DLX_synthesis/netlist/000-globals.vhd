library ieee;
use ieee.std_logic_1164.all;

package myTypes is

-- Control unit input sizes
    constant IR_SIZE        : integer := 32;  -- Instruction Register Size
    constant OP_CODE_SIZE   : integer := 6;   -- OPCODE field size
    constant REG_SIZE       : integer := 5;   -- REGISTER field size
    constant FUNC_SIZE      : integer := 11;  -- FUNC field size
    constant ALU_OPC_SIZE   : integer := 5;   -- ALU Op Code Word Size
    constant NUM_OPCODE     : integer := 61;  -- number of cw mem entries
    constant CW_SIZE        : integer := 14;  -- Control Word Size

-- R-Type instruction -> FUNC field
    constant FUNC_SLL       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";
    constant FUNC_SRL       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";
    constant FUNC_SRA       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";
    constant FUNC_ADD       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100000";
    constant FUNC_ADDU      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100001";
    constant FUNC_SUB       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100010";
    constant FUNC_SUBU      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100011";
    constant FUNC_AND       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100100";
    constant FUNC_OR        : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100101";
    constant FUNC_XOR       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000100110";
    constant FUNC_SEQ       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101000";
    constant FUNC_SNE       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101001";
    constant FUNC_SLT       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101010";
    constant FUNC_SGT       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101011";
    constant FUNC_SLE       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101100";
    constant FUNC_SGE       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000101101";
    constant FUNC_MOVI2S    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110000";
    constant FUNC_MOVS2I    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110001";
    constant FUNC_MOVF      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110010";
    constant FUNC_MOVD      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110011";
    constant FUNC_MOVFP2I   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110100";
    constant FUNC_MOVI2FP   : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110101";
    constant FUNC_MOVI2T    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110110";
    constant FUNC_MOVT2I    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000110111";
    constant FUNC_SLTU      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111010";
    constant FUNC_SGTU      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111011";
    constant FUNC_SLEU      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111100";
    constant FUNC_SGEU      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000111101";

-- F-Type instruction -> FUNC field
    constant FUNC_ADDF      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";
    constant FUNC_SUBF      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000001";
    constant FUNC_MULTF     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000010";
    constant FUNC_DIVF      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000011";
    constant FUNC_ADDD      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";
    constant FUNC_SUBD      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000101";
    constant FUNC_MULTD     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";
    constant FUNC_DIVD      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";
    constant FUNC_CVTF2D    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001000";
    constant FUNC_CVTF2I    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001001";
    constant FUNC_CVTD2F    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001010";
    constant FUNC_CVTD2I    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001011";
    constant FUNC_CVTI2F    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001100";
    constant FUNC_CVTI2D    : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001101";
    constant FUNC_MULT      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001110";
    constant FUNC_DIV       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001111";
    constant FUNC_EQF       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010000";
    constant FUNC_NEF       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010001";
    constant FUNC_LTF       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010010";
    constant FUNC_GTF       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010011";
    constant FUNC_GEF       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010100";
    constant FUNC_MULTU     : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010101";
    constant FUNC_DIVU      : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010110";
    constant FUNC_EQD       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000010111";
    constant FUNC_NED       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011000";
    constant FUNC_LTD       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011001";
    constant FUNC_GTD       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011010";
    constant FUNC_LED       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011011";
    constant FUNC_GED       : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000011100";

-- R-Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- register-to-register operation
-- R-Type instruction -> OPCODE field
    constant FTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000001";          -- floating point operation

-- I-Type instruction -> OPCODE field
    constant OP_J       : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";
    constant OP_JAL     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";
    constant OP_BEQZ    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100";
    constant OP_BNEZ    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000101";
    constant OP_BFPT    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";
    constant OP_BFPF    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";
    constant OP_ADDI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";
    constant OP_ADDUI   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";
    constant OP_SUBI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010";
    constant OP_SUBUI   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";
    constant OP_ANDI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";
    constant OP_ORI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001101";
    constant OP_XORI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001110";
    constant OP_LHI     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001111";
    constant OP_RFE     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010000";
    constant OP_TRAP    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010001";
    constant OP_JR      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010010";
    constant OP_JALR    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010011";
    constant OP_SLLI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010100";
    constant OP_NOP     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010101";
    constant OP_SRLI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010110";
    constant OP_SRAI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010111";
    constant OP_SEQI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011000";
    constant OP_SNEI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011001";
    constant OP_SLTI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011010";
    constant OP_SGTI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011011";
    constant OP_SLEI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011100";
    constant OP_SGEI    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "011101";
    constant OP_LB      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100000";
    constant OP_LH      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100001";
    constant OP_LW      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100011";
    constant OP_LBU     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100100";
    constant OP_LHU     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100101";
    constant OP_LF      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100110";
    constant OP_LD      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100111";
    constant OP_SB      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101000";
    constant OP_SH      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101001";
    constant OP_SW      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101011";
    constant OP_SF      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101110";
    constant OP_SD      : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "101111";
    constant OP_ITLB    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111000";
    constant OP_SLTUI   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111010";
    constant OP_SGTUI   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111011";
    constant OP_SLEUI   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111100";
    constant OP_SGEUI   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "111101";

    type mem_array is array (integer range 0 to  NUM_OPCODE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
    constant cw_mem : mem_array := (
        -- CONTROL WORDS FOR THE IMPLEMENTED OPERATIONS
        -- EN_D - EN_E, MUX_A_CTR, MUX_B_CTR, J_EN, J_COND - EN_M, MEM_DATA_EN, RDNOTWR - EN_W, MUX_WB_SEL[2], WB_EN, JL_EN
        "11000010010010", -- R-Type  *
        "11000010010010", -- F-Type  *
        "11111000000000", -- OP_J    *
        "11111010011111", -- OP_JAL  *  -- save lr to r31
        "11110000000000", -- OP_BEQZ *  -- mux val depends on ZERO_OUT
        "11110100000000", -- OP_BNEZ *
        "00000000000000", -- OP_BFPT 
        "00000000000000", -- OP_BFPF 
        "11010010010010", -- OP_ADDI *
        "11010010010010", -- OP_ADDUI *
        "11010010010010", -- OP_SUBI *
        "11010010010010", -- OP_SUBUI *
        "11010010010010", -- OP_ANDI *
        "11010010010010", -- OP_ORI  *
        "11010010010010", -- OP_XORI *
        "00000000000000", -- OP_LHI  
        "00000000000000", -- OP_RFE  
        "00000000000000", -- OP_TRAP 
        "11011000000000", -- OP_JR   *
        "11011010011111", -- OP_JALR *
        "11010010010010", -- OP_SLLI *
        "11000010010000", -- OP_NOP  *
        "11010010010010", -- OP_SRLI *
        "11010010010010", -- OP_SRAI *
        "11010010010010", -- OP_SEQI *
        "11010010010010", -- OP_SNEI * -- set not equal immediate
        "11010010010010", -- OP_SLTI *
        "11010010010010", -- OP_SGTI *
        "11010010010010", -- OP_SLEI * -- set less or equal immediate
        "11010010010010", -- OP_SGEI * -- set great or equal immediate
        "00000000000000",
        "00000000000000",
        "00000000000000", -- OP_LB  
        "00000000000000", -- OP_LH
        "00000000000000",    
        "11010011110110", -- OP_LW   *
        "00000000000000", -- OP_LBU  
        "00000000000000", -- OP_LHU  
        "00000000000000", -- OP_LF   
        "00000000000000", -- OP_LD   
        "00000000000000", -- OP_SB
        "00000000000000", -- OP_SH   
        "00000000000000",
        "11010011010000", -- OP_SW   *
        "00000000000000",   
        "00000000000000", 
        "00000000000000", -- OP_SF
        "00000000000000", -- OP_SD
        "00000000000000",
        "00000000000000",
        "00000000000000",
        "00000000000000",
        "00000000000000",
        "00000000000000",
        "00000000000000",  
        "00000000000000", -- OP_ITLB 
        "00000000000000",
        "00000000000000", -- OP_SLTUI
        "00000000000000", -- OP_SGTUI
        "00000000000000", -- OP_SLEUI
        "00000000000000" -- OP_SGEUI
    );

    -- ALU OP CODES
    constant OP_ALU_ADD  : std_logic_vector(4 downto 0) :=  "00000";
    constant OP_ALU_SUB  : std_logic_vector(4 downto 0) :=  "00001";
    constant OP_ALU_SUBU : std_logic_vector(4 downto 0) :=  "00010";
    constant OP_ALU_AND  : std_logic_vector(4 downto 0) :=  "00100";
    constant OP_ALU_OR   : std_logic_vector(4 downto 0) :=  "00101";
    constant OP_ALU_XOR  : std_logic_vector(4 downto 0) :=  "00110";
    constant OP_ALU_MULT : std_logic_vector(4 downto 0) :=  "01001";
    constant OP_ALU_MULTU: std_logic_vector(4 downto 0) :=  "01010";
    constant OP_ALU_SGE  : std_logic_vector(4 downto 0) :=  "10000";
    constant OP_ALU_SLE  : std_logic_vector(4 downto 0) :=  "10001";
    constant OP_ALU_SNE  : std_logic_vector(4 downto 0) :=  "10010";
    constant OP_ALU_SEQ  : std_logic_vector(4 downto 0) :=  "10011";
    constant OP_ALU_SLT  : std_logic_vector(4 downto 0) :=  "10100";
    constant OP_ALU_SGT  : std_logic_vector(4 downto 0) :=  "10101";
    constant OP_ALU_SLL  : std_logic_vector(4 downto 0) :=  "11000";
    constant OP_ALU_SRL  : std_logic_vector(4 downto 0) :=  "11001";
    constant OP_ALU_SRA  : std_logic_vector(4 downto 0) :=  "11010";
    constant OP_ALU_NOP  : std_logic_vector(4 downto 0) :=  "11111";

end myTypes;
