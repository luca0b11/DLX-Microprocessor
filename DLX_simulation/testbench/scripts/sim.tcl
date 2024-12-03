##################################################
# Script for DLX compilation and simulation
##################################################

# COMPILE ALL FILES

vcom 000-globals.vhd

# Control Unit
vcom a.a-CU.vhd

# Datapath

#Fetch stage
vcom a.b-DataPath.core/a.b.a-FetchStage.vhd

#Decode stage
vcom a.b-DataPath.core/a.b.b-DecodeStage.core/a.b.b.a-Registerfile.vhd
vcom a.b-DataPath.core/a.b.b-DecodeStage.vhd

# Execute stage
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.i-FullAdder.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.h-Mux21Generic.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.g-RCA.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.f-Pg.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.e-PgGenerator.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.d-PgNetwork.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.c-CarrySelectBlock.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.b-CarryGenerator.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.core/a.b.c.a.a.a-SumGenerator.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.a-P4Adder.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.b-BoothMul.core/a.b.c.a.b.b-FullAdder.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.b-BoothMul.core/a.b.c.a.b.a-RCA.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.core/a.b.c.a.b-BoothMul.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.core/a.b.c.a-ALU.vhd
vcom a.b-DataPath.core/a.b.c-ExecuteStage.vhd

# Memory stage
vcom a.b-DataPath.core/a.b.d-MemoryStage.vhd

# Writeback stage
vcom a.b-DataPath.core/a.b.e-WritebackStage.vhd

vcom a.b-DataPath.vhd

# Data/Instruction memory
vcom a.c-InstructionMemory.vhd
vcom a.d-DataMemory.vhd

# DLX top entity
vcom a-DLX.vhd

# Testbench DLX
vcom testbench/TB_DLX.vhd

# DLX simulation

vsim -t 10ps work.TB_DLX -voptargs=+acc
log -r /*
add wave *
run 500 ns