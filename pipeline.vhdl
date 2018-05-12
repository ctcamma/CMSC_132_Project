library ieee,std,work;
use ieee.std_logic_1164.all;
use work.std_logic_textio.all;
use std.textio.all;

entity pipeline is
end pipeline;

architecture file_reading of pipeline is
	begin
		file_io:
			process is
				file in_file : text open read_mode is "file_name.txt";
				variable in_line : line;
				variable opcode: std_logic_vector(20 downto 0);
				variable operation: std_logic_vector(2 downto 0);
				variable mode: std_logic;
				variable operand: std_logic_vector(4 downto 0);
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

 				end loop;
 				assert false report "simulation done" severity note;
 				wait;
		end process;
end file_reading;
