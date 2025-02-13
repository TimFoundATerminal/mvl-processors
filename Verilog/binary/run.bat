@echo off
REM Clean up any previous simulation files
del /F validate_cpu.vvp binary_test.vcd 2>nul

REM Compile the Verilog files
iverilog -o run.vvp ram_32x16.v cpu_core.v unified_system.v program_loader_tb.v

REM Run the simulation
vvp run.vvp

@REM REM View waveforms
@REM start gtkwave binary_test.vcd

@REM REM Pause to keep the window open if there are errors
@REM pause