files = std_logic_textio.vhdl pipeline.vhdl

run: $(files)
	ghdl -a std_logic_textio.vhdl
	ghdl -a pipeline.vhdl
	ghdl -a operation.vhdl
	ghdl -e pipeline
	ghdl -r pipeline --vcd="pipelining.vcd"
	rm pipeline