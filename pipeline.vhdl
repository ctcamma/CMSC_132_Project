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
end package;


library ieee,std,work;
use ieee.std_logic_1164.all;
use work.std_logic_textio.all;
use std.textio.all;
use work.STATE_CONSTANTS.all;

entity pipeline is
end pipeline;

architecture file_reading of pipeline is
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
 	  					wait for 1 ns;
 					end loop;

				    operation(0) := opcode(0);
				    operation(1) := opcode(1);
				    operation(2) := opcode(2);
 					
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

 				end loop;
 				assert false report "simulation done" severity note;
 				wait;
		end process;
end file_reading;
