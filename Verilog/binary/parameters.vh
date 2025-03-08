parameter OPCODE_SIZE = 5;
parameter WORD_SIZE = 16;
parameter MEM_SIZE = 32;
parameter MEM_ADDR_SIZE = 5;
parameter INS_ADDR_SIZE = 11;

parameter REG_NUM = 8;

// Opcodes (5 bits)
`define MV    5'b00000 // 0
`define NOT   5'b00010 // 2
`define AND   5'b00100 // 4
`define OR    5'b00101 // 5
`define XOR   5'b00110 // 6
`define ADD   5'b00111 // 7
`define SUB   5'b01000 // 8
`define COMP  5'b01011 // 11
`define ANDI  5'b01100 // 12
`define ADDI  5'b01101 // 13
`define SRI   5'b01110 // 14
`define SLI   5'b01111 // 15
`define LUI   5'b10000 // 16
`define LI    5'b10001 // 17
`define BEQ   5'b10010 // 18
`define BNE   5'b10011 // 19
`define LOAD  5'b10110 // 22
`define STORE 5'b10111 // 23
`define HALT  5'b11111 // 31

// Processor States
// `define STATE_INSMEM_LOAD 4'h0
// `define STATE_RESET 4'h1
// `define STATE_FETCH 4'h2
// `define STATE_REGLOAD 4'h3
// `define STATE_ALUOP 4'h4
// `define STATE_LOAD 4'h5
// `define STATE_STORE 4'h6
// `define STATE_REGSTORE 4'h7
// `define STATE_NEXT 4'h8

// `define CTRL_CPU_STATE 8'h00
// `define CTRL_INSMEM_POS 8'h02
// `define CTRL_INSMEM_DATA 8'h03