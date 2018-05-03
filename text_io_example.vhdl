LIBRARY IEEE,STD,WORK;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY text_io_example IS
END text_io_example;

ARCHITECTURE beh OF text_io_example IS
BEGIN
file_io:
PROCESS IS
 FILE in_file : TEXT OPEN READ_MODE IS "file_name.txt";
 FILE out_file : TEXT OPEN WRITE_MODE IS "file_out.txt";
 VARIABLE out_line : LINE;
 VARIABLE in_line : LINE;
 VARIABLE a,b,c : STD_LOGIC;
 VARIABLE d : String(1 to 10);
 BEGIN
 WHILE NOT ENDFILE(in_file) LOOP --do this till out of data
 READLINE(in_file, in_line); --get line of input stimulus
 READ(in_line, d); --get second operand
 READ(in_line, a); --get first operand
 READ(in_line, b); --get second operand
 report d & " " & std_logic'image( a ) & " " & 
           std_logic'image(b)
          severity NOTE;
 c := a AND b; --operate on the data
 WRITE(out_line, c); --save results to line
 WRITELINE(out_file, out_line); --write line to file
 END LOOP;
 ASSERT FALSE REPORT "Simulation done" SEVERITY NOTE;
 WAIT; --allows the simulation to halt!
END PROCESS;
END beh;
