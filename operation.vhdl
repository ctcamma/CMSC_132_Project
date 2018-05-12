library ieee,std,work;
use ieee.std_logic_1164.all;
use work.std_logic_textio.all;
use std.textio.all;
use work.STATE_CONSTANTS.all;

-- Entity Definition
entity operation is
	port (clock: in std_logic;
		fetch: out std_logic;
		decode: out std_logic;
		execute: out std_logic;
		memory: out std_logic;
		writeback: out std_logic;
		sign_flag: out std_logic;
		underflow_flag: out std_logic;
		overflow_flag: out std_logic;
		pc0: out std_logic;
		pc1: out std_logic;
		pc2: out std_logic;
		pc3: out std_logic);  			
end entity operation;
	
architecture operation of operation is
	type OPCODES is array (0 to 14) of std_logic_vector(0 to 20);
	shared variable instructions: OPCODES;
	shared variable counter: integer := 0;
begin
	file_io:
			process is
				file in_file : text open read_mode is "file_name.txt";
				variable in_line : line;
				variable opcode: std_logic_vector(0 to 20);
				variable operation: std_logic_vector(0 to 2);
				variable mode: std_logic;
				variable operand: std_logic_vector(0 to 4);

 			begin
 				while not endfile(in_file) loop
 					readline(in_file, in_line);
 					test_loop: for count in 0 to 20 loop
 	  					read(in_line, opcode(count));
 					end loop;

 					instructions(counter) := opcode;

 					operation(0) := instructions(counter)(0);
				    operation(1) := instructions(counter)(1);
				    operation(2) := instructions(counter)(2);
				    operation(2) := '1';
						
					report "operation: " & 	std_logic'image(operation(0)) &
											std_logic'image(operation(1)) &
											std_logic'image(operation(2));
					case operation is
						when load =>
							report "load";
						when addition =>
							report "addition";
						when subtraction =>
							report "subtraction";
						when multiplication =>
							report "multiplication";
						when division =>
							report "division";
						when modulo =>
							report "modulo";
						when others =>
							report "NONE";
					end case;
 					counter := counter + 1;
 				end loop;
 				assert false report "simulation done" severity note;
 				report "instructions: " & integer'image(counter);
 				wait;
		end process file_io;

		operates: process(clock) is
		begin
			
		end process operates;
end architecture operation;

