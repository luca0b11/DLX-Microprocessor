library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_decode_stage is
end tb_decode_stage;

architecture test of tb_decode_stage is

    constant SIZE: integer := 32;
    signal CLK: std_logic := '0';
    -- enable signals
    signal A_EN : std_logic := '0';
    signal B_EN : std_logic := '0';
    signal IMM_EN : std_logic := '0';
    signal NPC_EN : std_logic := '0';
    signal WB_REG_EN : std_logic := '0';
    -- write enable
    signal WB_EN : std_logic := '0';
    -- data/address in
    signal NPC_IN : std_logic_vector(SIZE-1 downto 0) := (others=>'0');
    signal WB  : std_logic_vector(SIZE-1 downto 0) := (others=>'0');
    signal WB_ADDR : std_logic_vector(5-1 downto 0) := (others=>'0');
    signal IR	: std_logic_vector(SIZE-1 downto 0) := (others=>'0');
    -- data/address out
    signal A	: std_logic_vector(SIZE-1 downto 0);
    signal B	: std_logic_vector(SIZE-1 downto 0);
    signal IMM	: std_logic_vector(SIZE-1 downto 0);
    signal WB_OUT  : std_logic_vector(5-1 downto 0);
    signal NPC_OUT : std_logic_vector(SIZE-1 downto 0);

    component decode_stage is
    generic (
        NBIT : integer := 32;
        NWORD : integer := 32
        );
    port (
        CLK	: in std_logic;
        -- enable signal for each output register
        A_EN : in std_logic;
        B_EN : in std_logic;
        IMM_EN : in std_logic;
        NPC_EN : in std_logic;
        WB_REG_EN : in std_logic;
        -- write enable
        WB_EN : in std_logic;
        -- data/address in
        NPC_IN : in std_logic_vector(NBIT-1 downto 0);
        WB  : in std_logic_vector(NBIT-1 downto 0);
        WB_ADDR : in std_logic_vector(5-1 downto 0);
        IR	: in std_logic_vector(NBIT-1 downto 0);
        -- data/address out
        A	: out std_logic_vector(NBIT-1 downto 0);
        B	: out std_logic_vector(NBIT-1 downto 0);
        IMM	: out std_logic_vector(NBIT-1 downto 0);
        WB_OUT  : out std_logic_vector(5-1 downto 0);
        NPC_OUT : out std_logic_vector(NBIT-1 downto 0)
        );
    end component;

begin

  dut: decode_stage
    generic map (
        NBIT => SIZE,
        NWORD => SIZE
    )
    port map (
        CLK => CLK,
        A_EN => A_EN,
        B_EN => B_EN,
        IMM_EN => IMM_EN,
        NPC_EN => NPC_EN,
        WB_REG_EN => WB_REG_EN,
        WB_EN => WB_EN,
        NPC_IN => NPC_IN,
        WB => WB,
        WB_ADDR => WB_ADDR,
        IR => IR,
        A => A,
        B => B,
        IMM => IMM,
        WB_OUT => WB_OUT,
        NPC_OUT => NPC_OUT
    );

    clk_proc: process(CLK)
    begin
        CLK <= not(CLK) after 0.5 ns;
    end process;

    -- write some data in the register file
    WB_EN <= '1' after 1 ns;
    WB <= x"8040e001" after 2 ns, x"f040e002" after 4 ns;
    WB_ADDR <= "01001" after 2 ns, "11010" after 4 ns;

    -- enables
    A_EN <= '1' after 8 ns;
    B_EN <= '1' after 8 ns;
    IMM_EN <= '1' after 8 ns;
    WB_REG_EN <= '1' after 8 ns;
    -- R-type, J-type, I-type  instruction
    IR <= x"013AF802" after 8.5 ns, x"0D3AF802" after 11.5 ns, x"A93A5555" after 14.5 ns;

end test;
