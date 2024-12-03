library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.myTypes.all;

entity tb_exec_stage is
end tb_exec_stage;

architecture behavior of tb_exec_stage is

    -- Component Declaration for the Unit Under Test (UUT)
    component exec_stage
        generic (NBIT: integer := 32);
        port (
            CLK:        in std_logic;
            NPC_IN:     in std_logic_vector(NBIT-1 downto 0);
            V_RA_IN:    in std_logic_vector(NBIT-1 downto 0);
            V_RB_IN:    in std_logic_vector(NBIT-1 downto 0);
            IMM_IN:     in std_logic_vector(NBIT-1 downto 0);
            A_RD_IN:    in std_logic_vector(4 downto 0);
            ALU_CODE:   in std_logic_vector(4 downto 0);
            MUX_A_CTR:  in std_logic;
            MUX_B_CTR:  in std_logic;
            ALU_OUT:    out std_logic_vector(NBIT-1 downto 0);
            V_RB_OUT:   out std_logic_vector(NBIT-1 downto 0);
            A_RD_OUT:   out std_logic_vector(4 downto 0);
            ZERO_OUT:   out std_logic
        );
    end component;

    -- Signals for inputs to the UUT
    signal CLK_tb:        std_logic := '0';
    signal NPC_IN:     std_logic_vector(31 downto 0) := (others => '0');
    signal V_RA_IN:    std_logic_vector(31 downto 0) := (others => '0');
    signal V_RB_IN:    std_logic_vector(31 downto 0) := (others => '0');
    signal IMM_IN:     std_logic_vector(31 downto 0) := (others => '0');
    signal A_RD_IN:    std_logic_vector(4 downto 0) := (others => '0');
    signal ALU_CODE:   std_logic_vector(4 downto 0) := (others => '0');
    signal MUX_A_CTR:  std_logic := '0';
    signal MUX_B_CTR:  std_logic := '0';

    -- Signals for outputs from the UUT
    signal ALU_OUT:    std_logic_vector(31 downto 0);
    signal V_RB_OUT:   std_logic_vector(31 downto 0);
    signal A_RD_OUT:   std_logic_vector(4 downto 0);
    signal ZERO_OUT:   std_logic;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: exec_stage
        generic map (
            NBIT => 32
        )
        port map (
            CLK => CLK_tb,
            NPC_IN => NPC_IN,
            V_RA_IN => V_RA_IN,
            V_RB_IN => V_RB_IN,
            IMM_IN => IMM_IN,
            A_RD_IN => A_RD_IN,
            ALU_CODE => ALU_CODE,
            MUX_A_CTR => MUX_A_CTR,
            MUX_B_CTR => MUX_B_CTR,
            ALU_OUT => ALU_OUT,
            V_RB_OUT => V_RB_OUT,
            A_RD_OUT => A_RD_OUT,
            ZERO_OUT => ZERO_OUT
        );

    CLK_tb <= not CLK_tb after 1 ns;

    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        wait for 5.5 ns;    

        -- Test case 1 (RA + RB = 3) ZERO Enabled 
        NPC_IN <= x"00000001";
        V_RA_IN <= x"00000000";
        V_RB_IN <= x"00000003";
        IMM_IN <= x"00000004";
        A_RD_IN <= "00001";
        ALU_CODE <= OP_ALU_ADD;
        MUX_A_CTR <= '0';
        MUX_B_CTR <= '0';
        wait for 4 ns;

        -- Test case 2 (RA - IMM = 1) ZERO Disalbled
        NPC_IN <= x"0000000F";
        V_RA_IN <= x"00000006";
        V_RB_IN <= x"00000007";
        IMM_IN <= x"00000005";
        A_RD_IN <= "00010";
        ALU_CODE <= OP_ALU_SUB;
        MUX_A_CTR <= '0';
        MUX_B_CTR <= '1';
        wait for 4 ns ;

        -- Test case 3 (NPC + RB = 12) ZERO Disabled
        NPC_IN <= x"00000005";
        V_RA_IN <= x"00000006";
        V_RB_IN <= x"00000007";
        IMM_IN <= x"00000008";
        A_RD_IN <= "00010";
        ALU_CODE <= OP_ALU_ADD;
        MUX_A_CTR <= '1';
        MUX_B_CTR <= '0';
        wait for 4 ns ;

        -- Test case 4 (NPC - IMM = 2) Zero Disabled
        NPC_IN <= x"0000000A";
        V_RA_IN <= x"00000006";
        V_RB_IN <= x"00000007";
        IMM_IN <= x"00000008";
        A_RD_IN <= "00010";
        ALU_CODE <= OP_ALU_SUB;
        MUX_A_CTR <= '1';
        MUX_B_CTR <= '1';
        wait for 4 ns ;

        -- Add more test cases as needed
        wait;

    end process;

end behavior;
