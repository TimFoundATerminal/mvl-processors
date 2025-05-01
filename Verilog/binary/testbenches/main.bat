@echo off

REM Argument for the directory of the Verilog files
IF "%1"=="" (
    SET SRC_DIR="."
) ELSE (
    SET SRC_DIR=%1
)

REM Clean up any previous simulation files
cd %SRC_DIR%/testbenches
del /f main.vvp
cd ../

REM Compile the Verilog files
iverilog -o testbenches/main.vvp -Psystem_tb.VERBOSE=1 program_counter.v registers.v fetch_instruction.v decode_instruction.v alu.v control.v memory.v cpu.v program_loader.v machine.v testbenches/system_tb.v

REM Run the simulation
vvp testbenches/main.vvp

@REM REM View waveforms
@REM start gtkwave main.vcd

@REM REM Pause to keep the window open if there are errors
@REM pause
