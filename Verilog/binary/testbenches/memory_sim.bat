@echo off
REM Clean up any previous simulation files
del /F testbenches/memory_tb.vvp 2>nul

REM Compile the Verilog files
iverilog -o testbenches/memory_tb.vvp memory.v testbenches/memory_tb.v

REM Run the simulation
vvp testbenches/memory_tb.vvp

@REM REM View waveforms
@REM start gtkwave system_tb.vcd

@REM REM Pause to keep the window open if there are errors
@REM pause