module cpu(
    clock, reset, execute, halted,
    mem_address, mem_read_data, mem_write_data, mem_read, mem_write,
    state, opcode // debug outputs
);

    `include "parameters.vh"

    input wire clock;
    input wire reset;
    input wire execute;
    output wire halted;

    // Memory interface
    input wire [2*WORD_SIZE-1:0] mem_read_data;
    output wire [2*MEM_ADDR_SIZE-1:0] mem_address;
    output wire [2*WORD_SIZE-1:0] mem_write_data;
    output wire mem_read, mem_write;

    // Control signals
    wire do_fetch, do_reg_load, do_alu, do_mem_load, do_mem_store, do_reg_store, do_next, do_reset, do_halt;

    // Program counter
    wire [2*WORD_SIZE-1:0] pc_value;
    wire [2*MEM_ADDR_SIZE-1:0] program_counter;
    program_counter pc (
        .clock(clock),
        .reset_enable(reset),  // may need to be connected to do_reset
        .update_enable(do_next),
        .value(pc_value),
        .out(program_counter)
    );

    // Register file
    wire [2*REG_ADDR_SIZE-1:0] reg_dest, reg_src;
    wire [2*WORD_SIZE-1:0] reg_val;
    wire [2*WORD_SIZE-1:0] reg_out1, reg_out2;
    registers regs (
        .clock(clock),
        .get_enable(do_reg_load),
        .set_enable(do_reg_store),
        .reset_enable(reset),  // may need to be connected to do_reset
        .num1(reg_dest),
        .num2(reg_src),
        .set_val(reg_val),
        .out1(reg_out1),
        .out2(reg_out2)
    );

    // Instruction fetching
    wire [2*WORD_SIZE-1:0] instruction;
    fetch_instruction fetch (
        .clock(clock),
        .instruction_memory(mem_read_data),
        .fetch_enable(do_fetch),
        .instruction(instruction)
    );

    // Instruction decode
    output wire [2*OPCODE_SIZE-1:0] opcode; // for debugging
    wire [2*REG_ADDR_SIZE-1:0] reg1, reg2;
    wire is_alu_operation;
    wire [2*BIG_IMM_SIZE-1:0] big_immediate;
    wire [2*SMALL_IMM_SIZE-1:0] small_immediate;
    decode_instruction decode (
        .instruction(instruction),
        .opcode(opcode),
        .is_alu_operation(is_alu_operation),
        .reg_dest(reg_dest),
        .reg_src(reg_src),
        .big_immediate(big_immediate),
        .small_immediate(small_immediate)
    );

    // Attach decoded register addresses to register file
    assign reg_dest = reg1;
    assign reg_src = reg2;
    assign reg_val = (opcode == `LOAD) ? mem_read_data 
        : (opcode == `MV) ? reg_out2
        : (opcode == `LUI) ? {`_0, big_immediate, {(WORD_SIZE-BIG_IMM_SIZE-1){`_0}}} // Zero the lower 4 trits after the big immediate
        : (opcode == `LI) ? ((reg_out1 & {{WORD_SIZE-BIG_IMM_SIZE{2'b11}}, {BIG_IMM_SIZE{`_0}}}) | big_immediate) // Keep the upper 5 trits of reg_out1 and update lower 4 trits
        : alu_out;

    // ALU
    wire [2*WORD_SIZE-1:0] alu_in_1, alu_in_2;
    wire [2*WORD_SIZE-1:0] alu_out;
    ternary_alu arithmetic_logic_unit (
        .clock(clock),
        .opcode(opcode),
        .input1(alu_in_1),
        .input2(alu_in_2),
        .alu_enable(do_alu),
        .alu_out(alu_out)
    );

    // attach ALU inputs to register outputs/immediate
    assign alu_in_1 = reg_out1;
    assign alu_in_2 = (opcode == `ADDI) || (opcode == `ANDI) ? {{WORD_SIZE-BIG_IMM_SIZE{`_0}}, big_immediate} : reg_out2;

    // Control unit with state machine
    output wire [3:0] state; // for debugging
    control ctrl (
        .clock(clock),
        .reset(reset),
        .execute(execute),
        .opcode(opcode),
        .is_alu_operation(is_alu_operation),
        .do_fetch(do_fetch),
        .do_reg_load(do_reg_load),
        .do_alu(do_alu),
        .do_mem_load(do_mem_load),
        .do_mem_store(do_mem_store),
        .do_reg_store(do_reg_store),
        .do_next(do_next),
        .do_reset(do_reset),
        .do_halt(do_halt),
        .state(state)
    );

    // Memory interface
    assign mem_address = do_fetch ? program_counter : reg_out1;
    assign mem_write_data = reg_out1;
    assign mem_read = do_fetch || do_mem_load;
    assign mem_write = do_mem_store;

    // Branching
    wire branch = ((opcode == `BEQ) && (reg_out1[1:0] == `_1)) || ((opcode == `BNE) && (reg_out1 == `_0));
    assign pc_value = branch ? big_immediate : {{(WORD_SIZE-1){`_0}}, `_1_}; // Add 1 to PC if not branching

    // Halt
    assign halted = do_halt;

endmodule