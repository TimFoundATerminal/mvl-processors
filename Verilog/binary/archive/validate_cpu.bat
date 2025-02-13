@echo off
REM Clean up any previous simulation files
del /F validate_cpu.vvp binary_test.vcd 2>nul

REM Compile the Verilog files
iverilog -o validate_cpu.vvp ram_32x16.v program_loader.v cpu_core.v unified_system.v unified_system_tb.v

REM Run the simulation
vvp validate_cpu.vvp

@REM REM View waveforms
@REM start gtkwave binary_test.vcd

REM Pause to keep the window open if there are errors
pause