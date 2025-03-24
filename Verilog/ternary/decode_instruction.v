module decode_instruction(
    instruction, 
    opcode, 
    is_alu_operation, // specific alu operation can be determined by opcode
    reg_dest,
    reg_src,
    big_immediate,
    small_immediate
);

    `include "parameters.vh"

    input wire [2*WORD_SIZE-1:0] instruction;

    output wire [2*OPCODE_SIZE-1:0] opcode;
    output wire [2*REG_ADDR_SIZE-1:0] reg_dest, reg_src;
    output wire is_alu_operation;
    output wire [2*BIG_IMM_SIZE-1:0] big_immediate;
    output wire [2*SMALL_IMM_SIZE-1:0] small_immediate;

    assign {opcode, reg_dest, reg_src, small_immediate} = instruction;
    assign big_immediate = {reg_src, small_immediate};

    // If opcode is in the following list, it is an ALU operation
    assign is_alu_operation = (opcode == `NOT) || (opcode == `AND) || (opcode == `OR) || 
        (opcode == `XOR) || (opcode == `ADD) || (opcode == `SUB) || (opcode == `COMP) || 
        (opcode == `ANDI) || (opcode == `ADDI) || (opcode == `SRI) || (opcode == `SLI);

endmodule