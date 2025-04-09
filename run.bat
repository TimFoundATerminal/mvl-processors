@echo off

REM Compile the assembly code into a hex file for binary
python Verilog/binary/programs/compiler.py --filepath "input.asm" --output "Verilog/binary/programs/bin/program.hex"

REM Compile the assembly code into a hex file for ternary
python Verilog/ternary/programs/compiler.py --filepath "input.asm" --output "Verilog/ternary/programs/bin/program.hex"

REM Run the batch file that runs the binary testbench
cd /d %~dp0
call Verilog/binary/testbenches/main.bat "Verilog/binary"


REM Run the batch file that runs the ternary testbench
cd /d %~dp0
call Verilog/ternary/testbenches/main.bat "Verilog/ternary"

REM Reset back to the original directory
cd /d %~dp0

