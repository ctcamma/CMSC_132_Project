library ieee,std,work;
use ieee.std_logic_1164.all;
use work.std_logic_textio.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.STATE_CONSTANTS.all;

-- Entity Definition
entity operation is
	port (clock: in std_logic;
		fetch: inout std_logic;
		decode: inout std_logic;
		execute: inout std_logic;
		memory: inout std_logic;
		writeback: inout std_logic;
		sign_flag: inout std_logic;
		underflow_flag: inout std_logic;
		overflow_flag: inout std_logic;
		pc0: out std_logic;
		pc1: out std_logic;
		pc2: out std_logic;
		pc3: out std_logic);  			
end entity operation;
	
architecture operation of operation is
	-- (Noobgineer, https://stackoverflow.com/questions/36881697/array-of-std-logic-vector?rq=1)
	type OPCODES is array (0 to 14) of std_logic_vector(0 to OPERAND_BITS-1);
	shared variable instructions: OPCODES;
	shared variable counter: integer := 0;
	shared variable clock_cycle: integer := 0;
begin
	file_io:
			process is
				file in_file : text open read_mode is "file_name.txt";
				variable in_line : line;
				variable opcode: std_logic_vector(0 to OPERAND_BITS-1);
				variable operation: std_logic_vector(0 to 2);
				variable mode: std_logic;
				variable operand: std_logic_vector(0 to 4);

 			begin
 				while not endfile(in_file) loop
 					readline(in_file, in_line);
 					test_loop: for count in 3 to OPERAND_BITS-1 loop
 	  					read(in_line, opcode(count));
 					end loop;

 					opcode(0) := '0';
 					opcode(1) := '0';
 					opcode(2) := '0';

 					instructions(counter) := opcode;

 					operation(0) := instructions(counter)(3);
				    operation(1) := instructions(counter)(4);
				    operation(2) := instructions(counter)(5);
						
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
				variable cycle: unsigned(3 downto 0);
				variable i: integer := 0;
				variable status: std_logic_vector(0 to 2);
				variable opcode: std_logic_vector(0 to OPERAND_BITS-1);
				variable operation: std_logic_vector(0 to 2);
				variable mode: std_logic;
				variable operand: std_logic_vector(0 to 4);		

		begin
			if rising_edge(clock) then
				i := 0;
				clock_cycle := clock_cycle + 1;
				cycle := to_unsigned(clock_cycle, 4);
				pc0 <= cycle(0);
				pc1 <= cycle(1);
				pc2 <= cycle(2);
				pc3 <= cycle(3);

				if clock_cycle <= counter then
					while i < clock_cycle loop

						status(0) := instructions(i)(0);
						status(1) := instructions(i)(1);
						status(2) := instructions(i)(2);

						report "status" & std_logic'image(status(0)) &
											std_logic'image(status(1)) &
											std_logic'image(status(2));

						case status is
							when toFetch =>
								if(fetch = '0') then
									report "fetch";
									fetch <= '1';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
									instructions(i)(2) := '1';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
								end if;
							when toDecode =>
								if(decode = '0') then
									report "decode";
									decode <= '1';
									instructions(i)(1) := '1';
									instructions(i)(2) := '0';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
								end if;
							when toExecute =>
								if(execute = '0') then
									report "execute";
									execute <= '1';
									instructions(i)(2) := '1';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
								end if;
							when toMemory =>
								if(memory = '0') then
									report "memory";
									memory <= '1';
									instructions(i)(0) := '1';
									instructions(i)(1) := '0';
									instructions(i)(2) := '0';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
								end if;
							when toWrite =>
								if(writeback = '0') then
									report "writeback";
									writeback <= '1';
									instructions(i)(2) := '1';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
								end if;
							when others =>
								report "";
						end case;

						i := i + 1;
						report "i: " & integer'image(i);
					end loop;


				else
					while i < counter loop
						status(0) := instructions(i)(0);
						status(1) := instructions(i)(1);
						status(2) := instructions(i)(2);

						report "status" & std_logic'image(status(0)) &
											std_logic'image(status(1)) &
											std_logic'image(status(2));

						case status is
							when toFetch =>
								if(fetch = '0') then
									report "fetch";
									fetch <= '1';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
									instructions(i)(2) := '1';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
								end if;
							when toDecode =>
								if(decode = '0') then
									report "decode";
									decode <= '1';
									instructions(i)(1) := '1';
									instructions(i)(2) := '0';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
								end if;
							when toExecute =>
								if(execute = '0') then
									report "execute";
									execute <= '1';
									instructions(i)(2) := '1';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
								end if;
							when toMemory =>
								if(memory = '0') then
									report "memory";
									memory <= '1';
									instructions(i)(0) := '1';
									instructions(i)(1) := '0';
									instructions(i)(2) := '0';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
								end if;
							when toWrite =>
								if(writeback = '0') then
									report "writeback";
									writeback <= '1';
									instructions(i)(2) := '1';
									report std_logic'image(instructions(i)(0)) &
											std_logic'image(instructions(i)(1)) &
											std_logic'image(instructions(i)(2));
								end if;
							when others =>
								report "";
						end case;

						i := i + 1;
						report "i: " & integer'image(i);
					end loop;
				end if;



			else
				fetch <= '0';
				decode <= '0';
				execute <= '0';
				memory <= '0';
				writeback <= '0';
				sign_flag <= '0';
				underflow_flag <= '0';
				overflow_flag <= '0';
				pc0 <= '0';
				pc1 <= '0';
				pc2 <= '0';
				pc3 <= '0';
			end if;
		end process operates;

end architecture operation;

