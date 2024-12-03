library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_signed.all;
use work.myTypes.all;

entity alu is
  generic (NBIT: integer := 32);
  port  (
        A:          in std_logic_vector(NBIT-1 downto 0);
        B:          in std_logic_vector(NBIT-1 downto 0);
        ALU_CODE:   in std_logic_vector(4 downto 0);
        Y:          out std_logic_vector(NBIT-1 downto 0)
        );
end alu;

architecture arch of alu is

    signal Y_P4_ADDER:          std_logic_vector(NBIT-1 downto 0);
    signal A_P4_ADDER:          std_logic_vector(NBIT-1 downto 0);
    signal B_P4_ADDER:          std_logic_vector(NBIT-1 downto 0);

    signal P_BOOTHMUL:          std_logic_vector(2*NBIT-1 downto 0);
    signal A_BOOTHMUL:          std_logic_vector(NBIT-1 downto 0);
    signal B_BOOTHMUL:          std_logic_vector(NBIT-1 downto 0);

    component p4_adder is
    generic (
      NBIT           : integer := 32;
      NBIT_PER_BLOCK : integer := 4
    );
    port (
      A :       in	std_logic_vector(NBIT-1 downto 0);
      B :     	in	std_logic_vector(NBIT-1 downto 0);
      Cin :	    in	std_logic;
      S :	    out	std_logic_vector(NBIT-1 downto 0);
      Cout :	out	std_logic);
    end component;

    component BOOTHMUL is
        generic (NBIT: integer);
        port ( A: in std_logic_vector(NBIT - 1 downto 0);
               B: in std_logic_vector(NBIT - 1 downto 0);
               P: out std_logic_vector(2*NBIT - 1 downto 0)
             );
    end component;

begin

    P4_add: p4_adder
    generic map(NBIT, 4)
    port map (
        A   => A_P4_ADDER,
        B   => B_P4_ADDER,
        Cin => '0',
        S   => Y_P4_ADDER,
        Cout => open
    );

    b_mul: BOOTHMUL
    generic map (NBIT => NBIT)
    port map (
        A => A_BOOTHMUL,
        B => B_BOOTHMUL,
        P => P_BOOTHMUL
    );


    alu_proc: process(A, B, ALU_CODE, Y_P4_ADDER, P_BOOTHMUL)
    begin
        case ALU_CODE is
            when OP_ALU_ADD => -- ADD
                A_P4_ADDER <= A;
                B_P4_ADDER <= B;
                Y <= Y_P4_ADDER;
            when OP_ALU_SUB => -- SUB
                A_P4_ADDER <= A;
                B_P4_ADDER <= std_logic_vector(-signed(B));
                Y <= Y_P4_ADDER;
            when OP_ALU_SUBU => -- SUB
                A_P4_ADDER <= std_logic_vector(unsigned(A));
                B_P4_ADDER <= std_logic_vector(-signed(unsigned(B)));
                Y <= Y_P4_ADDER;
            when OP_ALU_MULT => -- MULT
                A_BOOTHMUL <= std_logic_vector(signed(A));
                B_BOOTHMUL <= std_logic_vector(signed(B));
                Y <= P_BOOTHMUL(NBIT-1 downto 0);
            when OP_ALU_MULTU => -- MULTU
                A_BOOTHMUL <= std_logic_vector(unsigned(A));
                B_BOOTHMUL <= std_logic_vector(unsigned(B));
                Y <= P_BOOTHMUL(NBIT-1 downto 0);
            when OP_ALU_AND => -- AND
                Y <= A and B;
            when OP_ALU_OR => -- OR
                Y <= A or B;
            when OP_ALU_XOR => -- XOR
                Y <= A xor B;
            when OP_ALU_SGE => -- SGE (Set if Greater or Equal)
                if unsigned(A) >= unsigned(B) then
                    Y(0) <= '1';
                    Y(NBIT-1 downto 1) <= (others => '0');
                else
                    Y <= (others => '0');
                end if;
            when OP_ALU_SGT => -- SGE (Set if Greater)
                if unsigned(A) > unsigned(B) then
                    Y(0) <= '1';
                    Y(NBIT-1 downto 1) <= (others => '0');
                else
                    Y <= (others => '0');
                end if;
            when OP_ALU_SLE => -- SLE (Set if Less or Equal)
                if unsigned(A) <= unsigned(B) then
                    Y(0) <= '1';
                    Y(NBIT-1 downto 1) <= (others => '0');
                else
                    Y <= (others => '0');
                end if;
            when OP_ALU_SLT => -- SLE (Set if Less)
                if unsigned(A) < unsigned(B) then
                    Y(0) <= '1';
                    Y(NBIT-1 downto 1) <= (others => '0');
                else
                    Y <= (others => '0');
                end if;
            when OP_ALU_SNE => -- SNE (Set if Not Equal)
                if A /= B then
                    Y(0) <= '1';
                    Y(NBIT-1 downto 1) <= (others => '0');
                else
                    Y <= (others => '0');
                end if;
            when OP_ALU_SEQ => -- SEQ (Set if  Equal)
                if A = B then
                    Y(0) <= '1';
                    Y(NBIT-1 downto 1) <= (others => '0');
                else
                    Y <= (others => '0');
                end if;
            when OP_ALU_SLL => -- SLL (Shift Left Logical)
                Y <= std_logic_vector(unsigned(A) sll to_integer(unsigned(B)));
            when OP_ALU_SRL => -- SRL (Shift Right Logical)
                Y <= std_logic_vector(unsigned(A) srl to_integer(unsigned(B)));
--            when OP_ALU_SRA => -- SRA (Shift Right Logical)
--                Y(NBIT-1-to_integer(unsigned(B)) downto 0) <= A(NBIT-1 downto to_integer(unsigned(B)));
--                Y(NBIT-1 downto NBIT-1-to_integer(unsigned(B))) <= (others => A(NBIT-1));
            when others =>
                Y <= (others => '0');
        end case;
    end process;

end arch;