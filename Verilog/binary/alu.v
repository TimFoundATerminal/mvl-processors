// // Static gate count calculator
// module gate_counter #(parameter WIDTH = 16); // Get the width of ripple-carry adder

//   // Static gate counts
//   integer and_gates, or_gates, xor_gates;
  
//   initial begin
//     // In half_adder:
//     // - 1 XOR gate for sum
//     // - 1 AND gate for carry
    
//     // In full_adder:
//     // - 2 half_adders = 2 XOR + 2 AND
//     // - 1 OR gate for final carry_out
    
//     // In ripple_carry_adder with WIDTH bits:
//     // - WIDTH full_adders
    
//     // Calculate total gates:
//     and_gates = WIDTH * 2;     // 2 AND gates per full_adder
//     or_gates = WIDTH * 1;      // 1 OR gate per full_adder
//     xor_gates = WIDTH * 2;     // 2 XOR gates per full_adder
    
//     $display("Static gate count for %0d-bit ripple-carry adder:", WIDTH);
//     $display("AND gates: %0d", and_gates);
//     $display("OR gates: %0d", or_gates);
//     $display("XOR gates: %0d", xor_gates);
//     $display("Total gates: %0d", and_gates + or_gates + xor_gates);
//   end
// endmodule


/*
* Single bit operations
*/

module not_gate(input wire a, output wire b);
    assign b = ~a;
endmodule

module and_gate(input wire a, b, output wire c);
    assign c = a & b;
endmodule

module or_gate(input wire a, b, output wire c);
    assign c = a | b;
endmodule

module xor_gate(input wire a, b, output wire c);
    assign c = a ^ b;
endmodule

module half_adder(a, b, sum, carry);
    input a, b;
    output sum, carry;

    // XOR gate for sum
    xor_gate xor_g(a, b, sum);
    // AND gate for carry
    and_gate and_g(a, b, carry);

endmodule

module full_adder(a, b, carry_in, sum, carry_out);
    input a, b, carry_in;
    output sum, carry_out;

    wire sum1, carry1, carry2;

    // First half adder
    half_adder ha1(a, b, sum1, carry1);
    // Second half adder
    half_adder ha2(sum1, carry_in, sum, carry2);

    // OR gate for carry_out
    assign carry_out = carry1 | carry2;

endmodule

/*
* ALU operations over bit strings of length WORD_SIZE = 16
*/

module ripple_carry_adder #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, b,
    output wire [WIDTH-1:0] sum
);
    wire [WIDTH:0] carry; // Extra bit for the carry out

    assign carry[0] = 1'b0; // Initial carry is 0

    // Full adder chain
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: adder_loop
            full_adder fa(
                .a(a[i]),
                .b(b[i]),
                .carry_in(carry[i]),
                .sum(sum[i]),
                .carry_out(carry[i+1])
            );
        end
    endgenerate

endmodule


module alu(clock, opcode, input1, input2, alu_enable, alu_out);

    `include "parameters.vh"

    input wire clock, alu_enable;
    input wire [OPCODE_SIZE-1:0] opcode;
    input wire [WORD_SIZE-1:0] input1, input2;
    output reg [WORD_SIZE-1:0] alu_out;


    // Instantiate the ripple carry adder plus adder_out
    wire [WORD_SIZE-1:0] adder_out;
    ripple_carry_adder #(WORD_SIZE) adder(input1, input2, adder_out);

    always @(posedge clock) begin
        if (alu_enable) begin
            case (opcode)
                `NOT: begin
                    alu_out <= ~input1;
                end
                `AND, `ANDI: begin
                    alu_out <= input1 & input2;
                end
                `OR: begin
                    alu_out <= input1 | input2;
                end
                `XOR: begin
                    alu_out <= input1 ^ input2;
                end
                `ADD, `ADDI: begin
                    alu_out <= adder_out;
                end
                `SUB: begin
                    alu_out <= input1 - input2;
                end
                `COMP: begin
                    alu_out <= (input1 == input2);
                end
                `LT: begin
                    alu_out <= (input1 < input2);
                end
                `EQ: begin
                    alu_out <= (input1 == input2);
                end
                default: begin
                    alu_out <= 0; // Default case to avoid latches
                end
                // All the immediate instructions can use the same circuitry as the memory instructions
            endcase
        end
    end

endmodule