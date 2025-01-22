@echo off
REM Clean up any previous simulation files
del /F simulation.vvp ternary_test.vcd 2>nul

REM Compile the Verilog files
iverilog -o simulation.vvp ternary_components.v testbench.v

REM Run the simulation
vvp simulation.vvp

REM View waveforms
start gtkwave ternary_test.vcd

REM Pause to keep the window open if there are errors
pause