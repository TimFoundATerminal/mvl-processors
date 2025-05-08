# Binary vs. Ternary Logic Comparative Analysis

## Project Overview

This repository contains the implementation for the dissertation "A Comparative Analysis of Binary vs. Ternary Logic within an Emulated System". The project investigates ternary logic as a potential alternative to traditional binary computing by designing functionally equivalent binary and ternary processors.

### Abstract

As traditional binary computing approaches physical limitations, this research investigates ternary logic as a potential alternative by designing functionally equivalent binary and ternary processors. By proposing a novel design for a ternary CONSENSUS gate, we constructed a test platform capable of executing identical code on both architectures, enabling a direct performance comparison. Despite ternary logic's theoretical 58% information density advantage, our empirical findings revealed no significant practical performance benefits. The inefficiencies in current ternary gate implementations using CNFETs resulted in approximately three times more transistors than equivalent binary CMOS implementations. Our results suggest that substantial advancements in CNFET gate designs are necessary before it can compete with well-established binary systems in practical applications.

## Repository Structure

- `Verilog/` - Contains all Verilog code for the emulation
  - `binary/` - Binary system implementation with compiler.py
  - `ternary/` - Ternary system implementation with compiler.py
- `assembly-dashboard-backend/` - Backend code for the dashboard interface
- `assembly-dashboard-frontend/` - Frontend code for the dashboard interface
- `run.bat` - Main entry point for running the simulation

## Getting Started

### Prerequisites

- A working Verilog simulator (e.g., Icarus Verilog)
- Python 3.x
- Node.js and npm (for the dashboard)

### Running the Simulation

1. Create or edit your assembly code in a file named `input.asm`
2. Execute the batch file to compile and run your code on both architectures:

```
run.bat
```

This will:
1. Compile your assembly code for both binary and ternary architectures
2. Run the simulation on both architectures
3. Output the results for comparison

### Using the Dashboard

To use the web-based dashboard for visualizing and comparing results:

1. Navigate to the backend directory:
```
cd assembly-dashboard-backend
```

2. Install dependencies and start the backend server:
```
npm install
npm start
```

3. In a new terminal, navigate to the frontend directory:
```
cd assembly-dashboard-frontend
```

4. Install dependencies and start the frontend application:
```
npm install
npm start
```

5. Open your browser and navigate to `http://localhost:3000`

## Writing Assembly Code

The system supports a RISC-based instruction set with the following instruction types:
- R-type (Register operations)
- I-type (Immediate operations) 
- B-type (Branch operations)
- M-type (Memory operations)

Example assembly code:
```assembly
; Example program that adds two numbers
LOADI r0, 5     ; Load 5 into register 0
LOADI r1, 7     ; Load 7 into register 1
ADD r0, r1      ; Add r1 to r0, store result in r0
HALT            ; End program
```

## Key Contributions

- Functionally equivalent binary and ternary processors with matching instruction sets
- Quantitative assessment of the theoretical 58% information density advantage against practical implementation
- Novel implementation of a ternary CONS gate using primitive gates
- Digital test platform for ongoing benchmarking of CNFET and CMOS gate designs

## License

This project is academic research and is provided for educational purposes.