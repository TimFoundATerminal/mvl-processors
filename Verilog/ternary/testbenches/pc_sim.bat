@echo off
REM Clean up any previous simulation files
cd testbenches
del /f pc_tb.vvp
cd ../

@REM REM Compile the Verilog files
iverilog -o testbenches/pc_tb.vvp alu.v program_counter.v testbenches/pc_tb.v

@REM REM Run the simulation
vvp testbenches/pc_tb.vvp

@REM REM View waveforms
@REM start gtkwave system_tb.vcd

@REM REM Pause to keep the window open if there are errors
@REM pause