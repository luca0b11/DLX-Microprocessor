library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.myTypes.all;

entity tb_datapath is
end tb_datapath;

architecture test of tb_datapath is

    -- Component Declaration for the Unit Under Test (UUT)
    component datapath 
        generic (
            NBIT: integer := 32;
            NWORD: integer := 32;
            RF_ADDR_SIZE: integer := 5
        );
        port (
            CLK     : in  std_logic;
            RESET   : in  std_logic;    -- to the control unit (master reset)
            EN      : in  std_logic;    -- to the control unit

            -- CU signals
            -- fetch stage
            EN_F: in std_logic;
            RST_F: in std_logic;
            -- MUX_PC_SEL: in std_logic;
            -- decode stage
            EN_D : in std_logic;
            RST_D : in std_logic;
            RST_RF : in std_logic;
            -- exec stage
            EN_E: in std_logic;
            RST_E: in std_logic;
            ALU_CODE:   in std_logic_vector(4 downto 0);
            MUX_A_CTR:  in std_logic;
            MUX_B_CTR:  in std_logic;
            J_EN:       in std_logic;
            J_COND:     in std_logic;
            -- ZERO_OUT:   out std_logic;
            -- memory stage
            RST_M: in std_logic;
            EN_M: in std_logic;
            MEM_DATA_EN: in std_logic;
            -- writeback stage
            RST_W : in std_logic;
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

    -- Signals for inputs to the UUT

    constant NBIT       : integer := 32;
    
    signal clk_tb       : std_logic := '0';
    signal reset_tb     : std_logic;    -- to the control unit (master reset)
    signal en_tb        : std_logic;    -- to the control unit
    -- CU signals
    -- fetch stage
    signal en_f_tb      : std_logic;
    signal rst_f_tb     : std_logic;
    -- MUX_PC_SEL: in std_logic;
    -- decode stage
    signal en_d_tb      : std_logic;
    signal rst_d_tb     : std_logic;
    signal rst_rf_tb    : std_logic;
    -- exec stage
    signal en_e_tb      : std_logic;
    signal rst_e_tb     : std_logic;
    signal alu_code_tb  : std_logic_vector(4 downto 0) := "00000";
    signal mux_a_ctr_tb : std_logic;
    signal mux_b_ctr_tb : std_logic;
    signal j_en_tb      : std_logic;
    signal j_cond_tb    : std_logic;
    -- ZERO_OUT:   out std_logic;
    -- memory stage
    signal rst_m_tb     : std_logic;
    signal en_m_tb      : std_logic;
    signal mem_data_en_tb: std_logic;
    -- writeback stage
    signal rst_w_tb     : std_logic;
    signal en_w_tb      : std_logic;
    signal mux_wb_sel_tb: std_logic_vector(1 downto 0);
    signal wb_en_tb     : std_logic;
    signal jl_en_tb     : std_logic;
    -- IMem signals
    -- fetch stage
    signal mem_data_i_tb: std_logic_vector(NBIT-1 downto 0);
    signal mem_addr_i_tb: std_logic_vector(NBIT-1 downto 0);
    -- DMem signals
    -- memory stage
    signal mem_data_read_tb: std_logic_vector(NBIT-1 downto 0);
    signal mem_data_write_tb: std_logic_vector(NBIT-1 downto 0);
    signal mem_addr_tb  : std_logic_vector(NBIT-1 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: datapath
        generic map (
            NBIT => 32,
            NWORD => 32,
            RF_ADDR_SIZE => 5
        )
        port map (
            CLK                 => clk_tb,           
            RESET               => reset_tb,
            EN                  => en_tb,
            EN_F                => en_f_tb,
            RST_F               => reset_tb,
            EN_D                => en_d_tb,
            RST_D               => reset_tb,
            RST_RF              => reset_tb,
            EN_E                => en_e_tb,
            RST_E               => reset_tb,
            ALU_CODE            => alu_code_tb,
            MUX_A_CTR           => mux_a_ctr_tb,
            MUX_B_CTR           => mux_b_ctr_tb,
            J_EN                => j_en_tb,
            J_COND              => j_cond_tb,
            RST_M               => reset_tb,
            EN_M                => en_m_tb,
            MEM_DATA_EN         => mem_data_en_tb,
            RST_W               => reset_tb,
            EN_W                => en_w_tb,
            MUX_WB_SEL          => mux_wb_sel_tb,
            WB_EN               => wb_en_tb,
            JL_EN               => jl_en_tb,
            MEM_DATA_I          => mem_data_i_tb,
            MEM_ADDR_I          => mem_addr_i_tb,
            MEM_DATA_READ       => mem_data_read_tb,
            MEM_DATA_WRITE      => mem_data_write_tb,
            MEM_ADDR            => mem_addr_tb
        );

    clk_proc: process(clk_tb)
    begin
        clk_tb <= not clk_tb after 1 ns;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- TEST ADDI
        -- hold reset state for 5.5 ns.
        reset_tb <= '0';
        en_tb <= '0';

        en_f_tb <= '0';
        en_d_tb <= '0';
        en_e_tb <= '0';
        en_m_tb <= '0';
        en_w_tb <= '0';

        wait for 5.5 ns;    

        -- Fetch
        reset_tb <= '1';
        en_tb <= '1';
        mem_data_i_tb <= X"20020009";
        en_f_tb <= '1';

        wait for 2 ns;

        -- Decode
        en_f_tb <= '0';
        en_d_tb <= '1';

        wait for 2 ns;

        -- Execute
        en_d_tb <= '0';
        en_e_tb <= '1';

        mux_a_ctr_tb <= '0';
        mux_b_ctr_tb <= '1';
        j_en_tb <= '0';
        j_cond_tb <= '0';

        wait for 2 ns;

        mux_a_ctr_tb <= '0';
        mux_b_ctr_tb <= '0';
        j_en_tb <= '0';
        j_cond_tb <= '0';

        -- Memory
        en_e_tb <= '0';
        en_m_tb <= '1';
        
        mem_data_en_tb <= '0';
        -- unico per read and write a differenza della cw -> fixare

        wait for 2 ns;

        -- Write Back
        en_m_tb <= '0';
        en_w_tb <= '1';

        mux_wb_sel_tb <= "00";
        wb_en_tb <= '1';
        jl_en_tb <= '0';

        -- Add more test cases as needed
        wait for 10 ns;


        -- TEST JAL
        -- hold reset state for 5.5 ns.
        reset_tb <= '0';
        en_tb <= '0';

        en_f_tb <= '0';
        en_d_tb <= '0';
        en_e_tb <= '0';
        en_m_tb <= '0';
        en_w_tb <= '0';

        wait for 5 ns;    

        -- Fetch
        reset_tb <= '1';
        en_tb <= '1';
        mem_data_i_tb <= X"0C002209";
        en_f_tb <= '1';                     

        wait for 2 ns;

        -- Decode
        en_f_tb <= '0';
        en_d_tb <= '1';

        wait for 2 ns;

        -- Execute
        en_d_tb <= '0';
        en_e_tb <= '1';

        mux_a_ctr_tb <= '1';
        mux_b_ctr_tb <= '1';
        j_en_tb <= '1';
        j_cond_tb <= '0';

        wait for 2 ns;

        mux_a_ctr_tb <= '0';
        mux_b_ctr_tb <= '0';
        j_en_tb <= '0';
        j_cond_tb <= '0';

        -- Memory
        en_e_tb <= '0';
        en_m_tb <= '1';
        en_f_tb <= '1';
        
        mem_data_en_tb <= '0';

        wait for 2 ns;

        -- Write Back
        en_m_tb <= '1';
        en_w_tb <= '1';

        mux_wb_sel_tb <= "11";
        wb_en_tb <= '1';
        jl_en_tb <= '1';

        -- Add more test cases as needed
        wait for 10 ns;
    end process;

end test;
