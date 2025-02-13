@echo off
REM Clean up any previous simulation files
del /F programs/asm_parser.vvp binary_test.vcd 2>nul

REM Compile the Verilog files
iverilog -o programs/asm_parser.vvp programs/asm_parser.v

REM Run the simulation
vvp programs/asm_parser.vvp

REM Pause to keep the window open if there are errors
pause