library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;

-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
entity instruction_memory is
	generic (
		file_path	: string := "";
		ENTRIES		: integer := 128;
		WORD_SIZE	: integer := 32;
        ADDR_SIZE	: integer := 32
        
	);
	port (
		RST					: in std_logic;
		ADDR				: in std_logic_vector(ADDR_SIZE - 1 downto 0);
		ENABLE     			: in std_logic;
		DATA_OUT			: out std_logic_vector(WORD_SIZE - 1 downto 0)
	);
end instruction_memory;

architecture behavioral of instruction_memory is

	type ROMEM is array (0 to ENTRIES-1) of integer;
	signal memory : ROMEM;

begin

	-- purpose: This process is in charge of filling the Instruction RAM with the firmware
	mem_proc: process (RST, ENABLE, ADDR)

		file mem_fp: text;
		variable file_line : line;
		variable index : integer;
		variable tmp_data_u : std_logic_vector(WORD_SIZE-1 downto 0);

	begin
		if RST = '0' then
			file_open(
				mem_fp,
				file_path,
				READ_MODE
			);
            
            index := 0;
			while (not endfile(mem_fp)) loop
				readline(mem_fp,file_line);
				hread(file_line,tmp_data_u);
				memory(index) <= conv_integer(unsigned(tmp_data_u));
				index := index + 1;
			end loop;

			file_close(mem_fp);

		elsif ENABLE = '1' then
            DATA_OUT <= conv_std_logic_vector(memory(conv_integer(unsigned(ADDR))/4),WORD_SIZE);

		end if;

    end process mem_proc;

end behavioral;
