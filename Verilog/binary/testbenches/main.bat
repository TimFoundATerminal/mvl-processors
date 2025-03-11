@echo off
REM Clean up any previous simulation files
del /F testbenches/main.vvp system_tb.vcb 2>nul

REM Compile the Verilog files
iverilog -o testbenches/main.vvp program_counter.v registers.v decode_instruction.v alu.v control.v memory.v cpu.v program_loader.v machine.v testbenches/system_tb.v
@REM iverilog -o main.vvp alu.v

REM Run the simulation
vvp testbenches/main.vvp

@REM REM View waveforms
@REM start gtkwave system_tb.vcd

@REM REM Pause to keep the window open if there are errors
@REM pause