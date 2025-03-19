module ternary_adder_1bit(
    input [1:0] a,
    input [1:0] b,
    input [1:0] carry_in,
    output [1:0] sum,
    output [1:0] carry_out
);

    `include "parameters.vh"

    // Helper function for ternary addition (returns carry and sum)
    function [3:0] ternary_add_step;
        input [1:0] trit1, trit2;
        begin
            case({trit1, trit2})
                {`_1, `_1}: ternary_add_step = {`_1, `_1_};  // -1 + -1 = -2 = carry -1, sum 1
                {`_1, `_0}: ternary_add_step = {`_0, `_1};   // -1 + 0 = -1
                {`_1, `_1_}: ternary_add_step = {`_0, `_0};  // -1 + 1 = 0
                {`_0, `_1}: ternary_add_step = {`_0, `_1};   // 0 + -1 = -1
                {`_0, `_0}: ternary_add_step = {`_0, `_0};   // 0 + 0 = 0
                {`_0, `_1_}: ternary_add_step = {`_0, `_1_}; // 0 + 1 = 1
                {`_1_, `_1}: ternary_add_step = {`_0, `_0};  // 1 + -1 = 0
                {`_1_, `_0}: ternary_add_step = {`_0, `_1_}; // 1 + 0 = 1
                {`_1_, `_1_}: ternary_add_step = {`_1_, `_1}; // 1 + 1 = 2 = carry 1, sum -1
                default: ternary_add_step = {`_0, `_0};
            endcase
        end
    endfunction
    
    // First add a and b, then add the result to carry_in
    wire [3:0] step1, step2;
    
    // First addition: a + b
    assign step1 = ternary_add_step(a, b);
    
    // Second addition: (a+b result) + carry_in
    assign step2 = ternary_add_step(step1[1:0], carry_in);
    
    // Final sum is the result of the second addition
    assign sum = step2[1:0];
    
    // Combine the carries from both addition steps
    assign carry_out = (step1[3:2] == `_0) ? step2[3:2] :
                       (step2[3:2] == `_0) ? step1[3:2] :
                       (step1[3:2] == `_1_ && step2[3:2] == `_1_) ? `_1 :  // 1+1=-1 with carry 1
                       (step1[3:2] == `_1 && step2[3:2] == `_1) ? `_1_ :   // -1+-1=1 with carry -1
                       `_0;  // Otherwise carries cancel out
endmodule

// Ternary ripple carry adder - fixed for 9 trits
module ternary_ripple_carry_adder(input1, input2, result);

    `include "parameters.vh"
    
    input [2*WORD_SIZE-1:0] input1, input2;
    output [2*WORD_SIZE-1:0] result;
    
    // Wire to propagate carry
    wire [1:0] carry [0:WORD_SIZE];
    
    assign carry[0] = `_0; // Initial carry is 0
    
    // Explicitly instantiate all 9 adder stages
    ternary_adder_1bit adder0(
        .a(input1[1:0]),
        .b(input2[1:0]),
        .carry_in(carry[0]),
        .sum(result[1:0]),
        .carry_out(carry[1])
    );
    
    ternary_adder_1bit adder1(
        .a(input1[3:2]),
        .b(input2[3:2]),
        .carry_in(carry[1]),
        .sum(result[3:2]),
        .carry_out(carry[2])
    );
    
    ternary_adder_1bit adder2(
        .a(input1[5:4]),
        .b(input2[5:4]),
        .carry_in(carry[2]),
        .sum(result[5:4]),
        .carry_out(carry[3])
    );
    
    ternary_adder_1bit adder3(
        .a(input1[7:6]),
        .b(input2[7:6]),
        .carry_in(carry[3]),
        .sum(result[7:6]),
        .carry_out(carry[4])
    );
    
    ternary_adder_1bit adder4(
        .a(input1[9:8]),
        .b(input2[9:8]),
        .carry_in(carry[4]),
        .sum(result[9:8]),
        .carry_out(carry[5])
    );
    
    ternary_adder_1bit adder5(
        .a(input1[11:10]),
        .b(input2[11:10]),
        .carry_in(carry[5]),
        .sum(result[11:10]),
        .carry_out(carry[6])
    );
    
    ternary_adder_1bit adder6(
        .a(input1[13:12]),
        .b(input2[13:12]),
        .carry_in(carry[6]),
        .sum(result[13:12]),
        .carry_out(carry[7])
    );
    
    ternary_adder_1bit adder7(
        .a(input1[15:14]),
        .b(input2[15:14]),
        .carry_in(carry[7]),
        .sum(result[15:14]),
        .carry_out(carry[8])
    );
    
    ternary_adder_1bit adder8(
        .a(input1[17:16]),
        .b(input2[17:16]),
        .carry_in(carry[8]),
        .sum(result[17:16]),
        .carry_out(carry[9])
    );
endmodule

// Main ternary ALU module
module ternary_alu(clock, opcode, input1, input2, alu_enable, alu_out);

    `include "parameters.vh"
    
    input wire clock, alu_enable;
    input wire [2*OPCODE_SIZE-1:0] opcode;  // 3 trits = 6 bits
    input wire [2*WORD_SIZE-1:0] input1, input2;  // Each trit requires 2 bits (18 bits total)
    output reg [2*WORD_SIZE-1:0] alu_out;

    // Helper function to perform ternary NOT operation on a single trit
    function [1:0] ternary_not;
        input [1:0] trit;
        begin
            case(trit)
                `_1: ternary_not = `_1_;  // NOT(-1) = 1
                `_0: ternary_not = `_0;   // NOT(0) = 0
                `_1_: ternary_not = `_1;  // NOT(1) = -1
                default: ternary_not = `_0;
            endcase
        end
    endfunction

    // Helper function to perform ternary AND operation on two trits
    function [1:0] ternary_and;
        input [1:0] trit1, trit2;
        begin
            case({trit1, trit2})
                {`_1, `_1}: ternary_and = `_1;    // AND(-1, -1) = -1
                {`_1, `_0}: ternary_and = `_1;    // AND(-1, 0) = -1
                {`_1, `_1_}: ternary_and = `_1;   // AND(-1, 1) = -1
                {`_0, `_1}: ternary_and = `_1;    // AND(0, -1) = -1
                {`_0, `_0}: ternary_and = `_0;    // AND(0, 0) = 0
                {`_0, `_1_}: ternary_and = `_0;   // AND(0, 1) = 0
                {`_1_, `_1}: ternary_and = `_1;   // AND(1, -1) = -1
                {`_1_, `_0}: ternary_and = `_0;   // AND(1, 0) = 0
                {`_1_, `_1_}: ternary_and = `_1_; // AND(1, 1) = 1
                default: ternary_and = `_0;
            endcase
        end
    endfunction

    // Helper function to perform ternary OR operation on two trits
    function [1:0] ternary_or;
        input [1:0] trit1, trit2;
        begin
            case({trit1, trit2})
                {`_1, `_1}: ternary_or = `_1;     // OR(-1, -1) = -1
                {`_1, `_0}: ternary_or = `_1;     // OR(-1, 0) = -1
                {`_1, `_1_}: ternary_or = `_1_;   // OR(-1, 1) = 1
                {`_0, `_1}: ternary_or = `_1;     // OR(0, -1) = -1
                {`_0, `_0}: ternary_or = `_0;     // OR(0, 0) = 0
                {`_0, `_1_}: ternary_or = `_1_;   // OR(0, 1) = 1
                {`_1_, `_1}: ternary_or = `_1_;   // OR(1, -1) = 1
                {`_1_, `_0}: ternary_or = `_1_;   // OR(1, 0) = 1
                {`_1_, `_1_}: ternary_or = `_1_;  // OR(1, 1) = 1
                default: ternary_or = `_0;
            endcase
        end
    endfunction

    // Helper function to perform ternary XOR operation on two trits
    function [1:0] ternary_xor;
        input [1:0] trit1, trit2;
        begin
            case({trit1, trit2})
                {`_1, `_1}: ternary_xor = `_1;    // XOR(-1, -1) = -1
                {`_1, `_0}: ternary_xor = `_1;    // XOR(-1, 0) = -1
                {`_1, `_1_}: ternary_xor = `_0;   // XOR(-1, 1) = 0
                {`_0, `_1}: ternary_xor = `_1;    // XOR(0, -1) = -1
                {`_0, `_0}: ternary_xor = `_0;    // XOR(0, 0) = 0
                {`_0, `_1_}: ternary_xor = `_1_;  // XOR(0, 1) = 1
                {`_1_, `_1}: ternary_xor = `_0;   // XOR(1, -1) = 0
                {`_1_, `_0}: ternary_xor = `_1_;  // XOR(1, 0) = 1
                {`_1_, `_1_}: ternary_xor = `_1;  // XOR(1, 1) = -1
                default: ternary_xor = `_0;
            endcase
        end
    endfunction

    // Instantiate the ternary ripple carry adder
    wire [2*WORD_SIZE-1:0] adder_out;
    ternary_ripple_carry_adder adder(
        .input1(input1),
        .input2(input2),
        .result(adder_out)
    );
    
    // Function to extract a binary value from a ternary value (for shifts)
    function integer ternary_to_binary;
        input [2*WORD_SIZE-1:0] ternary_val;
        integer i, result;
        reg [1:0] current_trit;
        begin
            result = 0;
            for (i = 0; i < WORD_SIZE; i = i + 1) begin
                // Extract the trit using a case statement instead of variable indexing
                case(i)
                    0: current_trit = ternary_val[1:0];
                    1: current_trit = ternary_val[3:2];
                    2: current_trit = ternary_val[5:4];
                    3: current_trit = ternary_val[7:6];
                    4: current_trit = ternary_val[9:8];
                    5: current_trit = ternary_val[11:10];
                    6: current_trit = ternary_val[13:12];
                    7: current_trit = ternary_val[15:14];
                    8: current_trit = ternary_val[17:16];
                    default: current_trit = 2'b00;
                endcase
                
                case(current_trit)
                    `_1: result = result - 1;  // -1 contribution
                    `_1_: result = result + 1; // +1 contribution
                    default: result = result;  // 0 contribution
                endcase
            end
            ternary_to_binary = result;
        end
    endfunction
    
    // Helper function for ternary comparison
    function [1:0] ternary_compare;
        input [2*WORD_SIZE-1:0] a, b;
        integer i;
        reg equal;
        reg [1:0] a_trit, b_trit;
        begin
            equal = 1;
            for (i = 0; i < WORD_SIZE; i = i + 1) begin
                // Extract trits using case statements
                case(i)
                    0: begin a_trit = a[1:0]; b_trit = b[1:0]; end
                    1: begin a_trit = a[3:2]; b_trit = b[3:2]; end
                    2: begin a_trit = a[5:4]; b_trit = b[5:4]; end
                    3: begin a_trit = a[7:6]; b_trit = b[7:6]; end
                    4: begin a_trit = a[9:8]; b_trit = b[9:8]; end
                    5: begin a_trit = a[11:10]; b_trit = b[11:10]; end
                    6: begin a_trit = a[13:12]; b_trit = b[13:12]; end
                    7: begin a_trit = a[15:14]; b_trit = b[15:14]; end
                    8: begin a_trit = a[17:16]; b_trit = b[17:16]; end
                    default: begin a_trit = 2'b00; b_trit = 2'b00; end
                endcase
                
                if (a_trit != b_trit) begin
                    equal = 0;
                end
            end
            ternary_compare = equal ? `_1_ : `_0;
        end
    endfunction
    
    // Wire declarations for intermediate results
    wire [2*WORD_SIZE-1:0] not_result;
    wire [2*WORD_SIZE-1:0] and_result;
    wire [2*WORD_SIZE-1:0] or_result;
    wire [2*WORD_SIZE-1:0] xor_result;
    wire [2*WORD_SIZE-1:0] comp_result;
    wire [2*WORD_SIZE-1:0] sub_result;
    reg [2*WORD_SIZE-1:0] sri_result;
    reg [2*WORD_SIZE-1:0] sli_result;
    
    // NOT operation
    assign not_result[1:0] = ternary_not(input1[1:0]);
    assign not_result[3:2] = ternary_not(input1[3:2]);
    assign not_result[5:4] = ternary_not(input1[5:4]);
    assign not_result[7:6] = ternary_not(input1[7:6]);
    assign not_result[9:8] = ternary_not(input1[9:8]);
    assign not_result[11:10] = ternary_not(input1[11:10]);
    assign not_result[13:12] = ternary_not(input1[13:12]);
    assign not_result[15:14] = ternary_not(input1[15:14]);
    assign not_result[17:16] = ternary_not(input1[17:16]);
    
    // AND operation
    assign and_result[1:0] = ternary_and(input1[1:0], input2[1:0]);
    assign and_result[3:2] = ternary_and(input1[3:2], input2[3:2]);
    assign and_result[5:4] = ternary_and(input1[5:4], input2[5:4]);
    assign and_result[7:6] = ternary_and(input1[7:6], input2[7:6]);
    assign and_result[9:8] = ternary_and(input1[9:8], input2[9:8]);
    assign and_result[11:10] = ternary_and(input1[11:10], input2[11:10]);
    assign and_result[13:12] = ternary_and(input1[13:12], input2[13:12]);
    assign and_result[15:14] = ternary_and(input1[15:14], input2[15:14]);
    assign and_result[17:16] = ternary_and(input1[17:16], input2[17:16]);
    
    // OR operation
    assign or_result[1:0] = ternary_or(input1[1:0], input2[1:0]);
    assign or_result[3:2] = ternary_or(input1[3:2], input2[3:2]);
    assign or_result[5:4] = ternary_or(input1[5:4], input2[5:4]);
    assign or_result[7:6] = ternary_or(input1[7:6], input2[7:6]);
    assign or_result[9:8] = ternary_or(input1[9:8], input2[9:8]);
    assign or_result[11:10] = ternary_or(input1[11:10], input2[11:10]);
    assign or_result[13:12] = ternary_or(input1[13:12], input2[13:12]);
    assign or_result[15:14] = ternary_or(input1[15:14], input2[15:14]);
    assign or_result[17:16] = ternary_or(input1[17:16], input2[17:16]);
    
    // XOR operation
    assign xor_result[1:0] = ternary_xor(input1[1:0], input2[1:0]);
    assign xor_result[3:2] = ternary_xor(input1[3:2], input2[3:2]);
    assign xor_result[5:4] = ternary_xor(input1[5:4], input2[5:4]);
    assign xor_result[7:6] = ternary_xor(input1[7:6], input2[7:6]);
    assign xor_result[9:8] = ternary_xor(input1[9:8], input2[9:8]);
    assign xor_result[11:10] = ternary_xor(input1[11:10], input2[11:10]);
    assign xor_result[13:12] = ternary_xor(input1[13:12], input2[13:12]);
    assign xor_result[15:14] = ternary_xor(input1[15:14], input2[15:14]);
    assign xor_result[17:16] = ternary_xor(input1[17:16], input2[17:16]);
    
    // Comparison implementation
    assign comp_result = {{(2*WORD_SIZE-2){`_0}}, ternary_compare(input1, input2)};
    
    // Subtraction (negate input2 and add)
    wire [2*WORD_SIZE-1:0] neg_input2;
    
    // Negate input2
    assign neg_input2[1:0] = ternary_not(input2[1:0]);
    assign neg_input2[3:2] = ternary_not(input2[3:2]);
    assign neg_input2[5:4] = ternary_not(input2[5:4]);
    assign neg_input2[7:6] = ternary_not(input2[7:6]);
    assign neg_input2[9:8] = ternary_not(input2[9:8]);
    assign neg_input2[11:10] = ternary_not(input2[11:10]);
    assign neg_input2[13:12] = ternary_not(input2[13:12]);
    assign neg_input2[15:14] = ternary_not(input2[15:14]);
    assign neg_input2[17:16] = ternary_not(input2[17:16]);
    
    ternary_ripple_carry_adder subtractor(
        .input1(input1),
        .input2(neg_input2),
        .result(sub_result)
    );

    // // Shift implementations
    // integer shift_amount;
    // integer j;
    
    // // Right shift implementation
    // always @(*) begin
    //     shift_amount = ternary_to_binary(input2);
    //     // Limit to reasonable shift amounts
    //     if (shift_amount < 0) shift_amount = 0;
    //     if (shift_amount >= WORD_SIZE) shift_amount = WORD_SIZE - 1;
        
    //     sri_result = input1;
    //     for (j = 0; j < shift_amount; j = j + 1) begin
    //         // Right shift by manually moving bits
    //         sri_result[1:0] = sri_result[3:2];
    //         sri_result[3:2] = sri_result[5:4];
    //         sri_result[5:4] = sri_result[7:6];
    //         sri_result[7:6] = sri_result[9:8];
    //         sri_result[9:8] = sri_result[11:10];
    //         sri_result[11:10] = sri_result[13:12];
    //         sri_result[13:12] = sri_result[15:14];
    //         sri_result[15:14] = sri_result[17:16];
    //         sri_result[17:16] = `_0; // Shift in zeros
    //     end
    // end
    
    // // Left shift implementation
    // always @(*) begin
    //     shift_amount = ternary_to_binary(input2);
    //     // Limit to reasonable shift amounts
    //     if (shift_amount < 0) shift_amount = 0;
    //     if (shift_amount >= WORD_SIZE) shift_amount = WORD_SIZE - 1;
        
    //     sli_result = input1;
    //     for (j = 0; j < shift_amount; j = j + 1) begin
    //         // Left shift by manually moving bits
    //         sli_result[17:16] = sli_result[15:14];
    //         sli_result[15:14] = sli_result[13:12];
    //         sli_result[13:12] = sli_result[11:10];
    //         sli_result[11:10] = sli_result[9:8];
    //         sli_result[9:8] = sli_result[7:6];
    //         sli_result[7:6] = sli_result[5:4];
    //         sli_result[5:4] = sli_result[3:2];
    //         sli_result[3:2] = sli_result[1:0];
    //         sli_result[1:0] = `_0; // Shift in zeros
    //     end
    // end
    
    // Main logic
    always @(posedge clock) begin
        if (alu_enable) begin
            case (opcode)
                `NOT: begin
                    alu_out <= not_result;
                end
                `AND, `ANDI: begin
                    alu_out <= and_result;
                    // alu_out <= {`_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_};
                end
                `OR: begin
                    alu_out <= or_result;
                    // alu_out <= {`_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_};
                end
                `XOR: begin
                    alu_out <= xor_result;
                    // alu_out <= {`_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_};
                end
                `ADD, `ADDI: begin
                    alu_out <= adder_out;
                    // alu_out <= {`_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_};
                end
                `SUB: begin
                    alu_out <= sub_result;
                    // alu_out <= {`_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_};
                end
                `COMP: begin
                    alu_out <= comp_result;
                    // alu_out <= {`_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_};
                end
                // `SRI: begin
                //     alu_out <= sri_result;
                // end
                // `SLI: begin
                //     alu_out <= sli_result;
                // end
                default: begin
                    $display("Unknown opcode %h", opcode);
                    alu_out <= input1; // Default to passing through input1
                end
            endcase
        end
    end

endmodule