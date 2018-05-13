ghdl -a std_logic_textio.vhdl
ghdl -a pipeline.vhdl
ghdl -a operation.vhdl
ghdl -e pipeline
ghdl -r pipeline --vcd="sample.vcd"