@echo off
REM Clean up any previous simulation files
cd testbenches
del /f alu_tb.vvp
cd ../

@REM REM Compile the Verilog files
iverilog -o testbenches/alu_tb.vvp alu.v testbenches/alu_tb.v

@REM REM Run the simulation
vvp testbenches/alu_tb.vvp

@REM REM View waveforms
@REM start gtkwave system_tb.vcd

@REM REM Pause to keep the window open if there are errors
@REM pause