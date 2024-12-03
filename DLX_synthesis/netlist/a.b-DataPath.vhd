library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.myTypes.all;

entity datapath is
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
end datapath;

architecture structural of datapath is

    -- Signal declarations to connect the stages
    -- fetch stage
    signal ir_reg_out: std_logic_vector(NBIT-1 downto 0);
    signal npc_reg_out: std_logic_vector(NBIT-1 downto 0);
    -- decode stage
    signal a	: std_logic_vector(NBIT-1 downto 0);
    signal b	: std_logic_vector(NBIT-1 downto 0);
    signal imm	: std_logic_vector(NBIT-1 downto 0);
    signal wb_out  : std_logic_vector(RF_ADDR_SIZE-1 downto 0);
    signal npc_out_d : std_logic_vector(NBIT-1 downto 0);
    -- exec stage
    signal alu_out: std_logic_vector(NBIT-1 downto 0); 
    signal v_rb_out: std_logic_vector(NBIT-1 downto 0);
    signal a_rd_out: std_logic_vector(4 downto 0);
    signal npc_out_ex: std_logic_vector(NBIT-1 downto 0);
    signal mux_pc_sel_out: std_logic;
    -- memory stage
    signal lmd_reg_out: std_logic_vector(NBIT-1 downto 0);
    signal wb_addr_out_m: std_logic_vector(RF_ADDR_SIZE-1 downto 0);
    signal alu_out_reg: std_logic_vector(NBIT-1 downto 0);
    signal npc_out_mem: std_logic_vector(NBIT-1 downto 0);
    signal mux_pc_sel: std_logic;
    -- writeback stage
    signal wb_reg_out: std_logic_vector(NBIT-1 downto 0);
    signal wb_addr_out_w: std_logic_vector(RF_ADDR_SIZE-1 downto 0);

    -- Components
    component fetch_stage is
        generic (NBIT: integer := 32);
        port (CLK: in std_logic;
              RST: in std_logic;
              EN: in std_logic;                                     -- in cu
              BRANCH: in std_logic;
              MEM_DATA: in std_logic_vector(NBIT-1 downto 0);       -- in mem
              MUX_PC_SEL: in std_logic;                             -- in cu 
              NPC_FROM_ALU: in std_logic_vector(NBIT-1 downto 0);   -- signal
              MEM_ADDR: out std_logic_vector(NBIT-1 downto 0);      -- out mem
              IR_REG_OUT: out std_logic_vector(NBIT-1 downto 0);    -- signal
              NPC_REG_OUT: out std_logic_vector(NBIT-1 downto 0)    -- signal
        );
    end component;

    component decode_stage is
        generic (
            NBIT : integer := 32;
            NWORD : integer := 32);
        port (
            CLK	: in std_logic;
            EN : in std_logic;    -- cu in
            RST : in std_logic;   -- cu in
            WB_EN : in std_logic;     -- cu in
            JL_EN : in std_logic;
            NPC_IN : in std_logic_vector(NBIT-1 downto 0);    -- signal
            WB  : in std_logic_vector(NBIT-1 downto 0);       -- signal
            WB_ADDR : in std_logic_vector(integer(ceil(log2(real(NWORD))))-1 downto 0);   -- signal
            IR	: in std_logic_vector(NBIT-1 downto 0);     -- signal
            A	: out std_logic_vector(NBIT-1 downto 0);    -- signal
            B	: out std_logic_vector(NBIT-1 downto 0);    -- signal
            IMM	: out std_logic_vector(NBIT-1 downto 0);    -- signal
            WB_OUT  : out std_logic_vector(integer(ceil(log2(real(NWORD))))-1 downto 0);  -- signal
            NPC_OUT : out std_logic_vector(NBIT-1 downto 0)   -- signal
            );
    end component;

    component exec_stage is
        generic (NBIT: integer := 32);
        port  (
            CLK:        in std_logic;
            EN:			in std_logic;						-- cu in
            RST:		in std_logic;							-- cu in
            BRANCH:     in std_logic;
            NPC_IN:     in std_logic_vector(NBIT-1 downto 0);   -- signal
            V_RA_IN:    in std_logic_vector(NBIT-1 downto 0);   -- signal
            V_RB_IN:    in std_logic_vector(NBIT-1 downto 0);   -- signal
            IMM_IN:     in std_logic_vector(NBIT-1 downto 0);   -- signal
            A_RD_IN:    in std_logic_vector(4 downto 0);        -- signal
            ALU_CODE:   in std_logic_vector(4 downto 0);        -- cu in
            MUX_A_CTR:  in std_logic;                           -- cu in
            MUX_B_CTR:  in std_logic;                           -- cu in
            J_EN:       in std_logic;
            J_COND:     in std_logic;
            ALU_OUT:    out std_logic_vector(NBIT-1 downto 0);   -- signal
            V_RB_OUT:   out std_logic_vector(NBIT-1 downto 0);   -- signal
            A_RD_OUT:   out std_logic_vector(4 downto 0);        -- signal
            NPC_OUT:    out std_logic_vector(NBIT-1 downto 0);
            MUX_PC_SEL: out std_logic
            );
      end component;

    component memory_stage is
        generic (
            NBIT: integer := 32;
            RF_ADDR_SIZE: integer := 5
        );
        port (
            CLK: in std_logic;
            RST: in std_logic;  --  cu in
            EN: in std_logic;   -- cu in
            MUX_PC_SEL_IN: in std_logic;
            MUX_PC_SEL_OUT: out std_logic;
            ALU_RES_IN: in std_logic_vector(NBIT-1 downto 0);    -- signal
            B_REG_FROM_EXE: in std_logic_vector(NBIT-1 downto 0);  -- signal 
            MEM_DATA_READ: in std_logic_vector(NBIT-1 downto 0);  --  in Dmem
            WB_ADDR_IN: in std_logic_vector(RF_ADDR_SIZE-1 downto 0);     -- signal
            MEM_DATA_WRITE: out std_logic_vector(NBIT-1 downto 0);    -- out Dmem
            MEM_ADDR: out std_logic_vector(NBIT-1 downto 0);      -- out Dmem
            LMD_REG_OUT: out std_logic_vector(NBIT-1 downto 0);   -- signal 
            WB_ADDR_OUT: out std_logic_vector(RF_ADDR_SIZE-1 downto 0);    -- signal
            ALU_OUT_REG: out std_logic_vector(NBIT-1 downto 0); -- signal
            NPC_IN: in std_logic_vector(NBIT-1 downto 0);
            NPC_OUT: out std_logic_vector(NBIT-1 downto 0)
        );
    end component;

    component writeback_stage is
        generic (NBIT: integer := 32;
          RF_ADDR_SIZE: integer := 5
        );
        port (CLK: in std_logic;
              RST: in std_logic;
              EN: in std_logic; -- ACTIVE HIGH
              LMD: in std_logic_vector(NBIT-1 downto 0);
              ALU_OUT: in std_logic_vector(NBIT-1 downto 0);
              WB_ADDR_IN: in std_logic_vector(RF_ADDR_SIZE-1 downto 0);
              MUX_WB_SEL: in std_logic_vector(1 downto 0);
              WB_REG_OUT: out std_logic_vector(NBIT-1 downto 0);
              WB_ADDR_OUT: out std_logic_vector(RF_ADDR_SIZE-1 downto 0);
              NPC_IN: in std_logic_vector(NBIT-1 downto 0)
        );
    end component;

begin

    -- Fetch Stage Instance
    FS: fetch_stage
    generic map (
		NBIT => NBIT
		)
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN_F,
        BRANCH => branch,
        MEM_DATA => MEM_DATA_I,
        MUX_PC_SEL => mux_pc_sel_out,
        NPC_FROM_ALU => alu_out,
        MEM_ADDR => MEM_ADDR_I,
        IR_REG_OUT => ir_reg_out,
        NPC_REG_OUT => npc_reg_out
		);

    -- Decode Stage Instance
    DS: decode_stage
    generic map (
		NBIT => NBIT,
        NWORD => NWORD
		)
    port map (
        CLK => CLK,
        EN => EN_D,
        RST => RST,
        WB_EN => WB_EN,
        JL_EN => JL_EN,
        NPC_IN => npc_reg_out,
        WB => wb_reg_out,
        WB_ADDR => wb_addr_out_w,
        IR => ir_reg_out,
        A => a,
        B => b,
        IMM	=> imm,
        WB_OUT => wb_out,
        NPC_OUT => npc_out_d
		);

    -- Execution Stage Instance
    ES: exec_stage
    generic map (
		NBIT => NBIT
		)
    port map (
        CLK => CLK,    
        EN => EN_E,
        RST => RST,
        BRANCH => BRANCH,
        NPC_IN => npc_out_d,
        V_RA_IN => a,
        V_RB_IN => b,
        IMM_IN => imm,
        A_RD_IN => wb_out,
        ALU_CODE => ALU_CODE,
        MUX_A_CTR => MUX_A_CTR,
        MUX_B_CTR => MUX_B_CTR,
        J_EN => J_EN,
        J_COND => J_COND,
        ALU_OUT => alu_out,
        V_RB_OUT => v_rb_out,
        A_RD_OUT => a_rd_out,
        NPC_OUT => npc_out_ex,
        MUX_PC_SEL => mux_pc_sel_out
		);

    JUMP <= mux_pc_sel_out;

    -- Memory Stage Instance
    MS: memory_stage
    generic map (
		NBIT => NBIT,
        RF_ADDR_SIZE => RF_ADDR_SIZE
        )
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN_M,
        ALU_RES_IN => alu_out,
        B_REG_FROM_EXE => v_rb_out,
        MEM_DATA_READ => MEM_DATA_READ, 
        WB_ADDR_IN => a_rd_out,
        MEM_DATA_WRITE => MEM_DATA_WRITE,
        MEM_ADDR => MEM_ADDR,
        LMD_REG_OUT => lmd_reg_out,
        WB_ADDR_OUT => wb_addr_out_m,
        ALU_OUT_REG => alu_out_reg,
        NPC_IN => npc_out_ex,
        NPC_OUT => npc_out_mem,
        MUX_PC_SEL_IN => mux_pc_sel_out,
        MUX_PC_SEL_OUT => mux_pc_sel
    );

    -- Writeback Stage Instance
    WS: writeback_stage
    generic map (
		NBIT => NBIT,
        RF_ADDR_SIZE => RF_ADDR_SIZE
        )
    port map (
        CLK => CLK,
        RST => RST,
        EN => EN_W,
        LMD => lmd_reg_out,
        ALU_OUT => alu_out_reg,
        WB_ADDR_IN => wb_addr_out_m,
        MUX_WB_SEL => MUX_WB_SEL,
        WB_REG_OUT => wb_reg_out,
        WB_ADDR_OUT => wb_addr_out_w,
        NPC_IN => npc_out_mem
    );

end structural;