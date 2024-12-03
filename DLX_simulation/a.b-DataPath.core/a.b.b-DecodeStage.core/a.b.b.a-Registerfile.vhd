library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use WORK.all;

entity register_file is
 generic (NBIT: integer;
          NWORD: integer;
          NADDR: integer := 5);
 port ( CLK: 		IN std_logic;
        RESET: 	IN std_logic;
        -- ENABLE: 	IN std_logic;
        RD1: 		IN std_logic;
        RD2: 		IN std_logic;
        WR: 		IN std_logic;
        ADD_WR: 	IN std_logic_vector(NADDR-1 downto 0);
        ADD_RD1: 	IN std_logic_vector(NADDR-1 downto 0);
        ADD_RD2: 	IN std_logic_vector(NADDR-1 downto 0);
        DATAIN: 	IN std_logic_vector(NBIT-1 downto 0);
        OUT1: 		OUT std_logic_vector(NBIT-1 downto 0);
	      OUT2: 		OUT std_logic_vector(NBIT-1 downto 0));
end register_file;

architecture A of register_file is

  -- suggested structures
  subtype REG_ADDR is natural range 0 to (NWORD-1); -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBIT-1 downto 0);
	signal REGISTERS : REG_ARRAY;

  constant ZERO_VECTOR : std_logic_vector(ADD_WR'range) := (others => '0');
       
begin 
-- write your RF code
  
  rf_read: process(RESET, CLK, ADD_RD1, ADD_RD2)
    begin
        if RESET = '0' then
          OUT1 <= (others => '0');
          OUT2 <= (others => '0');
        else
            if RD1 = '1' then
              OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1)));                     
            end if;
               
            if RD2 = '1' then
              OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2)));
            end if;            
          end if;          
    end process;

    rf_write: process(RESET, CLK)
    begin
      if RESET = '0' then
        REGISTERS <= (others => (others => '0'));
      else
        if rising_edge(CLK) then
          if (WR = '1' and ADD_WR /= ZERO_VECTOR) then
            REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
          end if;
        end if;  
      end if;       
    end process;  

end A;
