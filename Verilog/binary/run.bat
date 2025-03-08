@echo off
REM Clean up any previous simulation files
del /F run.vvp system_tb.vcb 2>nul

REM Compile the Verilog files
iverilog -o run.vvp memory.v cpu_core.v program_loader.v system.v system_tb.v

REM Run the simulation
vvp run.vvp

@REM REM View waveforms
@REM start gtkwave system_tb.vcd

@REM REM Pause to keep the window open if there are errors
@REM pause