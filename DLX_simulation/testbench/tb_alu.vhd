library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.myTypes.all;

entity tb_alu is
end tb_alu;

architecture testbench of tb_alu is
    constant NBIT : integer := 32;

    signal A       : std_logic_vector(NBIT-1 downto 0) := (others => '0');
    signal B       : std_logic_vector(NBIT-1 downto 0) := (others => '0');
    signal ALU_CODE: std_logic_vector(4 downto 0) := (others => '0');
    signal Y       : std_logic_vector(NBIT-1 downto 0);

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

    uut: alu
        port map (
            A => A,
            B => B,
            ALU_CODE => ALU_CODE,
            Y => Y
        );

    stim_proc: process
    begin
        -- Test ADD (A + B)
        A <= x"00000005";
        B <= x"00000003";
        ALU_CODE <= OP_ALU_ADD;
        wait for 10 ns;

        -- Test SRA (A - B)
        A <= x"F0000000";
        B <= x"00000004";
        ALU_CODE <= OP_ALU_SRA;
        wait for 10 ns;

        -- Test SUB (A - B)
        A <= x"0F000000";
        B <= x"00000004";
        ALU_CODE <= OP_ALU_SRA;
        wait for 10 ns;

        -- Test MUL (A * B)
        A <= x"00000008";
        B <= x"00000003";
        ALU_CODE <= OP_ALU_MULT;
        wait for 10 ns;

        -- Test MUL (A * B)
        A <= x"00000008";
        B <= x"FFFFFFFD"; --32
        ALU_CODE <= OP_ALU_MULTU;
        wait for 10 ns;

        -- Test AND (A and B)
        A <= x"F0F0F0F0";
        B <= x"0F0F0F0F";
        ALU_CODE <= OP_ALU_AND;
        wait for 10 ns;

        -- Test OR (A or B)
        A <= x"F0F0F0F0";
        B <= x"0F0F0F0F";
        ALU_CODE <= OP_ALU_OR;
        wait for 10 ns;

        -- Test XOR (A xor B)
        A <= x"F0F0F0F0";
        B <= x"0F0F0F0F";
        ALU_CODE <= OP_ALU_XOR;
        wait for 10 ns;

        -- Test SGE (A >= B) TRUE
        A <= x"00000005";
        B <= x"00000003";
        ALU_CODE <= OP_ALU_SGE;
        wait for 10 ns;

        -- Test SGE (A >= B) FALSE
        A <= x"00000005";
        B <= x"00000007";
        ALU_CODE <= OP_ALU_SGE;
        wait for 10 ns;

        -- Test SLE (A <= B) TRUE
        A <= x"00000002";
        B <= x"00000008";
        ALU_CODE <= OP_ALU_SLE;
        wait for 10 ns;

        -- Test SLE (A <= B) FALSE
        A <= x"0000000A";
        B <= x"00000008";
        ALU_CODE <= OP_ALU_SLE;
        wait for 10 ns;

        -- Test SNE (A != B) TRUE
        A <= x"00000005";
        B <= x"00000003";
        ALU_CODE <= OP_ALU_SNE;
        wait for 10 ns;

        -- Test SNE (A != B) FALSE
        A <= x"00000005";
        B <= x"00000005";
        ALU_CODE <= OP_ALU_SNE;
        wait for 10 ns;

        -- Test SLL (Shift Left Logical)
        A <= x"00000001";
        B <= x"00000002";
        ALU_CODE <= OP_ALU_SLL;
        wait for 10 ns;

        -- Test SRL (Shift Right Logical)
        A <= x"00000004";
        B <= x"00000001";
        ALU_CODE <= OP_ALU_SRL;
        wait for 10 ns;

        -- Termina la simulazione
        wait;
    end process;

end testbench;
