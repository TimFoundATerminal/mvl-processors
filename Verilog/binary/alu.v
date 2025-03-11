
module half_adder(a, b, sum, carry);
    input a, b;
    output sum, carry;
    // TODO: Implement a global counter for the number of gates used

    // XOR gate for sum
    assign sum = a ^ b;
    // AND gate for carry
    assign carry = a & b;

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
    input wire [4:0] opcode;
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
                    // alu_out <= input1 + input2;
                end
                `SUB: begin
                    alu_out <= input1 - input2;
                end
                `COMP: begin
                    alu_out <= (input1 == input2);
                end
                `SRI: begin
                    alu_out <= input1 >> input2;
                end
                `SLI: begin
                    alu_out <= input1 << input2;
                end
                // All the immediate instructions can use the same circuitry as the memory instructions
            endcase
        end
    end

endmodule