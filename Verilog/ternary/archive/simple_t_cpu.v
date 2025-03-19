`define T_POS  2'b01    // Represents +1
`define T_ZERO 2'b00    // Represents  0
`define T_NEG  2'b10    // Represents -1

module ternary_cpu(
    clock,
    reset,
    alu_out
);

input clock, reset;
output reg [1:0] alu_out;  // Changed to ternary output (2-bit encoding)

// Registers - now using ternary values
reg [1:0] register_file [0:1];  // Two ternary registers
reg [1:0] state;                // Ternary state
reg [1:0] program_counter;      // Ternary program counter

// Program memory stores ternary instructions
reg [5:0] program_memory [255:0];  // 3 ternary values per instruction (6 bits total)

// Internal buses - breaking down the ternary instruction
wire [1:0] opcode = program_memory[program_counter][5:4];      // Ternary opcode
wire [1:0] reg_dest = program_memory[program_counter][3:2];    // Ternary register select
wire [1:0] reg_src = program_memory[program_counter][1:0];     // Ternary register select

// Ternary ALU function
function [1:0] ternary_alu;
    input [1:0] a;
    input [1:0] b;
    input [1:0] op;
    begin
        case (op)
            `T_NEG: begin  // Subtraction
                case ({a, b})
                    {`T_POS, `T_POS}: ternary_alu = `T_ZERO;
                    {`T_POS, `T_ZERO}: ternary_alu = `T_POS;
                    {`T_POS, `T_NEG}: ternary_alu = `T_POS;
                    {`T_ZERO, `T_POS}: ternary_alu = `T_NEG;
                    {`T_ZERO, `T_ZERO}: ternary_alu = `T_ZERO;
                    {`T_ZERO, `T_NEG}: ternary_alu = `T_POS;
                    {`T_NEG, `T_POS}: ternary_alu = `T_NEG;
                    {`T_NEG, `T_ZERO}: ternary_alu = `T_NEG;
                    {`T_NEG, `T_NEG}: ternary_alu = `T_ZERO;
                    default: ternary_alu = `T_ZERO;
                endcase
            end
            `T_ZERO: begin  // Addition
                case ({a, b})
                    {`T_POS, `T_POS}: ternary_alu = `T_POS;
                    {`T_POS, `T_ZERO}: ternary_alu = `T_POS;
                    {`T_POS, `T_NEG}: ternary_alu = `T_ZERO;
                    {`T_ZERO, `T_POS}: ternary_alu = `T_POS;
                    {`T_ZERO, `T_ZERO}: ternary_alu = `T_ZERO;
                    {`T_ZERO, `T_NEG}: ternary_alu = `T_NEG;
                    {`T_NEG, `T_POS}: ternary_alu = `T_ZERO;
                    {`T_NEG, `T_ZERO}: ternary_alu = `T_NEG;
                    {`T_NEG, `T_NEG}: ternary_alu = `T_NEG;
                    default: ternary_alu = `T_ZERO;
                endcase
            end
            `T_POS: begin  // MIN operation
                case ({a, b})
                    {`T_POS, `T_POS}: ternary_alu = `T_POS;
                    {`T_POS, `T_ZERO}: ternary_alu = `T_ZERO;
                    {`T_POS, `T_NEG}: ternary_alu = `T_NEG;
                    {`T_ZERO, `T_POS}: ternary_alu = `T_ZERO;
                    {`T_ZERO, `T_ZERO}: ternary_alu = `T_ZERO;
                    {`T_ZERO, `T_NEG}: ternary_alu = `T_NEG;
                    {`T_NEG, `T_POS}: ternary_alu = `T_NEG;
                    {`T_NEG, `T_ZERO}: ternary_alu = `T_NEG;
                    {`T_NEG, `T_NEG}: ternary_alu = `T_NEG;
                    default: ternary_alu = `T_ZERO;
                endcase
            end
            default: ternary_alu = `T_ZERO;
        endcase
    end
endfunction

always @(posedge clock or posedge reset) begin 
    if (reset) begin
        program_counter <= `T_ZERO;
        register_file[0] <= `T_ZERO;
        register_file[1] <= `T_ZERO;
        alu_out <= `T_ZERO;
        state <= `T_ZERO;
    end else begin
        case (state)
            `T_ZERO: begin  // Fetch
                state <= `T_POS;
            end
            `T_POS: begin  // Decode and Execute
                case (opcode)
                    `T_NEG: alu_out <= ternary_alu(register_file[0], register_file[1], `T_NEG);  // SUB
                    `T_ZERO: alu_out <= ternary_alu(register_file[0], register_file[1], `T_ZERO); // ADD
                    `T_POS: alu_out <= ternary_alu(register_file[0], register_file[1], `T_POS);   // MIN
                    default: alu_out <= `T_ZERO;
                endcase
                state <= `T_NEG;
            end
            `T_NEG: begin  // Write Back
                case (opcode)
                    `T_NEG, `T_ZERO, `T_POS: register_file[0] <= alu_out;
                endcase
                program_counter <= ternary_alu(program_counter, `T_POS, `T_ZERO);  // Increment PC
                state <= `T_ZERO;
            end
            default: state <= `T_ZERO;
        endcase
    end
end

endmodule