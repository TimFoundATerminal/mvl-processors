module cpu(clock,
    ...
);

    `include "parameters.vh"

    input wire clock;

    // Memory interface
    input wire [WORD_SIZE-1:0] mem_read_data;
    output wire [MEM_ADDR_SIZE-1:0] mem_address;
    output wire [WORD_SIZE-1:0] mem_write_data;
    output wire mem_read, mem_write;

    // Debug Outputs
    output wire [3:0] state;
    output wire [OPCODE_SIZE-1:0] opcode;


    // Control signals
    wire fetch_, reg_load_, alu_, mem_load_, mem_store_, reg_store_, next_, reset_ halt_;

    // Internal signals
    // Internal signals for program counter
    wire update_pc, set_pc;
    wire [WORD_SIZE-1:0] pc_value;
    wire [MEM_ADDR_SIZE-1:0] program_counter;

    // Internal signals for register file
    wire get_regs, set_regs;
    wire [REG_ADDR_SIZE-1:0] reg_dest, reg_src;
    wire [WORD_SIZE-1:0] reg_val;
    wire [WORD_SIZE-1:0] reg_out1, reg_out2;


    // Program counter
    program_counter pc (
        .clock(clock),
        .reset_enable(reset_),
        .update_enable(next_),
        .value(pc_value),
        .out(program_counter)
    );


    // Register file
    registers regs (
        .clock(clock),
        .get_enable(get_regs),
        .set_enable(set_regs),
        .reset_enable(reset),
        .num1(reg_dest),
        .num2(reg_src),
        .set_val(reg_val),
        .out1(reg_out1),
        .out2(reg_out2)
    );

    // Instruction fetching
    assign mem_address = fetch_ ? program_counter : 
        (mem_load_ || mem_store_) ? reg_out1 : 5'b0; // 5'b0 is the default value for memory address.
    assign mem_write_data = mem_store_ ? reg_out2 : 16'h0000; // 16'h0000 is the default value for memory data.
    assign mem_read = fetch_ || mem_load_;
    assign mem_write = mem_store_;

    // Instruction decode
    output wire [OPCODE_SIZE-1:0] opcode;
    wire [REG_ADDR_SIZE-1:0] reg1, reg2;
    wire is_alu_operation;
    wire [BIG_IMM_SIZE-1:0] big_immediate;
    wire [SMALL_IMM_SIZE-1:0] small_immediate;
    decode_instruction decode (
        .instruction(mem_read_data), // Does this need to connected here?
        .opcode(opcode),
        .is_alu_operation(is_alu_operation),
        .reg_dest(reg_dest),
        .reg_src(reg_src), 
        .big_immediate(big_immediate),
        .small_immediate(small_immediate)
    );

    // ALU
    wire [WORD_SIZE-1:0] alu_out;
    alu arithmetic_logic_unit (
        .clock(clock),
        .reset(reset),
        .opcode(opcode),
        .input1(reg_dest),
        .input2(reg_src),
        .alu_enable(is_alu_operation),
        .alu_out(alu_out)
    );

    // Memory Interface
    output wire [MEM_ADDR_SIZE-1:0] mem_address;
    output wire [WORD_SIZE-1:0] mem_data;
    output wire mem_read, mem_write;
    input wire [WORD_SIZE-1:0] mem_out;

    assign reg_val = (opcode == `LOAD) ? mem_read_data 
        : (opcode == `LUI) ? {big_immediate, {WORD_SIZE-BIG_IMM_SIZE{1'b0}}}
        : (opcode == `LI) ? {{WORD_SIZE-BIG_IMM_SIZE{1'b0}}, big_immediate}
        : alu_out;

    // Control unit with state machine
    output wire [3:0] state;
    control ctrl(clock,
        opcode, is_alu_operation,
        fetch_, reg_load_, alu_, mem_load_, mem_store_, reg_store_, next_, reset_, halt_,
        state);

    // Branching
    wire branch = (opcode == `BEQ && reg_out1 == reg_out2) || (opcode == `BNE && reg_out1 != reg_out2);
    // Check if small_immediate is negative
    wire small_immediate_negative = small_immediate[SMALL_IMM_SIZE-1];
    // Check if instruction is a branch and then apply 2's complement if needed
    assign pc_value = branch ? (small_immediate_negative ? (~small_immediate+1): small_immediate) : 1; // Add 1 to PC if not branching

endmodule