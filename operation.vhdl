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
		zero_flag: inout std_logic;
		pc0: out std_logic;
		pc1: out std_logic;
		pc2: out std_logic;
		pc3: out std_logic);  			
end entity operation;
	
architecture operation of operation is
	-- (Noobgineer, https://stackoverflow.com/questions/36881697/array-of-std-logic-vector?rq=1)
	type OPCODES is array (0 to 14) of std_logic_vector(0 to OPERAND_BITS-1);
	type int_array is array (0 to REGISTER_COUNT-1) of integer;
	shared variable instructions: OPCODES;
	shared variable fetchStall: integer := 0;
	shared variable decodeStall: integer := 0;
	shared variable executeStall: integer := 0;
	shared variable memoryStall: integer := 0;
	shared variable instructionCount: integer := 0;
	shared variable clock_cycle: integer := 0;
	shared variable registers: std_logic_vector(0 to REGISTER_COUNT-1) := (others => '0');
	shared variable reg_value: int_array := (others => 0);
	shared variable newlyFreed: integer := -1;
	shared variable iterator: integer := 0;
begin
	file_io:																							-- file reading per line
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

 					opcode(0) := '0';																	-- initialize the stage for each instruction being red (F,D,E,M,W)
 					opcode(1) := '0';
 					opcode(2) := '0';

 					instructions(instructionCount) := opcode;

 					instructionCount := instructionCount + 1;											-- update the format of instructions (add 3 bits (initialized stage) before the instruction)
 				end loop;
 				assert false report "simulation done" severity note;
 				report "instructions: " & integer'image(instructionCount);
 				wait;
		end process file_io;

		operates: process(clock) is 																	-- pipelining body
				variable cycle: unsigned(3 downto 0);
				variable i: integer := 0;
				variable status: std_logic_vector(0 to 2);
				variable opcode: std_logic_vector(0 to OPERAND_BITS-1);
				variable operation: std_logic_vector(0 to 2);
				variable mode: std_logic;
				variable operand: std_logic_vector(0 to 4);
				variable register_busy: integer;

				variable immediateBinary: unsigned(0 to 1);
				variable immediateBinaryVector: std_logic_vector(0 to 1);
				variable destination: integer;
				variable source1: integer;
				variable source2: integer;
		begin
			if rising_edge(clock) then																	-- changes in the pipeline for every rising edge of the clock
				i := 0;
				clock_cycle := clock_cycle + 1;
				cycle := to_unsigned(clock_cycle, 4);
				pc0 <= cycle(0);																		-- initialization of PC
				pc1 <= cycle(1);
				pc2 <= cycle(2);
				pc3 <= cycle(3);

				if clock_cycle <= instructionCount then 
					iterator := clock_cycle;
				else
					iterator := instructionCount;
				end if;

				while i < iterator loop
					status(0) := instructions(i)(0);
					status(1) := instructions(i)(1);
					status(2) := instructions(i)(2);


					case status is 																		-- checks the current stage of the instruction 
						when toFetch =>																	-- the instruction had just started and asks to proceed to fetch stage
							if(fetch = '0') then
								report "fetch";
								fetch <= '1';

								mode := instructions(i)(6);
								if mode = '1' then
									operand(0) := instructions(i)(7);
									operand(1) := instructions(i)(8);
									operand(2) := instructions(i)(9);
									operand(3) := instructions(i)(10);
									operand(4) := instructions(i)(11);
									register_busy := to_integer(unsigned(operand));
									if registers(register_busy) = '1' then
										fetchStall := 1;
										report "fetch again";
									else
										registers(register_busy) := '1';
										report "register_busy: " & integer'image(to_integer(unsigned(operand)));
										instructions(i)(2) := '1';
										mode := instructions(i)(12);
										if mode = '1' then
											operand(0) := instructions(i)(13);
											operand(1) := instructions(i)(14);
											operand(2) := instructions(i)(15);
											operand(3) := instructions(i)(16);
											operand(4) := instructions(i)(17);
											register_busy := to_integer(unsigned(operand));
											registers(register_busy) := '1';
											mode := instructions(i)(18);
											if mode = '1' then
												operand(0) := instructions(i)(19);
												operand(1) := instructions(i)(20);
												operand(2) := instructions(i)(21);
												operand(3) := instructions(i)(22);
												operand(4) := instructions(i)(23);
												register_busy := to_integer(unsigned(operand));
												registers(register_busy) := '1';
											end if;
										end if;
									end if;
								end if;
							end if;
						when toDecode =>																			-- the instruction is currently on the fetch stage and asks to proceed to decode stage
							if(decode = '0') then
								report "decode";
								decode <= '1';
								mode := instructions(i)(12);
								if mode = '1' then
									operand(0) := instructions(i)(13);
									operand(1) := instructions(i)(14);
									operand(2) := instructions(i)(15);
									operand(3) := instructions(i)(16);
									operand(4) := instructions(i)(17);
									if registers(to_integer(unsigned(operand))) = '0' then
										if to_integer(unsigned(operand)) /= newlyFreed then
											mode := instructions(i)(18);
											if mode = '1' then
												operand(0) := instructions(i)(19);
												operand(1) := instructions(i)(20);
												operand(2) := instructions(i)(21);
												operand(3) := instructions(i)(22);
												operand(4) := instructions(i)(23);
												if registers(to_integer(unsigned(operand))) = '0' then
													if to_integer(unsigned(operand)) /= newlyFreed then
														instructions(i)(2) := '0';
														instructions(i)(1) := '1';
													else
														report "newlyFreed: " & integer'image(newlyFreed);
														decodeStall := 1;
													end if;
												else
													report "BUSY REGISTER: " & integer'image(to_integer(unsigned(operand)));
													decodeStall := 1;															
												end if;
											else
												instructions(i)(1) := '1';
												instructions(i)(2) := '0';
											end if;
										else
											report "newlyFreed: " & integer'image(newlyFreed);
											decodeStall := 1; 
										end if ;
									else
										report "BUSY REGISTER: " & integer'image(to_integer(unsigned(operand)));
										decodeStall := 1;
									end if;
								else
									mode := instructions(i)(18);
									if mode = '1' then
										operand(0) := instructions(i)(19);
										operand(1) := instructions(i)(20);
										operand(2) := instructions(i)(21);
										operand(3) := instructions(i)(22);
										operand(4) := instructions(i)(23);
										if registers(to_integer(unsigned(operand))) = '0' then
											if to_integer(unsigned(operand)) /= newlyFreed then
												instructions(i)(2) := '0';
												instructions(i)(1) := '1';
											else
												report "newlyFreed: " & integer'image(newlyFreed);
												decodeStall := 1;
											end if;
										else
											report "BUSY REGISTER: " & integer'image(to_integer(unsigned(operand)));
											decodeStall := 1;
										end if;
									else
										instructions(i)(1) := '1';
										instructions(i)(2) := '0';
									end if;
								end if;
							else 
								fetch <= '1';
								fetchStall := 1;
							end if;
						when toExecute =>																				-- the instruction is currently on the decode stage and asks to proceed to execute stage
							if(execute = '0') then
								report "execute";
								execute <= '1';
								instructions(i)(2) := '1';
								operation(0) := instructions(i)(3);
								operation(1) := instructions(i)(4);
								operation(2) := instructions(i)(5);
								case operation is
									when load =>																		-- execute load operation
										report "load";
										mode := instructions(i)(6);
										if mode = '1' then
											operand(0) := instructions(i)(7);
											operand(1) := instructions(i)(8);
											operand(2) := instructions(i)(9);
											operand(3) := instructions(i)(10);
											operand(4) := instructions(i)(11);
											destination := to_integer(unsigned(operand));

											operand(0) := instructions(i)(13);
											operand(1) := instructions(i)(14);
											operand(2) := instructions(i)(15);
											operand(3) := instructions(i)(16);
											operand(4) := instructions(i)(17);

											mode := instructions(i)(12);
											if mode = '0' then
												source1 := to_integer(unsigned(operand));
												if source1 > 3 then
													immediateBinary := to_unsigned(source1, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source1 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
												if source1 = 0 then
													zero_flag <= '1';
												end if;
												if source1 >= 0 then 
													sign_flag <= '1';
												end if;
												reg_value(destination) := source1;
												report "reg_value of " & integer'image(destination) &
													": " & integer'image(reg_value(destination));
											end if;
										end if;
									when addition =>																		-- execute addition operation
										report "addition";
										mode := instructions(i)(6);
										if mode = '1' then
											operand(0) := instructions(i)(7);
											operand(1) := instructions(i)(8);
											operand(2) := instructions(i)(9);
											operand(3) := instructions(i)(10);
											operand(4) := instructions(i)(11);
											destination := to_integer(unsigned(operand));

											operand(0) := instructions(i)(13);
											operand(1) := instructions(i)(14);
											operand(2) := instructions(i)(15);
											operand(3) := instructions(i)(16);
											operand(4) := instructions(i)(17);

											mode := instructions(i)(12);
											source1 := to_integer(unsigned(operand));
											if mode = '0' then
												if source1 > 3 then
													immediateBinary := to_unsigned(source1, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source1 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
											else
												source1 := reg_value(source1);
											end if;

											operand(0) := instructions(i)(19);
											operand(1) := instructions(i)(20);
											operand(2) := instructions(i)(21);
											operand(3) := instructions(i)(22);
											operand(4) := instructions(i)(23);

											mode := instructions(i)(18);
											source2 := to_integer(unsigned(operand));
											if mode = '0' then
												if source2 > 3 then
													immediateBinary := to_unsigned(source2, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source2 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
											else
												source2 := reg_value(source2);
											end if;

											reg_value(destination) := source1 + source2;
											if reg_value(destination) = 0 then
													zero_flag <= '1';
												end if;
											if reg_value(destination) >= 0 then 
													sign_flag <= '1';
												end if;
											if reg_value(destination) > 3 then
												immediateBinary := to_unsigned(reg_value(destination), 2);
												immediateBinaryVector(0) := immediateBinary(0);
												immediateBinaryVector(1) := immediateBinary(1);
												reg_value(destination) := to_integer(unsigned(immediateBinaryVector));
												overflow_flag <= '1';
											end if;												
										end if;
									when subtraction =>																		-- execute subtraction operation
										report "subtraction";
										mode := instructions(i)(6);
										if mode = '1' then
											operand(0) := instructions(i)(7);
											operand(1) := instructions(i)(8);
											operand(2) := instructions(i)(9);
											operand(3) := instructions(i)(10);
											operand(4) := instructions(i)(11);
											destination := to_integer(unsigned(operand));

											operand(0) := instructions(i)(13);
											operand(1) := instructions(i)(14);
											operand(2) := instructions(i)(15);
											operand(3) := instructions(i)(16);
											operand(4) := instructions(i)(17);

											mode := instructions(i)(12);
											source1 := to_integer(unsigned(operand));
											if mode = '0' then
												if source1 > 3 then
													immediateBinary := to_unsigned(source1, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source1 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
											else
												source1 := reg_value(source1);
											end if;

											operand(0) := instructions(i)(19);
											operand(1) := instructions(i)(20);
											operand(2) := instructions(i)(21);
											operand(3) := instructions(i)(22);
											operand(4) := instructions(i)(23);

											mode := instructions(i)(18);
											source2 := to_integer(unsigned(operand));
											if mode = '0' then
												if source2 > 3 then
													immediateBinary := to_unsigned(source2, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source2 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
											else
												source2 := reg_value(source2);
											end if;

											reg_value(destination) := source1 - source2;
											if reg_value(destination) = 0 then
													zero_flag <= '1';
												end if;
											if reg_value(destination) >= 0 then 
													sign_flag <= '1';
												end if;
											if reg_value(destination) > 3 then
												immediateBinary := to_unsigned(reg_value(destination), 2);
												immediateBinaryVector(0) := immediateBinary(0);
												immediateBinaryVector(1) := immediateBinary(1);
												reg_value(destination) := to_integer(unsigned(immediateBinaryVector));
												overflow_flag <= '1';
											end if;												
										end if;
									when multiplication =>																	-- execute multiplication operation
										report "multiplication";
										mode := instructions(i)(6);
										if mode = '1' then
											operand(0) := instructions(i)(7);
											operand(1) := instructions(i)(8);
											operand(2) := instructions(i)(9);
											operand(3) := instructions(i)(10);
											operand(4) := instructions(i)(11);
											destination := to_integer(unsigned(operand));

											operand(0) := instructions(i)(13);
											operand(1) := instructions(i)(14);
											operand(2) := instructions(i)(15);
											operand(3) := instructions(i)(16);
											operand(4) := instructions(i)(17);

											mode := instructions(i)(12);
											source1 := to_integer(unsigned(operand));
											if mode = '0' then
												if source1 > 3 then
													immediateBinary := to_unsigned(source1, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source1 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
											else
												source1 := reg_value(source1);
											end if;

											operand(0) := instructions(i)(19);
											operand(1) := instructions(i)(20);
											operand(2) := instructions(i)(21);
											operand(3) := instructions(i)(22);
											operand(4) := instructions(i)(23);

											mode := instructions(i)(18);
											source2 := to_integer(unsigned(operand));
											if mode = '0' then
												if source2 > 3 then
													immediateBinary := to_unsigned(source2, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source2 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
											else
												source2 := reg_value(source2);
											end if;

											reg_value(destination) := source1 * source2;
											if reg_value(destination) = 0 then
													zero_flag <= '1';
												end if;
											if reg_value(destination) >= 0 then 
													sign_flag <= '1';
												end if;
											if reg_value(destination) > 3 then
												immediateBinary := to_unsigned(reg_value(destination), 2);
												immediateBinaryVector(0) := immediateBinary(0);
												immediateBinaryVector(1) := immediateBinary(1);
												reg_value(destination) := to_integer(unsigned(immediateBinaryVector));
												overflow_flag <= '1';
											end if;												
										end if;
									when division =>																		-- execute division operation
										report "division";
										mode := instructions(i)(6);
										if mode = '1' then
											operand(0) := instructions(i)(7);
											operand(1) := instructions(i)(8);
											operand(2) := instructions(i)(9);
											operand(3) := instructions(i)(10);
											operand(4) := instructions(i)(11);
											destination := to_integer(unsigned(operand));

											operand(0) := instructions(i)(13);
											operand(1) := instructions(i)(14);
											operand(2) := instructions(i)(15);
											operand(3) := instructions(i)(16);
											operand(4) := instructions(i)(17);

											mode := instructions(i)(12);
											source1 := to_integer(unsigned(operand));
											if mode = '0' then
												if source1 > 3 then
													immediateBinary := to_unsigned(source1, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source1 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
											else
												source1 := reg_value(source1);
											end if;

											operand(0) := instructions(i)(19);
											operand(1) := instructions(i)(20);
											operand(2) := instructions(i)(21);
											operand(3) := instructions(i)(22);
											operand(4) := instructions(i)(23);

											mode := instructions(i)(18);
											source2 := to_integer(unsigned(operand));
											if mode = '0' then
												if source2 > 3 then
													immediateBinary := to_unsigned(source2, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source2 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
											else
												source2 := reg_value(source2);
											end if;

											reg_value(destination) := source1 / source2;
											if reg_value(destination) = 0 then
													zero_flag <= '1';
												end if;
											if reg_value(destination) >= 0 then 
													sign_flag <= '1';
												end if;
											if reg_value(destination) > 3 then
												immediateBinary := to_unsigned(reg_value(destination), 2);
												immediateBinaryVector(0) := immediateBinary(0);
												immediateBinaryVector(1) := immediateBinary(1);
												reg_value(destination) := to_integer(unsigned(immediateBinaryVector));
												overflow_flag <= '1';
											end if;												
										end if;
									when modulo =>																			-- execute modulo operation
										report "modulo";
										mode := instructions(i)(6);
										if mode = '1' then
											operand(0) := instructions(i)(7);
											operand(1) := instructions(i)(8);
											operand(2) := instructions(i)(9);
											operand(3) := instructions(i)(10);
											operand(4) := instructions(i)(11);
											destination := to_integer(unsigned(operand));

											operand(0) := instructions(i)(13);
											operand(1) := instructions(i)(14);
											operand(2) := instructions(i)(15);
											operand(3) := instructions(i)(16);
											operand(4) := instructions(i)(17);

											mode := instructions(i)(12);
											source1 := to_integer(unsigned(operand));
											if mode = '0' then
												if source1 > 3 then
													immediateBinary := to_unsigned(source1, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source1 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
											else
												source1 := reg_value(source1);
											end if;

											operand(0) := instructions(i)(19);
											operand(1) := instructions(i)(20);
											operand(2) := instructions(i)(21);
											operand(3) := instructions(i)(22);
											operand(4) := instructions(i)(23);

											mode := instructions(i)(18);
											source2 := to_integer(unsigned(operand));
											if mode = '0' then
												if source2 > 3 then
													immediateBinary := to_unsigned(source2, 2);
													immediateBinaryVector(0) := immediateBinary(0);
													immediateBinaryVector(1) := immediateBinary(1);
													source2 := to_integer(unsigned(immediateBinaryVector));
													overflow_flag <= '1';
												end if;
											else
												source2 := reg_value(source2);
											end if;

											reg_value(destination) := source1 mod source2;
											if reg_value(destination) = 0 then
													zero_flag <= '1';
												end if;
											if reg_value(destination) >= 0 then 
													sign_flag <= '1';
												end if;
											if reg_value(destination) > 3 then
												immediateBinary := to_unsigned(reg_value(destination), 2);
												immediateBinaryVector(0) := immediateBinary(0);
												immediateBinaryVector(1) := immediateBinary(1);
												reg_value(destination) := to_integer(unsigned(immediateBinaryVector));
												overflow_flag <= '1';
											end if;												
										end if;
									when others =>
										report "NONE";
								end case;

							else 
								decode <= '1';
								decodeStall := 1;
							end if;
						when toMemory =>																				-- the instruction is currently on the execute stage and asks to proceed to memory stage
							if(memory = '0') then
								report "memory";
								memory <= '1';
								instructions(i)(0) := '1';
								instructions(i)(1) := '0';
								instructions(i)(2) := '0';
							else 
								execute <= '1';
								executeStall := 1;
							end if;
						when toWrite =>																					-- the instruction is currently on the memory stage and asks to proceed to writeback stage
							if(writeback = '0') then
								report "writeback";
								writeback <= '1';
								instructions(i)(2) := '1';
								mode := instructions(i)(6);
								if mode = '1' then
									operand(0) := instructions(i)(7);
									operand(1) := instructions(i)(8);
									operand(2) := instructions(i)(9);
									operand(3) := instructions(i)(10);
									operand(4) := instructions(i)(11);
									register_busy := to_integer(unsigned(operand));
									registers(register_busy) := '0';													-- 1st operand used by this instruction is freed
									newlyFreed := register_busy;
									report "NOT BUSY: " & integer'image(to_integer(unsigned(operand)));
								end if;
								
								mode := instructions(i)(12);
								if mode = '1' then
									operand(0) := instructions(i)(13);
									operand(1) := instructions(i)(14);
									operand(2) := instructions(i)(15);
									operand(3) := instructions(i)(16);
									operand(4) := instructions(i)(17);
									register_busy := to_integer(unsigned(operand));
									registers(register_busy) := '0';													-- 2nd operand used by this instruction is freed
									report "NOT BUSY: " & integer'image(to_integer(unsigned(operand)));
								end if;
								mode := instructions(i)(19);
								if mode = '1' then
									operand(0) := instructions(i)(19);
									operand(1) := instructions(i)(20);
									operand(2) := instructions(i)(21);
									operand(3) := instructions(i)(22);
									operand(4) := instructions(i)(23);
									register_busy := to_integer(unsigned(operand));
									registers(register_busy) := '0';													-- 3rd operand used by this instruction is freed
									report "NOT BUSY: " & integer'image(to_integer(unsigned(operand)));
								end if;
							else 
								memory <= '1';
								memoryStall := 1;
							end if;
						when others =>
							i := i;
					end case;

					i := i + 1;
				end loop;					
			else 																										-- if the clock shifts to the falling edge, also shifts values of signals to 0
				if(fetchStall = 0) then
					fetch <= '0';																							-- exception to shifting, fetch and decode are stalling
				end if;
				if(decodeStall = 0) then
					decode <= '0';
				end if;
				if(executeStall = 0) then
					execute <= '0';
				end if;
				if(memoryStall = 0) then
					memory <= '0';
				end if;

				fetchStall := 0;
				decodeStall := 0;
				executeStall := 0;
				memoryStall := 0;

				newlyFreed := -1;

				writeback <= '0';
				sign_flag <= '0';
				underflow_flag <= '0';
				overflow_flag <= '0';
				zero_flag <= '0';
				pc0 <= '0';
				pc1 <= '0';
				pc2 <= '0';
				pc3 <= '0';

			end if;
		end process operates;

end architecture operation;