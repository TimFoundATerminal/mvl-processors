# Notes

## Prerequisites

- Digital Electronics
    - Finite State Machines
- Verilog
    - Combination Logs
    - Finite state machine
- Abstraction Levels
- Data path + Controller
- Testbench Design


## 32-bit Processor Design

Components:
- Arithmetic and Logic Unit
- Branching Design
- Instruction Registers
- Decoder

### Data Path vs. Controller

**Data Path**
Consists of components that perform the actual data processing such as:
- Functional Units: ALU, shifters, Multipliers, Adders
- Storage Elements: Registers, Memory Units, flip-flops
- Data Transfer Components: Multiplexers, buses, interconnections

**Controller**
Responsible for coordinating operations within the data path which includes:
- State Machines: Finite State Machines that determine the current state of the system
- Control Signal Generation: Logic that produces signals to activate specific components in the data path
- Timing Coordination: Ensuring operations happen in the correct sequence.
- Decision Logic: Determining the next state based on inputs and current state

This separation of concerns allows the controller to monitor status signals from the data path and respond to outputs by generating 
control signals. This modular design makes the code more maintainable.

## Architecture vs Micro-architecture

**Architecture**
These are the programmer visible aspects of the CPU and what the software developer needs to know to write code for the processor:
- Instruction Set Architecture (ISA)
- Register Set
- Memory Model: How memory is addressed and accessed
- Exception Handling: How interrupts and errors are processed
- Addressing Modes: How operands are specified in instructions

**Micro Architecture**
Refers to specific implementation details of the architecture:
- Pipeline Design: How instructions flow through the CPU (single-cycle, multi-cycle, pipelined)
- Cache Hierarchy: Implementation of different cache levels and their behaviors
- Branch Prediction
- Execution Units: How many ALUs, FPUs, and other functional units.
- Bus structure
- Clock domain management
- Power management

## Design Choices

When selecting which addition algorithm to use, consider that ripple carry requires less gates so will use less power but take slightly longer. Look-ahead carry requires more gates and therefore power making it more suited for a server CPU whereas ripple carry would be better suited to a mobile CPU.

## CISC vs. RISC

**Complex Instruction Set**
- Will introduce specific instructions for each operation e.g. ADD, SUB, MUL, DIV
- Less lines of instructions
- Requires more hardware to decode more instruction

**Reduced Instruction Set**
- Will use general instructions to complete more general operations e.g. ADD, SUB -> MUL, DIV
- More lines of instructions
- Requires less hardware to decode less instructions




