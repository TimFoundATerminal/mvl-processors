@echo off
REM Clean up any previous simulation files
cd testbenches
del /f mem_tb.vvp
cd ../

@REM REM Compile the Verilog files
iverilog -o testbenches/mem_tb.vvp memory.v testbenches/mem_tb.v

@REM REM Run the simulation
vvp testbenches/mem_tb.vvp

@REM REM View waveforms
@REM start gtkwave system_tb.vcd

@REM REM Pause to keep the window open if there are errors
@REM pause