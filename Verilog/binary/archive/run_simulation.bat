@echo off
REM Clean up any previous simulation files
del /F simulation.vvp binary_test.vcd 2>nul

REM Compile the Verilog files
iverilog -o simulation.vvp binary_components.v testbench.v

REM Run the simulation
vvp simulation.vvp

REM View waveforms
start gtkwave binary_test.vcd

REM Pause to keep the window open if there are errors
pause