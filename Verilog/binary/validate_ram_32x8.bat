@echo off
REM Clean up any previous simulation files
del /F validate_ram_32x8.vvp binary_test.vcd 2>nul

REM Compile the Verilog files
iverilog -o validate_ram_32x8.vvp ram_32x8.v

REM Run the simulation
vvp validate_ram_32x8.vvp

@REM REM View waveforms
@REM start gtkwave binary_test.vcd

REM Pause to keep the window open if there are errors
pause