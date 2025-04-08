// Static gate counter
module gate_counter_top;
    integer not_count = 0;
    integer and_count = 0;
    integer or_count = 0;
    integer xor_count = 0;
    
    // Task to display counts
    task display_counts;
    begin
        $display("Gate counts: NOT=%0d, AND=%0d, OR=%0d, XOR=%0d", 
                 not_count, and_count, or_count, xor_count);
    end
    endtask
endmodule


/*
* Single bit operations
*/

module not_gate(input wire a, output wire b);
    assign b = ~a;

    //Increment the gate counter for NOT gate
    always @(a) begin
        counter.not_count = counter.not_count + 1;
    end
endmodule

module and_gate(input wire a, b, output wire c);
    assign c = a & b;

    //Increment the gate counter for AND gate
    always @(a or b) begin
        counter.and_count = counter.and_count + 1;
    end
endmodule

module or_gate(input wire a, b, output wire c);
    assign c = a | b;

    //Increment the gate counter for OR gate
    always @(a or b) begin
        counter.or_count = counter.or_count + 1;
    end
endmodule

module xor_gate(input wire a, b, output wire c);
    assign c = a ^ b;

    //Increment the gate counter for XOR gate
    always @(a or b) begin
        counter.xor_count = counter.xor_count + 1;
    end
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

module binary_not #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, 
    output wire [WIDTH-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: not_loop
            not_gate ng(a[i], out[i]);
        end
    endgenerate
endmodule

module binary_and #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, 
    input wire [WIDTH-1:0] b, 
    output wire [WIDTH-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: and_loop
            and_gate ag(a[i], b[i], out[i]);
        end
    endgenerate
endmodule

module binary_or #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, 
    input wire [WIDTH-1:0] b, 
    output wire [WIDTH-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: or_loop
            or_gate og(a[i], b[i], out[i]);
        end
    endgenerate
endmodule

module binary_xor #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, 
    input wire [WIDTH-1:0] b, 
    output wire [WIDTH-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: xor_loop
            xor_gate xg(a[i], b[i], out[i]);
        end
    endgenerate
endmodule

module ripple_carry_adder #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, 
    input wire [WIDTH-1:0] b, 
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

    // Instantiate the outputs for all logic components
    wire [WORD_SIZE-1:0] not_out;
    wire [WORD_SIZE-1:0] and_out;
    wire [WORD_SIZE-1:0] or_out;
    wire [WORD_SIZE-1:0] xor_out;
    wire [WORD_SIZE-1:0] add_out;
    wire [WORD_SIZE-1:0] sub_out;
    wire [WORD_SIZE-1:0] comp_out;
    wire [WORD_SIZE-1:0] lt_out;
    wire [WORD_SIZE-1:0] eq_out;

    // Instantiate the logic components with the appropriate widths
    binary_not #(WORD_SIZE) not_gate(input1, not_out);
    binary_and #(WORD_SIZE) and_gate(input1, input2, and_out);
    binary_or #(WORD_SIZE) or_gate(input1, input2, or_out);
    binary_xor #(WORD_SIZE) xor_gate(input1, input2, xor_out);
    // Insert others here
    ripple_carry_adder #(WORD_SIZE) adder(input1, input2, add_out);

    always @(posedge clock) begin
        if (alu_enable) begin
            case (opcode)
                `NOT: begin
                    alu_out <= not_out;
                end
                `AND, `ANDI: begin
                    alu_out <= and_out;
                end
                `OR: begin
                    alu_out <= or_out;
                end
                `XOR: begin
                    alu_out <= xor_out;
                end
                `ADD, `ADDI: begin
                    alu_out <= add_out;
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