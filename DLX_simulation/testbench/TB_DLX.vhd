library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_dlx is
end tb_dlx;

architecture TEST of tb_dlx is

    component dlx is
        generic (
            NBIT: integer
        );
        port (
            CLK:            in std_logic;
            RST:            in std_logic;
            -- I_Mem signals
            MEM_DATA_I:     in std_logic_vector(NBIT-1 downto 0);   -- instruction from I_Mem
            MEM_ADDR_I:     out std_logic_vector(NBIT-1 downto 0);  -- instruction address (PC)
            MEM_EN_I:       out std_logic;

            -- D_Mem signals
            MEM_DATA_READ: in std_logic_vector(NBIT-1 downto 0);
            MEM_DATA_WRITE: out std_logic_vector(NBIT-1 downto 0);
            MEM_ADDR: out std_logic_vector(NBIT-1 downto 0);
            MEM_DATA_EN: out std_logic;
            RDNOTWR: out std_logic
        );
    end component;

    component data_memory is
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
    end component;

    component instruction_memory is
        generic (
            file_path	: string := "test.asm.mem";
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
    end component;

    constant NBIT       : integer := 32;

    signal clk_tb           : std_logic := '0';
    signal reset_tb         : std_logic := '0';

    signal mem_data_i_tb    : std_logic_vector(NBIT-1 downto 0);
    signal mem_addr_i_tb    : std_logic_vector(NBIT-1 downto 0);
    signal mem_en_i_tb    : std_logic;

    signal mem_data_read_tb : std_logic_vector(NBIT-1 downto 0);
    signal mem_data_write_tb: std_logic_vector(NBIT-1 downto 0);
    signal mem_addr_d_tb      : std_logic_vector(NBIT-1 downto 0);
    signal mem_data_en_tb    : std_logic;
    signal readnotwrite_tb    : std_logic;

begin

-- MUL instantiation
    dut: dlx
        generic map(
            NBIT => 32
        )
        port map(
            CLK             => clk_tb,
            RST             => reset_tb,
            -- I_Mem signals
            MEM_DATA_I      => mem_data_i_tb,
            MEM_ADDR_I      => mem_addr_i_tb,
            MEM_EN_I        => mem_en_i_tb,
            
            -- D_Mem signals
            MEM_DATA_READ   => mem_data_read_tb,
            MEM_DATA_WRITE  => mem_data_write_tb,
            MEM_ADDR        => mem_addr_d_tb,
            MEM_DATA_EN     => mem_data_en_tb,
            RDNOTWR         => readnotwrite_tb
        );

    dmem: data_memory
        generic map(
            file_path_init  => "testbench/files/mem/data_mem_init.txt",
            file_path_dest  => "testbench/files/mem/data_mem.txt",
            ENTRIES         => 128,
            WORD_SIZE       => 32,
            ADDR_SIZE       => 32
        )
        port map(
            CLK				=> clk_tb,
            RST             => reset_tb,
            ADDR            => mem_addr_d_tb,
            ENABLE          => mem_data_en_tb,
            READNOTWRITE    => readnotwrite_tb,
            DATA_IN         => mem_data_write_tb,
            DATA_OUT        => mem_data_read_tb
        );

    imem: instruction_memory
        generic map(
            file_path       => "testbench/files/mem/test.mem",
            ENTRIES         => 128,
            WORD_SIZE       => 32,
            ADDR_SIZE       => 32
        )
        port map(
            RST             => reset_tb,
            ADDR            => mem_addr_i_tb,
            ENABLE          => mem_en_i_tb,
            DATA_OUT        => mem_data_i_tb
        );


    clk_tb <= not clk_tb after 1 ns;
    reset_tb <= '0', '1' after 5.5 ns; 

--    -- PROCESS FOR TESTING  ---------
--    stim: process
--    begin
--        
--        mem_data_read_tb <= (others => '0');
--
--        wait for 5.5 ns;
--
--        --ADDI R2 R0 #9
--        mem_data_i_tb <= X"20020009";
--        wait for 2 ns;
--
--        --SUBI R5 R12 #4
--        mem_data_i_tb <= X"29850004";
--        wait for 2 ns;
--
--        -- NOP
--        mem_data_i_tb <= X"54000000";
--        wait for 2 ns;
--
--        -- NOP
--        mem_data_i_tb <= X"54000000";
--        wait for 2 ns;
--        
--        -- NOP
--        mem_data_i_tb <= X"54000000";
--        wait for 2 ns;
--
--        -- NOP
--        mem_data_i_tb <= X"54000000";
--        wait for 2 ns;
--
--        -- OR R3 R2 R5
--        mem_data_i_tb <= X"00451819";
--        wait for 2 ns;
--
--        --ADDI R6 R0 #5
--        mem_data_i_tb <= X"20050005";
--        wait for 2 ns;
--
--        --SUBI R9 R2 #15
--        mem_data_i_tb <= X"28A9000F";
--        wait for 2 ns;
--
--        -- BEQZ R0 0x025C
--        mem_data_i_tb <= X"1060025C";
--        wait for 2ns 
--
--        --ADDI R11 R0 #9
--        mem_data_i_tb <= X"200B0005";
--        wait;
--
--        -- AFTER ALL
--        -- RO = 0
--        -- R2 = 9
--        -- R3 = FFFFFFFD
--        -- R5 = -4
--        -- R6 = 5
--        -- R9 = -6
--
--    end process stim;
--

end TEST;


































