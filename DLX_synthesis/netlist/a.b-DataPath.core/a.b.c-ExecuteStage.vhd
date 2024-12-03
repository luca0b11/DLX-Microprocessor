library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.myTypes.all;

entity exec_stage is
  generic (NBIT: integer := 32);
  port  (
        -- CLOCK SIGNAL
        CLK:        in std_logic;                           -- Clock Signal
		EN:			in std_logic;							-- enable of registers
		RST:		in std_logic;							-- Reset of registers
        -- DATA INPUT
        NPC_IN:     in std_logic_vector(NBIT-1 downto 0);   -- New Program Counter
        V_RA_IN:    in std_logic_vector(NBIT-1 downto 0);   -- Value of RA
        V_RB_IN:    in std_logic_vector(NBIT-1 downto 0);   -- Valie of RB
        IMM_IN:     in std_logic_vector(NBIT-1 downto 0);   -- Value of Immediate
        A_RD_IN:    in std_logic_vector(4 downto 0);        -- Address (number register) of destination register
        -- CONTROL INPUT
        ALU_CODE:   in std_logic_vector(4 downto 0);        -- ALU Operation selection
        MUX_A_CTR:  in std_logic;                           -- Control of MUX A (0 for regA, 1 for NPC)
        MUX_B_CTR:  in std_logic;                           -- Control of MUX B (0 for regB, 1 for IMM)
        J_EN:       in std_logic;
        J_COND:     in std_logic;
        BRANCH:     in std_logic;
        -- DATA OUTPUT
        ALU_OUT:    out std_logic_vector(NBIT-1 downto 0);   -- ALU Result (AFTER the register)
        V_RB_OUT:   out std_logic_vector(NBIT-1 downto 0);   -- Value of RB (AFTER the register) used for store/load operations
        A_RD_OUT:   out std_logic_vector(4 downto 0);        -- Address (number register) of destination register (AFTER the register)
        NPC_OUT:    out std_logic_vector(NBIT-1 downto 0);
        MUX_PC_SEL: out std_logic
        );
end exec_stage;

architecture arch of exec_stage is

    signal Y_MUX_A:         std_logic_vector(NBIT-1 downto 0);
    signal Y_MUX_B:         std_logic_vector(NBIT-1 downto 0);
    signal ALU_OUT_INT:     std_logic_vector(NBIT-1 downto 0);
    signal ZERO_INT:        std_logic;
    signal MUX_PC_SEL_SIG:  std_logic;

    component alu
        generic (NBIT: integer := 32);
        port (
            A:          in std_logic_vector(NBIT-1 downto 0);
            B:          in std_logic_vector(NBIT-1 downto 0);
            ALU_CODE:   in std_logic_vector(4 downto 0);
            Y:          out std_logic_vector(NBIT-1 downto 0)
        );
    end component;

begin

    alu_comp: alu
    generic map ( 
        NBIT => NBIT
        )
    port map (
        A => Y_MUX_A,
        B => Y_MUX_B,
        ALU_CODE => ALU_CODE,
        Y => ALU_OUT_INT
    );

    zero_proc: process(V_RA_IN)
    begin
        if unsigned(V_RA_IN) = 0 then
            ZERO_INT <= '1';
        else
            ZERO_INT <= '0';     
        end if;
    end process;

    branch_cond: process(EN, BRANCH, ZERO_INT, J_EN, J_COND)
    begin
        if BRANCH = '1' then
            if J_EN = '1' then
                MUX_PC_SEL_SIG <= '1';
            elsif (J_COND = '1' and ZERO_INT = '0') or (J_COND = '0' and ZERO_INT = '1') then
                MUX_PC_SEL_SIG <= '1';
            end if;
        else
            MUX_PC_SEL_SIG <= '0';
        end if;
    end process;

    mux_a_proc: process(V_RA_IN, NPC_IN, MUX_A_CTR)
    begin
        if MUX_A_CTR = '0' then
            Y_MUX_A <= V_RA_IN;
        else
            Y_MUX_A <= NPC_IN;     
        end if;
    end process;

    mux_b_proc: process(V_RB_IN, IMM_IN, MUX_B_CTR)
    begin
        if MUX_B_CTR = '0' then
            Y_MUX_B <= V_RB_IN;
        else
            Y_MUX_B <= IMM_IN;     
        end if;
    end process;

    reg_proc: process(CLK)
    begin
        if rising_edge(CLK) then
			if RST = '0' then
            	ALU_OUT     <= (others => '0');
            	V_RB_OUT    <= (others => '0');
            	A_RD_OUT    <= (others => '0');
            	NPC_OUT     <= (others => '0');
                MUX_PC_SEL  <= '0';
			else
				if EN = '1' then
					ALU_OUT     <= ALU_OUT_INT;
            		V_RB_OUT    <= V_RB_IN;
            		A_RD_OUT    <= A_RD_IN;
            		NPC_OUT     <= NPC_IN;
                    MUX_PC_SEL  <= MUX_PC_SEL_SIG;
				end if;
			end if;
        end if;
    end process;
    
end arch;
