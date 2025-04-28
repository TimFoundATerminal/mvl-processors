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

    // Task to save counts to a CSV file
    task save_counts;
        input [8*100:1] filename; // Can store a string up to 100 characters
        integer file;
    begin
        // Open file for writing
        file = $fopen(filename, "w");
        
        // Check if file was opened successfully
        if (file == 0) begin
            $display("Error: Could not open file %s", filename);
        end else begin
            // Write header
            $fwrite(file, "Gate,Count\n");
            
            // Write gate counts
            $fwrite(file, "NOT,%0d\n", not_count);
            $fwrite(file, "AND,%0d\n", and_count);
            $fwrite(file, "OR,%0d\n", or_count);
            $fwrite(file, "XOR,%0d\n", xor_count);
            
            // Close the file
            $fclose(file);
            $display("Gate counts saved successfully");
        end
    end
    endtask
endmodule


/*
* Single bit operations
*/

module not_gate(input wire a, input wire enable, output wire b);
    assign b = ~a;

    //Increment the gate counter for NOT gate only when enabled
    always @(posedge enable) begin
        counter.not_count = counter.not_count + 1;
    end
endmodule

module and_gate(input wire a, b, enable, output wire c);
    assign c = a & b;

    //Increment the gate counter for AND gate only when enabled
    always @(posedge enable) begin
        counter.and_count = counter.and_count + 1;
    end
endmodule

module or_gate(input wire a, b, input wire enable, output wire c);
    assign c = a | b;

    //Increment the gate counter for OR gate only when enabled
    always @(posedge enable) begin
        counter.or_count = counter.or_count + 1;
    end
endmodule

module xor_gate(input wire a, b, input wire enable, output wire c);
    assign c = a ^ b;

    //Increment the gate counter for XOR gate only when enabled
    always @(posedge enable) begin
        counter.xor_count = counter.xor_count + 1;
    end
endmodule

module half_adder(a, b, enable, sum, carry);
    input a, b, enable;
    output sum, carry;

    // XOR gate for sum
    xor_gate xor_g(a, b, enable, sum);
    // AND gate for carry
    and_gate and_g(a, b, enable, carry);
endmodule

module full_adder(a, b, carry_in, enable, sum, carry_out);
    input a, b, carry_in, enable;
    output sum, carry_out;

    wire sum1, carry1, carry2;

    // First half adder
    half_adder ha1(a, b, enable, sum1, carry1);
    // Second half adder
    half_adder ha2(sum1, carry_in, enable, sum, carry2);

    // OR gate for carry_out
    or_gate or_g(carry1, carry2, enable, carry_out);

endmodule

/*
* ALU operations over bit strings of length WORD_SIZE = 16
*/

module binary_not #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, 
    input wire enable,
    output wire [WIDTH-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: not_loop
            not_gate ng(a[i], enable, out[i]);
        end
    endgenerate
endmodule

module binary_and #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, 
    input wire [WIDTH-1:0] b, 
    input wire enable,
    output wire [WIDTH-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: and_loop
            and_gate ag(a[i], b[i], enable, out[i]);
        end
    endgenerate
endmodule

module binary_or #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, 
    input wire [WIDTH-1:0] b, 
    input wire enable, 
    output wire [WIDTH-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: or_loop
            or_gate og(a[i], b[i], enable, out[i]);
        end
    endgenerate
endmodule

module binary_xor #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, 
    input wire [WIDTH-1:0] b, 
    input wire enable,
    output wire [WIDTH-1:0] out
);
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: xor_loop
            xor_gate xg(a[i], b[i], enable, out[i]);
        end
    endgenerate
endmodule

module ripple_carry_adder #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a, 
    input wire [WIDTH-1:0] b, 
    input wire enable,
    input wire carry_in,
    output wire [WIDTH-1:0] sum
);
    wire [WIDTH:0] carry; // Extra bit for the carry out

    assign carry[0] = carry_in; // Initial carry is the carry_in (used in subtractor)

    // Full adder chain
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: adder_loop
            full_adder fa(
                .a(a[i]),
                .b(b[i]),
                .carry_in(carry[i]),
                .enable(enable),
                .sum(sum[i]),
                .carry_out(carry[i+1])
            );
        end
    endgenerate
endmodule

module ripple_carry_subtractor #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire enable,
    output wire [WIDTH-1:0] diff
);
    wire [WIDTH-1:0] b_complement;

    // Perform 2's complement by inverting b and adding 1
    binary_not #(WIDTH) not_b(b, enable, b_complement);

    ripple_carry_adder #(WIDTH) adder(
        .a(a),
        .b(b_complement),
        .enable(enable),
        .carry_in(1'b1), // Add 1 to complete the 2's complement
        .sum(diff)
    );

endmodule

module binary_equality #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire enable,
    output wire [WIDTH-1:0] out
);
    wire [WIDTH:0] eq_chain;
    
    // Initialize: assume equal at the start
    assign eq_chain[0] = 1'b1;
    
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: eq_bit_loop
            wire xor_result, eq_bit, and_result;
            
            xor_gate xg(a[i], b[i], enable, xor_result);
            not_gate ng(xor_result, enable, eq_bit);
            
            and_gate ag(eq_chain[i], eq_bit, enable, eq_chain[i+1]);
        end
    endgenerate
    
    assign out = {{(WIDTH-1){1'b0}}, eq_chain[WIDTH-1]};
endmodule

module binary_less_than #(parameter WIDTH = 16)(
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire enable,
    output wire [WIDTH-1:0] out
);
    // This array holds the comparison results at each bit position
    wire [WIDTH:0] comparison;
    
    // Default case: If all bits are equal, a is not less than b
    assign comparison[WIDTH] = 1'b0;
    
    genvar i;
    generate
        for (i = WIDTH-1; i >= 0; i = i - 1) begin: bit_compare
            // Temporary wires for bit-level operations
            wire a_is_0, b_is_1, a_bit_lt_b;     // For checking current bit
            wire bits_equal, prev_result_and;     // For handling equal bits
            wire result_at_bit;                   // Final result at this bit
            
            // Check if a[i] = 0
            not_gate not_a(b[i], enable, b_is_0);
            
            // Check if a[i] = 0 and b[i] = 1 (the case where a < b at this bit)
            and_gate b_lt_a(b_is_0, a[i], enable, b_bit_lt_a);
            
            // Check if bits are equal
            wire bit_xor;
            xor_gate bits_xor(b[i], a[i], enable, bit_xor);
            not_gate bits_eq(bit_xor, enable, bits_equal);
            
            // If current bits are equal, use the previous comparison result
            and_gate prev_and(bits_equal, comparison[i+1], enable, prev_result_and);
            
            // Combine: a < b at this position if a[i] < b[i] or (bits equal and a < b from previous)
            or_gate combine(b_bit_lt_a, prev_result_and, enable, comparison[i]);
        end
    endgenerate
    
    // The final comparison result is at bit 0
    assign out = {{(WIDTH-1){1'b0}}, comparison[0]};
endmodule


module alu(clock, opcode, input1, input2, alu_enable, alu_out);

    `include "parameters.vh"

    input wire clock, alu_enable;
    input wire [OPCODE_SIZE-1:0] opcode;
    input wire [WORD_SIZE-1:0] input1, input2;
    output reg [WORD_SIZE-1:0] alu_out;

    // Generate operation-specific enable signals
    wire not_enable = alu_enable && (opcode == `NOT);
    wire and_enable = alu_enable && (opcode == `AND || opcode == `ANDI);
    wire or_enable = alu_enable && (opcode == `OR);
    wire xor_enable = alu_enable && (opcode == `XOR);
    wire add_enable = alu_enable && (opcode == `ADD || opcode == `ADDI);
    wire sub_enable = alu_enable && (opcode == `SUB);
    wire comp_enable = alu_enable && (opcode == `COMP);
    wire lt_enable = alu_enable && (opcode == `LT);
    wire eq_enable = alu_enable && (opcode == `EQ);

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
    binary_not #(WORD_SIZE) not_gate(input1, not_enable, not_out);
    binary_and #(WORD_SIZE) and_gate(input1, input2, and_enable, and_out);
    binary_or #(WORD_SIZE) or_gate(input1, input2, or_enable, or_out);
    binary_xor #(WORD_SIZE) xor_gate(input1, input2, xor_enable, xor_out);

    // set ground to binary equivalent of 0
    wire carry_in = 1'b0;
    ripple_carry_adder #(WORD_SIZE) adder(input1, input2, add_enable, carry_in, add_out);
    ripple_carry_subtractor #(WORD_SIZE) subtractor(input1, input2, sub_enable, sub_out);
    binary_equality #(WORD_SIZE) equality(input1, input2, eq_enable, eq_out);
    binary_less_than #(WORD_SIZE) less_than(input1, input2, lt_enable, lt_out);

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
                    alu_out <= sub_out;
                end
                `COMP: begin
                    alu_out <= (input1 == input2);  // Needs to be implemented as a module
                end
                `LT: begin
                    alu_out <= lt_out;   // Needs to be implemented as a module
                end
                `EQ: begin
                    alu_out <= eq_out;  // Needs to be implemented as a module
                end
                default: begin
                    alu_out <= 0; // Default case to avoid latches
                end
                // All the immediate instructions can use the same circuitry as the memory instructions
            endcase
        end
    end

endmodule