library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use work.myTypes.all;
use ieee.std_logic_unsigned.all;

entity decode_stage is
  generic (
    NBIT : integer := 32;
	NWORD : integer := 32;
	NADDR : integer := 5);
  port (
	CLK	: in std_logic;
	-- enable/reset signal 
	EN : in std_logic;
	RST : in std_logic;
	--RST_RF : in std_logic;
	-- write enable
	WB_EN : in std_logic;
	JL_EN : in std_logic;
	-- data/address in
	NPC_IN : in std_logic_vector(NBIT-1 downto 0);
	WB  : in std_logic_vector(NBIT-1 downto 0);
	WB_ADDR : in std_logic_vector(NADDR-1 downto 0);
	IR	: in std_logic_vector(NBIT-1 downto 0);
	-- data/address out
	A	: out std_logic_vector(NBIT-1 downto 0);
	B	: out std_logic_vector(NBIT-1 downto 0);
	IMM	: out std_logic_vector(NBIT-1 downto 0);
	WB_OUT  : out std_logic_vector(NADDR-1 downto 0);
	NPC_OUT : out std_logic_vector(NBIT-1 downto 0)
    );
end decode_stage;

architecture arch of decode_stage is

	signal op_code : std_logic_vector(OP_CODE_SIZE-1 downto 0);
	signal imm_reg : std_logic_vector(NBIT-1 downto 0);
	signal npc_reg : std_logic_vector(NBIT-1 downto 0);
	signal rd1_addr : std_logic_vector(NADDR-1 downto 0);
	signal rd2_addr : std_logic_vector(NADDR-1 downto 0);
	signal wr_addr : std_logic_vector(NADDR-1 downto 0);
	signal wb_address : std_logic_vector(NADDR-1 downto 0);
	signal wb_data : std_logic_vector(NBIT-1 downto 0);
	signal a_reg	: std_logic_vector(NBIT-1 downto 0);
	signal b_reg	: std_logic_vector(NBIT-1 downto 0);
	
	component register_file is
		generic (
			NBIT: integer := 32;
			NWORD: integer := 32;
			NADDR : integer := 5
			);
		port (
			CLK: 		IN std_logic;
			RESET: 		IN std_logic;
			RD1: 		IN std_logic;
			RD2:		IN std_logic;
			WR: 		IN std_logic;
			ADD_WR: 	IN std_logic_vector(NADDR-1 downto 0);
			ADD_RD1: 	IN std_logic_vector(NADDR-1 downto 0);
			ADD_RD2: 	IN std_logic_vector(NADDR-1 downto 0);
			DATAIN: 	IN std_logic_vector(NBIT-1 downto 0);
			OUT1: 		OUT std_logic_vector(NBIT-1 downto 0);
			OUT2: 		OUT std_logic_vector(NBIT-1 downto 0)
			);
   end component;
		 
  begin

	RF: register_file
    generic map (
		NBIT => NBIT,
		NWORD => NWORD
		)
    port map (
		CLK => CLK,
		RESET => RST,
		RD1 => EN,
		RD2 => EN,
		WR => WB_EN,
		ADD_WR => wb_address,	
		ADD_RD1 => rd1_addr,
		ADD_RD2 => rd2_addr,
		DATAIN => WB,
		OUT1 => a_reg,	
		OUT2 => b_reg
	);

	op_code <= IR(NBIT - 1 downto NBIT - OP_CODE_SIZE);

	mux_jal: process(WB, WB_ADDR)
	begin
		if JL_EN = '0' then
			wb_address <= WB_ADDR;
		else
			wb_address <= (others => '1'); -- indirizzo 31 rf
		end if;
	end process;

	decode: process(IR, op_code)
	begin
		imm_reg <= (others => '0');
		case to_integer(unsigned(op_code)) is
			when 0 | 1 =>	-- R-type
				rd1_addr <= IR(25 downto 21);
				rd2_addr <= IR(20 downto 16);
				wr_addr <= IR(15 downto 11);
				imm_reg(11 downto 0) <= IR(11 downto 0);
			when 2 | 3  =>	-- J-type
				rd1_addr <= (others => '0');
				rd2_addr <= (others => '0');
				wr_addr <= (others => '0');
				imm_reg(25 downto 0) <= IR(25 downto 0);
				if (IR(25) = '1') then
					imm_reg(31 downto 26)  <= (others => '1');
				else
					imm_reg(31 downto 26)  <= (others => '0');
				end if;
			when 43 =>	-- Store
				rd1_addr <= IR(25 downto 21);
				rd2_addr <= IR(20 downto 16);
				wr_addr <= (others => '0');
				imm_reg(15 downto 0) <= IR(15 downto 0);
				if (IR(15) = '1') then
					imm_reg(31 downto 16)  <= (others => '1');
				else
					imm_reg(31 downto 16)  <= (others => '0');
				end if;
			when others =>	-- I-type
				rd1_addr <= IR(25 downto 21);
				rd2_addr <= (others => '0');
				wr_addr <= IR(20 downto 16);
				imm_reg(15 downto 0) <= IR(15 downto 0);
				if (IR(15) = '1') then
					imm_reg(31 downto 16)  <= (others => '1');
				else
					imm_reg(31 downto 16)  <= (others => '0');
				end if;

		end case;
	end process;

	registers: process(CLK)
	begin
		if rising_edge(CLK) then
			if RST = '0' then
				IMM <= (others => '0');
				NPC_OUT <= (others => '0');
				WB_OUT <= (others => '0');
				A <= (others => '0');
				B <= (others => '0');
			else
				if EN = '1' then
					IMM <= imm_reg;
					NPC_OUT <= NPC_IN;
					WB_OUT <= wr_addr;
					A <= a_reg;
					B <= b_reg;
				end if;
			end if;
		end if;
	end process;

end arch;
