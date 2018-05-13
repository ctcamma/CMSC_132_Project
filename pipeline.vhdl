library ieee,std,work;
use ieee.std_logic_1164.all;
use work.std_logic_textio.all;
use std.textio.all;

package STATE_CONSTANTS is
	constant load: std_logic_vector(0 to 2) := "000";
	constant addition: std_logic_vector(0 to 2) := "001";
	constant subtraction: std_logic_vector(0 to 2) := "010";
	constant multiplication: std_logic_vector(0 to 2) := "011";
	constant division: std_logic_vector(0 to 2) := "100";
	constant modulo: std_logic_vector(0 to 2) := "101";


	constant toFetch: std_logic_vector(0 to 2) := "000";
	constant toDecode: std_logic_vector(0 to 2) := "001";
	constant toExecute: std_logic_vector(0 to 2) := "010";
	constant toMemory: std_logic_vector(0 to 2) := "011";
	constant toWrite: std_logic_vector(0 to 2) := "100";
	constant toEnd: std_logic_vector(0 to 2) := "101";

	constant OPERAND_BITS: integer := 24;
	constant REGISTER_COUNT: integer := 32;
end package;


library ieee,std,work;
use ieee.std_logic_1164.all;
use work.std_logic_textio.all;
use std.textio.all;
use work.STATE_CONSTANTS.all;

entity pipeline is
	constant PERIOD1: time := 1 ns; -- clock period
end pipeline;

architecture file_reading of pipeline is
	signal clock: std_logic := '1';
	signal fetch: std_logic := '1';
	signal decode: std_logic := '0';
	signal execute: std_logic := '0';
	signal memory: std_logic := '0';
	signal writeback: std_logic := '0';
	signal sign_flag: std_logic := '0';
	signal underflow_flag: std_logic := '0';
	signal overflow_flag: std_logic := '0';
	signal zero_flag: std_logic := '0';
	signal pc0: std_logic := '0';
	signal pc1: std_logic := '0';
	signal pc2: std_logic := '0';
	signal pc3: std_logic := '0';

	component operation is
		 port (clock: in std_logic;
			fetch: inout std_logic;
			decode: inout std_logic;
			execute: inout std_logic;
			memory: inout std_logic;
			writeback: inout std_logic;
			sign_flag: inout std_logic;
			underflow_flag: inout std_logic;
			overflow_flag: inout std_logic;
			zero_flag: inout std_logic;
			pc0: out std_logic;
			pc1: out std_logic;
			pc2: out std_logic;
			pc3: out std_logic); -- the signal data input			  				
	end component operation;

	begin
		uut: component operation port map(clock, fetch, decode, execute, memory, writeback, sign_flag, underflow_flag,
											overflow_flag, zero_flag, pc0, pc1, pc2, pc3);
		clk: clock <= not clock after (PERIOD1/2);


end file_reading;
