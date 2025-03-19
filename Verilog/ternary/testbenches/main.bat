@echo off
REM Clean up any previous simulation files
cd testbenches
del /f main.vvp
cd ../

REM Compile the Verilog files
iverilog -o testbenches/main.vvp 
@REM testbenches/system_tb.v

REM Run the simulation
@REM vvp testbenches/main.vvp

@REM REM View waveforms
@REM start gtkwave main.vcd

@REM REM Pause to keep the window open if there are errors
@REM pause