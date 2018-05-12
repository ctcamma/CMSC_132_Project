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
				variable opcode: std_logic_vector(14 downto 0);
 			begin
 				while not endfile(in_file) loop
 					readline(in_file, in_line);
 					test_loop: for count in 0 to 14 loop
 	  					read(in_line, opcode(count));
 	  					report std_logic'image(opcode(count));
 	  					wait for 1 ns;
 					end loop;

 				end loop;
 				assert false report "simulation done" severity note;
 				wait;
		end process;
end file_reading;
