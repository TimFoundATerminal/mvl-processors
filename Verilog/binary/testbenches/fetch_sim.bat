@echo off
REM Clean up any previous simulation files
del /F testbenches/fetch_tb.vvp 2>nul

REM Compile the Verilog files
iverilog -o testbenches/fetch_tb.vvp fetch_instruction.v testbenches/fetch_tb.v

REM Run the simulation
vvp testbenches/fetch_tb.vvp

@REM REM View waveforms
@REM start gtkwave system_tb.vcd

@REM REM Pause to keep the window open if there are errors
@REM pause