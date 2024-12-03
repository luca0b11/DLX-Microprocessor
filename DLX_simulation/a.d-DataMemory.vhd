library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library std;
use std.textio.all;

entity data_memory is
	generic(
        file_path_init	    : string := "";
        file_path_dest	    : string := "";
		ENTRIES		        : integer := 128;
		WORD_SIZE	        : integer := 32;
        ADDR_SIZE	        : integer := 32
		);
	port (
		CLK				: in std_logic;
		RST             : in std_logic;
		ADDR		    : in std_logic_vector(ADDR_SIZE - 1 downto 0);
		ENABLE			: in std_logic;
		READNOTWRITE    : in std_logic;
		DATA_IN         : in std_logic_vector(WORD_SIZE-1 downto 0);
		DATA_OUT		: out std_logic_vector(WORD_SIZE-1 downto 0)
		);
end data_memory;

architecture behavioral of data_memory is

	type RWMEM is array (0 to ENTRIES - 1) of std_logic_vector(WORD_SIZE - 1 downto 0);
	signal memory : RWMEM;

	procedure refresh_file(data_mem: in RWMEM; path_file: string) is
		variable index: natural range 0 to ENTRIES;
		file wr_file: text;
		variable line_in: line;
	begin
		index:=0;
		file_open(wr_file, path_file, WRITE_MODE);
		while index < ENTRIES loop
			hwrite(line_in,data_mem(index));
			writeline(wr_file,line_in);
			index := index + 1;
		end loop;
	end refresh_file;



begin  
	write_proc: process (RST, ENABLE, ADDR) -- CLK

		file mem_fp: text;
        variable file_line : line;
		variable index: integer range 0 to ENTRIES;
		variable tmp_data_u : std_logic_vector(WORD_SIZE-1 downto 0);

	begin
		--if rising_edge(CLK) then
			if RST = '0' then
				file_open(
					mem_fp,
					file_path_init,
					READ_MODE
				);
			
        	    index := 0;
				while (not endfile(mem_fp)) loop
					readline(mem_fp,file_line);
					hread(file_line,tmp_data_u);
					memory(index) <= tmp_data_u;  -- conv_integer ??
					index := index + 1;
				end loop;

				file_close(mem_fp);

			elsif ENABLE = '1' then

				if (READNOTWRITE = '0') then
        	        -- WRITE TO MEMORY
					memory(to_integer(unsigned(ADDR))) <= DATA_IN(WORD_SIZE - 1 downto 0); 
				else
        	        -- READ FROM MEMORY
					DATA_OUT <= memory(to_integer(unsigned(ADDR)));
				end if;
			end if;
		--end if;
	end process;

	refresh_file(memory, file_path_dest); -- refresh the file

end behavioral;
