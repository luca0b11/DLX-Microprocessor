##############################################################
#SCRIPT FOR COMPLETE DLX SYNTHESIS#
##############################################################
# analyzing and checking vhdl netlist#

analyze -library WORK -format vhdl netlist/000-globals.vhd
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.a-FetchStage.vhd
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.b-DecodeStage.core/a.b.b.a-Registerfile.vhd
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.b-DecodeStage.vhd
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.i-FullAdder.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.h-Mux21Generic.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.g-RCA.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.f-Pg.vhd  
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.e-PgGenerator.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.d-PgNetwork.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.c-CarrySelectBlock.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.b-CarryGenerator.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.a-SumGenerator.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.b-BoothMul.core/a.b.c.a.b.b-FullAdder.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.b-BoothMul.core/a.b.c.a.b.a-RCA.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.b-BoothMul.vhd 
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.vhd
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.c-ExecuteStage.vhd
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.d-MemoryStage.vhd
analyze -library WORK -format vhdl netlist/a.b-DataPath.core/a.b.e-WritebackStage.vhd
analyze -library WORK -format vhdl netlist/a.b-DataPath.vhd
analyze -library WORK -format vhdl netlist/a.a-CU.vhd
analyze -library WORK -format vhdl netlist/a-DLX.vhd

##############################################################
# elaborating the top entity of the DLX#

elaborate dlx -architecture structural -library WORK
set_wire_load_model -name 5K_hvratio_1_4
ungroup -all -flatten

##### Synthesis DLX #####
current_design dlx
create_clock -name "CLK" -period 1 CLK
set_max_delay 1 -from [all_inputs] -to [all_outputs]
optimize_registers -clock CLK -minimum_period_only
set_fix_hold CLK
compile_ultra

report_timing > report/DLX_time_opt.txt
report_area > report/DLX_area_opt.txt
report_power > report/DLX_power_opt.txt

##### Power Gating DLX #####
set_clock_gating_style \
    -minimum_bitwidth 1 \
    -max_fanout 1024 \
    -positive_edge_logic {latch and} \
    -control_point before

compile_ultra -gate_clock
set_dont_retime [all_fanout -from [get_pins -filter is_clock_gate_output_pin] -only_cells]

report_clock_gating > report/DLX_clock_gating.txt
report_timing > report/DLX_time_cg.txt
report_area > report/DLX_area_cg.txt
report_power > report/DLX_power_cg.txt

# saving files
write -hierarchy -format ddc -output saved/DLX-structural-topt.ddc
write -hierarchy -format verilog -output saved/DLX-structural-topt.v
write_sdc -version 1.3 saved/DLX-postsyn.sdc
