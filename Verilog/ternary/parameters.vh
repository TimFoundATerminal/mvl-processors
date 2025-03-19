parameter WORD_SIZE = 9;

parameter OPCODE_SIZE = 3;
parameter BIG_IMM_SIZE = 4;
parameter SMALL_IMM_SIZE = 2;
parameter INS_ADDR_SIZE = 4;

parameter MEM_SIZE = 32; // Will need to rethink this instruction set
parameter MEM_ADDR_SIZE = 3;

parameter REG_NUM = 8;
parameter REG_ADDR_SIZE = 2;

// Ternary logic
`define _1  2'b11 // -1 (2)
`define _0  2'b00 // 0
`define _1_ 2'b01 // 1

// Opcodes (3 trits) - represented as 6 bits
`define MV    6'b000000 // 0
`define NOT   6'b000011 // 2
`define AND   6'b000101 // 4
`define OR    6'b000111 // 5
`define XOR   6'b001100 // 6
`define ADD   6'b001101 // 7
`define SUB   6'b001111 // 8
`define COMP  6'b010011 // 11
`define ANDI  6'b010100 // 12
`define ADDI  6'b010101 // 13
`define SRI   6'b010111 // 14
`define SLI   6'b011100 // 15
`define LUI   6'b011101 // 16
`define LI    6'b011111 // 17
`define BEQ   6'b110000 // 18
`define BNE   6'b110001 // 19
`define LOAD  6'b110101 // 22
`define STORE 6'b110111 // 23
`define HALT  6'b111111 // 26

// Processor States
`define STATE_INSMEM_LOAD 4'h0
`define STATE_RESET 4'h1
`define STATE_FETCH 4'h2
`define STATE_REGLOAD 4'h3
`define STATE_ALU 4'h4
`define STATE_LOAD 4'h5
`define STATE_STORE 4'h6
`define STATE_REGSTORE 4'h7
`define STATE_NEXT 4'h8
`define STATE_HALT 4'h9