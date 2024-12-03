library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.myTypes.all;

entity dlx is
    generic (
        NBIT: integer := 32
    );
    port (
        CLK:            in std_logic;
        RST:            in std_logic;
        -- I_Mem signals
        MEM_DATA_I:     in std_logic_vector(NBIT-1 downto 0);   -- instruction from I_Mem
        MEM_ADDR_I:     out std_logic_vector(NBIT-1 downto 0);  -- instruction address (PC)
        MEM_EN_I:       out std_logic;

        -- D_Mem signals
        MEM_DATA_READ: in std_logic_vector(NBIT-1 downto 0);    -- data from D_Mem
        MEM_DATA_WRITE: out std_logic_vector(NBIT-1 downto 0);  -- data to D_Mem
        MEM_ADDR: out std_logic_vector(NBIT-1 downto 0);        -- address for R/W in D_Mem
        MEM_DATA_EN: out std_logic;
        RDNOTWR: out std_logic
    );
end dlx;

architecture structural of dlx is
    -- signals declaration to connect components (datapath and cu)
    -- cw signals
    signal en_f: std_logic;
    signal en_d: std_logic;
    signal en_e: std_logic;
    signal mux_a_ctr: std_logic;
    signal mux_b_ctr: std_logic;
    signal j_en: std_logic;
    signal j_cond: std_logic;
    signal en_m: std_logic;
    -- signal mem_data_en: std_logic;
    -- signal rdnotwr: std_logic;
    signal en_w: std_logic;
    signal mux_wb_sel: std_logic_vector(1 downto 0);
    signal wb_en: std_logic;
    signal jl_en: std_logic;
    -- jump to CU
    signal jump: std_logic;
    signal branch: std_logic;
    -- alu_code from CU
    signal alu_code: std_logic_vector(ALU_OPC_SIZE-1 downto 0);

    component datapath is
        generic (
            NBIT: integer := 32;
            NWORD: integer := 32;
            RF_ADDR_SIZE: integer := 5
        );
        port (
            CLK     : in  std_logic;
            RST     : in  std_logic;    -- to the control unit (master reset)
            -- EN      : in  std_logic;    -- to the control unit
            JUMP    : out std_logic;
            BRANCH  : in std_logic;

            -- CU signals
            -- fetch stage
            EN_F: in std_logic;
            -- decode stage
            EN_D : in std_logic;
            -- exec stage
            EN_E: in std_logic;
            ALU_CODE:   in std_logic_vector(4 downto 0);
            MUX_A_CTR:  in std_logic;
            MUX_B_CTR:  in std_logic;
            J_EN:       in std_logic;
            J_COND:     in std_logic;
            -- memory stage
            EN_M: in std_logic;
            -- writeback stage
            EN_W : in std_logic;
            MUX_WB_SEL: in std_logic_vector(1 downto 0);
            WB_EN : in std_logic;
            JL_EN : in std_logic;

            -- IMem signals
            -- fetch stage
            MEM_DATA_I: in std_logic_vector(NBIT-1 downto 0);
            MEM_ADDR_I: out std_logic_vector(NBIT-1 downto 0);

            -- DMem signals
            -- memory stage
            MEM_DATA_READ: in std_logic_vector(NBIT-1 downto 0);
            MEM_DATA_WRITE: out std_logic_vector(NBIT-1 downto 0);
            MEM_ADDR: out std_logic_vector(NBIT-1 downto 0)
        );
    end component;

    component dlx_cu is
        port (
            Clk         : in std_logic;  -- Clock
            Rst         : in std_logic;  -- Reset:Active-Low
            IR_IN       : in std_logic_vector(IR_SIZE - 1 downto 0);
            JUMP        : in std_logic;
            BRANCH      : out std_logic;
            -- Instruction Register

            -- fetch stage
            EN_F        : out std_logic;
            EN_MEM_I    : out std_logic;
            -- MUX_PC_SEL  : out std_logic;
            -- decode stage
            EN_D        : out std_logic;
            -- exec stage
            EN_E        : out std_logic;
            ALU_CODE    : out std_logic_vector(4 downto 0);
            MUX_A_CTR   : out std_logic;
            MUX_B_CTR   : out std_logic;
            -- ZERO_OUT    : in std_logic;
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
    end component;

    begin
    
    -- Datapath Instance
    DP: datapath
    port map (
        CLK => CLK,
        RST => RST,
        -- EN => EN,
        JUMP => jump,
        BRANCH => branch,
        EN_F => en_f,
        EN_D => en_d,
        EN_E => en_e,
        ALU_CODE => alu_code,
        MUX_A_CTR => mux_a_ctr,
        MUX_B_CTR => mux_b_ctr,
        J_EN => j_en,
        J_COND => j_cond,
        EN_M => en_m,
        EN_W => en_w,
        MUX_WB_SEL => mux_wb_sel,
        WB_EN => wb_en,
        JL_EN => jl_en,
        MEM_DATA_I => MEM_DATA_I,
        MEM_ADDR_I => MEM_ADDR_I,
        MEM_DATA_READ => MEM_DATA_READ,
        MEM_DATA_WRITE => MEM_DATA_WRITE,
        MEM_ADDR => MEM_ADDR
    );

    -- Control Unit Instance
    CU: dlx_cu
    port map (
        CLK => CLK,
        RST => RST,
        IR_IN => MEM_DATA_I,
        JUMP => jump,
        BRANCH => branch,
        EN_F => en_f,
        EN_MEM_I => MEM_EN_I,
        EN_D => en_d,
        EN_E => en_e,
        ALU_CODE => alu_code,
        MUX_A_CTR => mux_a_ctr,
        MUX_B_CTR => mux_b_ctr,
        J_EN => j_en,
        J_COND => j_cond,
        EN_M => en_m,
        MEM_DATA_EN => MEM_DATA_EN,
        RDNOTWR => RDNOTWR,
        EN_W => en_w,
        MUX_WB_SEL => mux_wb_sel,
        WB_EN => wb_en,
        JL_EN => jl_en
    );

end structural;