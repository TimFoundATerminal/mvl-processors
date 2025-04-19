// Gate Counter Module
module gate_counter_top;
    integer not_count = 0;
    integer and_count = 0;
    integer or_count = 0;
    integer xor_count = 0;
    integer any_count = 0;
    integer consensus_count = 0;
    
    // Task to display counts
    task display_counts;
    begin
        $display("Gate counts: NOT=%0d, AND=%0d, OR=%0d, XOR=%0d, ANY=%0d, CONSENSUS=%0d", 
                 not_count, and_count, or_count, xor_count, any_count, consensus_count);
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
            $fwrite(file, "ANY,%0d\n", any_count);
            $fwrite(file, "CONSENSUS,%0d\n", consensus_count);
            
            // Close the file
            $fclose(file);
            $display("Gate counts saved successfully");
        end
    end
    endtask
endmodule



/*
* Ternary ALU gates operating of a single trit (2 bits)
*/

module ternary_negation_1bit(
    input [1:0] a,
    input wire enable,
    output [1:0] neg_out
);

    `include "parameters.vh"

    // Mapping of inputs to outputs for ternary negation gate
    assign neg_out = (a == `_1) ? `_1_ :
              (a == `_1_) ? `_1 :
              `_0;

    // Increment the gate counter for NOT gate
    always @(posedge enable) begin
        counter.not_count = counter.not_count + 1;
    end
endmodule


module ternary_comparator_1trit(a, b, lt_in, eq_in, enable, lt_out, eq_out);
    input [1:0] a, b;   // Single trit inputs (2 bits per trit)
    input lt_in;        // Input is less than so far
    input eq_in;        // Input is equal so far
    input wire enable;  // Enable signal for the comparator
    output lt_out;      // Output is less than
    output eq_out;      // Output is equal
    
    wire is_equal;
    wire a_less_than_b;
    
    // Check if a and b are equal
    assign is_equal = (a == b);
    
    // Check if a < b for this trit
    assign a_less_than_b = 
           ((a == 2'b11) && (b == 2'b00 || b == 2'b01)) || // a = -1, b = 0 or 1
           ((a == 2'b00) && (b == 2'b01));                 // a = 0, b = 1
    
    assign lt_out = lt_in || (eq_in && a_less_than_b);
    
    // Output equal if previous trits were equal and current trits are equal
    assign eq_out = eq_in && is_equal;
endmodule


module ternary_and_1bit(
    input [1:0] a,
    input [1:0] b,
    input wire enable,
    output [1:0] and_out
);

    `include "parameters.vh"

    // Mapping of inputs to outputs for ternary AND gate
    function [1:0] ternary_and_gate;
        input [1:0] trit1, trit2;
        begin
            case({trit1, trit2})
                {`_1, `_1}: ternary_and_gate = `_1;     // AND(-1, -1) = -1
                {`_1, `_0}: ternary_and_gate = `_1;     // AND(-1, 0) = -1
                {`_1, `_1_}: ternary_and_gate = `_1;    // AND(-1, 1) = -1
                {`_0, `_1}: ternary_and_gate = `_1;     // AND(0, -1) = -1
                {`_0, `_0}: ternary_and_gate = `_0;     // AND(0, 0) = 0
                {`_0, `_1_}: ternary_and_gate = `_0;    // AND(0, 1) = 0
                {`_1_, `_1}: ternary_and_gate = `_1;    // AND(1, -1) = -1
                {`_1_, `_0}: ternary_and_gate = `_0;    // AND(1, 0) = 0
                {`_1_, `_1_}: ternary_and_gate = `_1_;  // AND(1, 1) = 1
                default: ternary_and_gate = `_0;
            endcase
        end
    endfunction

    assign and_out = ternary_and_gate(a, b);

    // Increment the gate counter for AND gate
    always @(posedge enable) begin
        counter.and_count = counter.and_count + 1;
    end

endmodule

// Ternary OR Module
module ternary_or_1bit(
    input [1:0] a,
    input [1:0] b,
    input wire enable,
    output [1:0] or_out
);

    `include "parameters.vh"

    // Mapping of inputs to outputs for ternary OR gate
    function [1:0] ternary_or_gate;
        input [1:0] trit1, trit2;
        begin
            case({trit1, trit2})
                {`_1, `_1}: ternary_or_gate = `_1;      // OR(-1, -1) = -1
                {`_1, `_0}: ternary_or_gate = `_1;      // OR(-1, 0) = -1
                {`_1, `_1_}: ternary_or_gate = `_1_;    // OR(-1, 1) = 1
                {`_0, `_1}: ternary_or_gate = `_1;      // OR(0, -1) = -1
                {`_0, `_0}: ternary_or_gate = `_0;      // OR(0, 0) = 0
                {`_0, `_1_}: ternary_or_gate = `_1_;    // OR(0, 1) = 1
                {`_1_, `_1}: ternary_or_gate = `_1_;    // OR(1, -1) = 1
                {`_1_, `_0}: ternary_or_gate = `_1_;    // OR(1, 0) = 1
                {`_1_, `_1_}: ternary_or_gate = `_1_;   // OR(1, 1) = 1
                default: ternary_or_gate = `_0;
            endcase
        end
    endfunction

    assign or_out = ternary_or_gate(a, b);

    // Increment the gate counter for OR gate
    always @(posedge enable) begin
        counter.or_count = counter.or_count + 1;
    end

endmodule


module ternary_xor_1bit(
    input [1:0] a,
    input [1:0] b,
    input wire enable,
    output [1:0] xor_out
);

    `include "parameters.vh"

    // Mapping of inputs to outputs for ternary XOR gate
    function [1:0] ternary_xor_gate;
        input [1:0] trit1, trit2;
        begin
            case({trit1, trit2})
                {`_1, `_1}: ternary_xor_gate = `_1;     // XOR(-1, -1) = -1
                {`_1, `_0}: ternary_xor_gate = `_1;     // XOR(-1, 0) = -1
                {`_1, `_1_}: ternary_xor_gate = `_0;    // XOR(-1, 1) = 0
                {`_0, `_1}: ternary_xor_gate = `_1;     // XOR(0, -1) = -1
                {`_0, `_0}: ternary_xor_gate = `_0;     // XOR(0, 0) = 0
                {`_0, `_1_}: ternary_xor_gate = `_1_;   // XOR(0, 1) = 1
                {`_1_, `_1}: ternary_xor_gate = `_0;    // XOR(1, -1) = 0
                {`_1_, `_0}: ternary_xor_gate = `_1_;   // XOR(1, 0) = 1
                {`_1_, `_1_}: ternary_xor_gate = `_1;   // XOR(1, 1) = -1
                default: ternary_xor_gate = `_0;
            endcase
        end
    endfunction

    assign xor_out = ternary_xor_gate(a, b);

    // Increment the gate counter for XOR gate
    always @(posedge enable) begin
        counter.xor_count = counter.xor_count + 1;
    end

endmodule


module ternary_any_1bit(
    input [1:0] a,
    input [1:0] b,
    input wire enable,
    output [1:0] any_out
);

    `include "parameters.vh"

    // Mapping of inputs to outputs for ternary any gate
    function [1:0] ternary_any_gate;
        input [1:0] trit1, trit2;
        begin
            case({trit1, trit2})
                {`_1, `_1}: ternary_any_gate = {`_1};       // -1 ⊞ -1 = -1
                {`_1, `_0}: ternary_any_gate = {`_1};       // -1 ⊞  0 = -1
                {`_1, `_1_}: ternary_any_gate = {`_0};      // -1 ⊞ +1 =  0
                {`_0, `_1}: ternary_any_gate = {`_1};       //  0 ⊞ -1 = -1
                {`_0, `_0}: ternary_any_gate = {`_0};       //  0 ⊞  0 =  0
                {`_0, `_1_}: ternary_any_gate = {`_1_};     //  0 ⊞ +1 = +1
                {`_1_, `_1}: ternary_any_gate = {`_0};      // +1 ⊞ -1 =  0
                {`_1_, `_0}: ternary_any_gate = {`_1_};     // +1 ⊞  0 = +1
                {`_1_, `_1_}: ternary_any_gate = {`_1_};    // +1 ⊞ +1 = +1
                default: ternary_any_gate = {`_0};
            endcase
        end
    endfunction

    assign any_out = ternary_any_gate(a, b);

    // Increment the gate counter for ANY gate
    always @(posedge enable) begin
        counter.any_count = counter.any_count + 1;
    end

endmodule


module ternary_consensus_1bit(
    input [1:0] a,
    input [1:0] b,
    input wire enable,
    output [1:0] consensus_out
);

    `include "parameters.vh"

    // Mapping of inputs to outputs for ternary consensus gate
    function [1:0] ternary_consensus_gate;
        input [1:0] trit1, trit2;
        begin
            case({trit1, trit2})
                {`_1, `_1}: ternary_consensus_gate = {`_1};       // -1 ⊠ -1 = -1
                {`_1, `_0}: ternary_consensus_gate = {`_0};       // -1 ⊠  0 =  0
                {`_1, `_1_}: ternary_consensus_gate = {`_0};      // -1 ⊠ +1 =  0
                {`_0, `_1}: ternary_consensus_gate = {`_0};       //  0 ⊠ -1 =  0
                {`_0, `_0}: ternary_consensus_gate = {`_0};       //  0 ⊠  0 =  0
                {`_0, `_1_}: ternary_consensus_gate = {`_0};     //  0 ⊠ +1 =  0
                {`_1_, `_1}: ternary_consensus_gate = {`_0};      // +1 ⊠ -1 =  0
                {`_1_, `_0}: ternary_consensus_gate = {`_0};     // +1 ⊠  0 =  0
                {`_1_, `_1_}: ternary_consensus_gate = {`_1_};    // +1 ⊠ +1 = +1
                default: ternary_consensus_gate = {`_0};
            endcase
        end
    endfunction

    assign consensus_out = ternary_consensus_gate(a, b);

    // Increment the gate counter for CONSENSUS gate
    always @(posedge enable) begin
        counter.consensus_count = counter.consensus_count + 1;
    end

endmodule


module ternary_addition_1bit(
    input [1:0] a,
    input [1:0] b,
    input wire enable,
    output [1:0] sum
);

    `include "parameters.vh"

    // Use any and consensus gates to compute the sum
    wire [1:0] consensus_out;
    ternary_consensus_1bit consensus_gate(
        .a(a),
        .b(b),
        .enable(enable),
        .consensus_out(consensus_out)
    );

    wire [1:0] consensus_neg;
    ternary_negation_1bit neg_gate(
        .a(consensus_out),
        .enable(enable),
        .neg_out(consensus_neg)
    );

    wire [1:0] any1_out;
    ternary_any_1bit any_gate1(
        .a(a),
        .b(b),
        .enable(enable),
        .any_out(any1_out)
    );

    wire [1:0] any2_out;
    ternary_any_1bit any_gate2(
        .a(consensus_neg),
        .b(any1_out),
        .enable(enable),
        .any_out(any2_out)
    );

    wire [1:0] any3_out;
    ternary_any_1bit any_gate3(
        .a(consensus_neg),
        .b(any2_out),
        .enable(enable),
        .any_out(any3_out)
    );

    assign sum = any3_out;

endmodule


module ternary_half_adder_1bit(
    input [1:0] a,
    input [1:0] b,
    input wire enable,
    output [1:0] sum,
    output [1:0] carry_out
);

    ternary_addition_1bit add_gate(
        .a(a),
        .b(b),
        .enable(enable),
        .sum(sum)
    );

    ternary_consensus_1bit consensus_gate(
        .a(a),
        .b(b),
        .enable(enable),
        .consensus_out(carry_out)
    );

endmodule


module ternary_adder_1bit(
    input [1:0] a,
    input [1:0] b,
    input [1:0] carry_in,
    input wire enable,
    output [1:0] sum,
    output [1:0] carry_out
);

    `include "parameters.vh"

    wire [1:0] sum1, carry1, carry2;
    ternary_half_adder_1bit half_adder1(
        .a(b),
        .b(carry_in),
        .enable(enable),
        .sum(sum1),
        .carry_out(carry1)
    );

    ternary_half_adder_1bit half_adder2(
        .a(a),
        .b(sum1),
        .enable(enable),
        .sum(sum),
        .carry_out(carry2)
    );

    // Carry out is the any of the two carry outputs
    ternary_any_1bit any_gate(
        .a(carry1),
        .b(carry2),
        .enable(enable),
        .any_out(carry_out)
    );

endmodule


// module ternary_adder_1bit(
//     input [1:0] a,
//     input [1:0] b,
//     input [1:0] carry_in,
//     output [1:0] sum,
//     output [1:0] carry_out
// );

//       TODO: Create an efficient 1-bit ternary adder implementation here

//     `include "parameters.vh"

//     // Ternary 

//     // Helper function for ternary addition (returns carry and sum)
//     function [3:0] ternary_add_step;
//         input [1:0] trit1, trit2;
//         begin
//             case({trit1, trit2})
//                 {`_1, `_1}: ternary_add_step = {`_1, `_1_};  // -1 + -1 = -2 = carry -1, sum 1
//                 {`_1, `_0}: ternary_add_step = {`_0, `_1};   // -1 + 0 = -1
//                 {`_1, `_1_}: ternary_add_step = {`_0, `_0};  // -1 + 1 = 0
//                 {`_0, `_1}: ternary_add_step = {`_0, `_1};   // 0 + -1 = -1
//                 {`_0, `_0}: ternary_add_step = {`_0, `_0};   // 0 + 0 = 0
//                 {`_0, `_1_}: ternary_add_step = {`_0, `_1_}; // 0 + 1 = 1
//                 {`_1_, `_1}: ternary_add_step = {`_0, `_0};  // 1 + -1 = 0
//                 {`_1_, `_0}: ternary_add_step = {`_0, `_1_}; // 1 + 0 = 1
//                 {`_1_, `_1_}: ternary_add_step = {`_1_, `_1}; // 1 + 1 = 2 = carry 1, sum -1
//                 default: ternary_add_step = {`_0, `_0};
//             endcase
//         end
//     endfunction
    
//     // First add a and b, then add the result to carry_in
//     wire [3:0] step1, step2;
    
//     // First addition: a + b
//     assign step1 = ternary_add_step(a, b);
    
//     // Second addition: (a+b result) + carry_in
//     assign step2 = ternary_add_step(step1[1:0], carry_in);
    
//     // Final sum is the result of the second addition
//     assign sum = step2[1:0];
    
//     // Combine the carries from both addition steps
//     assign carry_out = (step1[3:2] == `_0) ? step2[3:2] :
//                        (step2[3:2] == `_0) ? step1[3:2] :
//                        (step1[3:2] == `_1_ && step2[3:2] == `_1_) ? `_1 :  // 1+1=-1 with carry 1
//                        (step1[3:2] == `_1 && step2[3:2] == `_1) ? `_1_ :   // -1+-1=1 with carry -1
//                        `_0;  // Otherwise carries cancel out
// endmodule


/*
* ALU operations on ternary numbers of WORD_SIZE equals 9 trits (18 bits)
*/

module ternary_not(
    input [17:0] a,
    input wire enable,
    output [17:0] result
);

    // Instantiate 9 NOT gates, one for each trit
    ternary_negation_1bit not0(.a(a[1:0]), .enable(enable), .neg_out(result[1:0]));
    ternary_negation_1bit not1(.a(a[3:2]), .enable(enable), .neg_out(result[3:2]));
    ternary_negation_1bit not2(.a(a[5:4]), .enable(enable), .neg_out(result[5:4]));
    ternary_negation_1bit not3(.a(a[7:6]), .enable(enable), .neg_out(result[7:6]));
    ternary_negation_1bit not4(.a(a[9:8]), .enable(enable), .neg_out(result[9:8]));
    ternary_negation_1bit not5(.a(a[11:10]), .enable(enable), .neg_out(result[11:10]));
    ternary_negation_1bit not6(.a(a[13:12]), .enable(enable), .neg_out(result[13:12]));
    ternary_negation_1bit not7(.a(a[15:14]), .enable(enable), .neg_out(result[15:14]));
    ternary_negation_1bit not8(.a(a[17:16]), .enable(enable), .neg_out(result[17:16]));

endmodule


module ternary_and(
    input [17:0] a,
    input [17:0] b,
    input wire enable, 
    output [17:0] result
);

    // Instantiate 9 AND gates, one for each trit position
    ternary_and_1bit and0(.a(a[1:0]), .b(b[1:0]), .enable(enable), .and_out(result[1:0]));
    ternary_and_1bit and1(.a(a[3:2]), .b(b[3:2]), .enable(enable), .and_out(result[3:2]));
    ternary_and_1bit and2(.a(a[5:4]), .b(b[5:4]), .enable(enable), .and_out(result[5:4]));
    ternary_and_1bit and3(.a(a[7:6]), .b(b[7:6]), .enable(enable), .and_out(result[7:6]));
    ternary_and_1bit and4(.a(a[9:8]), .b(b[9:8]), .enable(enable), .and_out(result[9:8]));
    ternary_and_1bit and5(.a(a[11:10]), .b(b[11:10]), .enable(enable), .and_out(result[11:10]));
    ternary_and_1bit and6(.a(a[13:12]), .b(b[13:12]), .enable(enable), .and_out(result[13:12]));
    ternary_and_1bit and7(.a(a[15:14]), .b(b[15:14]), .enable(enable), .and_out(result[15:14]));
    ternary_and_1bit and8(.a(a[17:16]), .b(b[17:16]), .enable(enable), .and_out(result[17:16]));

endmodule


module ternary_or(
    input [17:0] a, 
    input [17:0] b, 
    input wire enable,
    output [17:0] result
);

    // Instantiate 9 OR gates, one for each trit position
    ternary_or_1bit or0(.a(a[1:0]), .b(b[1:0]), .enable(enable), .or_out(result[1:0]));
    ternary_or_1bit or1(.a(a[3:2]), .b(b[3:2]), .enable(enable), .or_out(result[3:2]));
    ternary_or_1bit or2(.a(a[5:4]), .b(b[5:4]), .enable(enable), .or_out(result[5:4]));
    ternary_or_1bit or3(.a(a[7:6]), .b(b[7:6]), .enable(enable), .or_out(result[7:6]));
    ternary_or_1bit or4(.a(a[9:8]), .b(b[9:8]), .enable(enable), .or_out(result[9:8]));
    ternary_or_1bit or5(.a(a[11:10]), .b(b[11:10]), .enable(enable), .or_out(result[11:10]));
    ternary_or_1bit or6(.a(a[13:12]), .b(b[13:12]), .enable(enable), .or_out(result[13:12]));
    ternary_or_1bit or7(.a(a[15:14]), .b(b[15:14]), .enable(enable), .or_out(result[15:14]));
    ternary_or_1bit or8(.a(a[17:16]), .b(b[17:16]), .enable(enable), .or_out(result[17:16]));

endmodule


module ternary_xor(
    input [17:0] a,
    input [17:0] b,
    input wire enable,
    output [17:0] result
);

    // Instantiate 9 XOR gates, one for each trit position
    ternary_xor_1bit xor0(.a(a[1:0]), .b(b[1:0]), .enable(enable), .xor_out(result[1:0]));
    ternary_xor_1bit xor1(.a(a[3:2]), .b(b[3:2]), .enable(enable), .xor_out(result[3:2]));
    ternary_xor_1bit xor2(.a(a[5:4]), .b(b[5:4]), .enable(enable), .xor_out(result[5:4]));
    ternary_xor_1bit xor3(.a(a[7:6]), .b(b[7:6]), .enable(enable), .xor_out(result[7:6]));
    ternary_xor_1bit xor4(.a(a[9:8]), .b(b[9:8]), .enable(enable), .xor_out(result[9:8]));
    ternary_xor_1bit xor5(.a(a[11:10]), .b(b[11:10]), .enable(enable), .xor_out(result[11:10]));
    ternary_xor_1bit xor6(.a(a[13:12]), .b(b[13:12]), .enable(enable), .xor_out(result[13:12]));
    ternary_xor_1bit xor7(.a(a[15:14]), .b(b[15:14]), .enable(enable), .xor_out(result[15:14]));
    ternary_xor_1bit xor8(.a(a[17:16]), .b(b[17:16]), .enable(enable), .xor_out(result[17:16]));

endmodule


module ternary_less_than_comparator(input1, input2, enable, result);

    `include "parameters.vh"
    
    input [2*WORD_SIZE-1:0] input1, input2;
    input wire enable;
    output result; // 1 if input1 < input2, 0 otherwise
    
    // Wires for stage results - each stage determines if input1 is less than, equal to, or greater than input2 so far
    // lt_signal[i] = 1 if input1 < input2 for trits [i:WORD_SIZE-1]
    // eq_signal[i] = 1 if input1 = input2 for trits [i:WORD_SIZE-1]
    wire lt_signal [0:WORD_SIZE];
    wire eq_signal [0:WORD_SIZE];
    
    // Initialize comparison for MSB position
    // Initially, no "less than" condition has been found
    assign lt_signal[WORD_SIZE] = 1'b0;
    // Initially, inputs are considered equal
    assign eq_signal[WORD_SIZE] = 1'b1;
    
    // Instantiate comparator stages from MSB to LSB
    // Start with MSB (trit 8)
    ternary_comparator_1trit comp8(
        .a(input1[17:16]),
        .b(input2[17:16]),
        .lt_in(lt_signal[WORD_SIZE]),
        .eq_in(eq_signal[WORD_SIZE]),
        .enable(enable),
        .lt_out(lt_signal[8]),
        .eq_out(eq_signal[8])
    );
    
    ternary_comparator_1trit comp7(
        .a(input1[15:14]),
        .b(input2[15:14]),
        .lt_in(lt_signal[8]),
        .eq_in(eq_signal[8]),
        .enable(enable),
        .lt_out(lt_signal[7]),
        .eq_out(eq_signal[7])
    );
    
    ternary_comparator_1trit comp6(
        .a(input1[13:12]),
        .b(input2[13:12]),
        .lt_in(lt_signal[7]),
        .eq_in(eq_signal[7]),
        .enable(enable),
        .lt_out(lt_signal[6]),
        .eq_out(eq_signal[6])
    );
    
    ternary_comparator_1trit comp5(
        .a(input1[11:10]),
        .b(input2[11:10]),
        .lt_in(lt_signal[6]),
        .eq_in(eq_signal[6]),
        .enable(enable),
        .lt_out(lt_signal[5]),
        .eq_out(eq_signal[5])
    );
    
    ternary_comparator_1trit comp4(
        .a(input1[9:8]),
        .b(input2[9:8]),
        .lt_in(lt_signal[5]),
        .eq_in(eq_signal[5]),
        .enable(enable),
        .lt_out(lt_signal[4]),
        .eq_out(eq_signal[4])
    );
    
    ternary_comparator_1trit comp3(
        .a(input1[7:6]),
        .b(input2[7:6]),
        .lt_in(lt_signal[4]),
        .eq_in(eq_signal[4]),
        .enable(enable),
        .lt_out(lt_signal[3]),
        .eq_out(eq_signal[3])
    );
    
    ternary_comparator_1trit comp2(
        .a(input1[5:4]),
        .b(input2[5:4]),
        .lt_in(lt_signal[3]),
        .eq_in(eq_signal[3]),
        .enable(enable),
        .lt_out(lt_signal[2]),
        .eq_out(eq_signal[2])
    );
    
    ternary_comparator_1trit comp1(
        .a(input1[3:2]),
        .b(input2[3:2]),
        .lt_in(lt_signal[2]),
        .eq_in(eq_signal[2]),
        .enable(enable),
        .lt_out(lt_signal[1]),
        .eq_out(eq_signal[1])
    );
    
    ternary_comparator_1trit comp0(
        .a(input1[1:0]),
        .b(input2[1:0]),
        .lt_in(lt_signal[1]),
        .eq_in(eq_signal[1]),
        .enable(enable),
        .lt_out(lt_signal[0]),
        .eq_out(eq_signal[0])
    );
    
    // Final result
    assign result = lt_signal[0];
endmodule

// Ternary ripple carry adder - fixed for 9 trits
module ternary_ripple_carry_adder(input1, input2, enable, result);

    `include "parameters.vh"
    
    input [2*WORD_SIZE-1:0] input1, input2;
    input wire enable;
    output [2*WORD_SIZE-1:0] result;
    
    // Wire to propagate carry
    wire [1:0] carry [0:WORD_SIZE];
    
    assign carry[0] = `_0; // Initial carry is 0
    
    // Explicitly instantiate all 9 adder stages
    ternary_adder_1bit adder0(
        .a(input1[1:0]),
        .b(input2[1:0]),
        .carry_in(carry[0]),
        .enable(enable),
        .sum(result[1:0]),
        .carry_out(carry[1])
    );
    
    ternary_adder_1bit adder1(
        .a(input1[3:2]),
        .b(input2[3:2]),
        .carry_in(carry[1]),
        .enable(enable),
        .sum(result[3:2]),
        .carry_out(carry[2])
    );
    
    ternary_adder_1bit adder2(
        .a(input1[5:4]),
        .b(input2[5:4]),
        .carry_in(carry[2]),
        .enable(enable),
        .sum(result[5:4]),
        .carry_out(carry[3])
    );
    
    ternary_adder_1bit adder3(
        .a(input1[7:6]),
        .b(input2[7:6]),
        .carry_in(carry[3]),
        .enable(enable),
        .sum(result[7:6]),
        .carry_out(carry[4])
    );
    
    ternary_adder_1bit adder4(
        .a(input1[9:8]),
        .b(input2[9:8]),
        .carry_in(carry[4]),
        .enable(enable),
        .sum(result[9:8]),
        .carry_out(carry[5])
    );
    
    ternary_adder_1bit adder5(
        .a(input1[11:10]),
        .b(input2[11:10]),
        .carry_in(carry[5]),
        .enable(enable),
        .sum(result[11:10]),
        .carry_out(carry[6])
    );
    
    ternary_adder_1bit adder6(
        .a(input1[13:12]),
        .b(input2[13:12]),
        .carry_in(carry[6]),
        .enable(enable),
        .sum(result[13:12]),
        .carry_out(carry[7])
    );
    
    ternary_adder_1bit adder7(
        .a(input1[15:14]),
        .b(input2[15:14]),
        .carry_in(carry[7]),
        .enable(enable),
        .sum(result[15:14]),
        .carry_out(carry[8])
    );
    
    ternary_adder_1bit adder8(
        .a(input1[17:16]),
        .b(input2[17:16]),
        .carry_in(carry[8]),
        .enable(enable),
        .sum(result[17:16]),
        .carry_out(carry[9])
    );
endmodule


/*
*Main ALU module that instantiates all of the above components to perform the ALU operations
*/

module ternary_alu(clock, opcode, input1, input2, alu_enable, alu_out);

    `include "parameters.vh"
    
    input wire clock, alu_enable;
    input wire [2*OPCODE_SIZE-1:0] opcode;  // 3 trits = 6 bits
    input wire [2*WORD_SIZE-1:0] input1, input2;  // Each trit requires 2 bits (18 bits total)
    output reg [2*WORD_SIZE-1:0] alu_out;

    // Generate operation specific enable signals
    wire not_enable = alu_enable && (opcode == `NOT);
    wire and_enable = alu_enable && (opcode == `AND || opcode == `ANDI);
    wire or_enable = alu_enable && (opcode == `OR);
    wire xor_enable = alu_enable && (opcode == `XOR);
    wire add_enable = alu_enable && (opcode == `ADD || opcode == `ADDI);
    wire sub_enable = alu_enable && (opcode == `SUB);
    wire comp_enable = alu_enable && (opcode == `COMP);
    wire lt_enable = alu_enable && (opcode == `LT);
    wire eq_enable = alu_enable && (opcode == `EQ);
    
    // Wire declarations for intermediate results
    wire [2*WORD_SIZE-1:0] not_result;
    wire [2*WORD_SIZE-1:0] and_result;
    wire [2*WORD_SIZE-1:0] or_result;
    wire [2*WORD_SIZE-1:0] xor_result;
    wire [2*WORD_SIZE-1:0] less_than_result;
    wire [2*WORD_SIZE-1:0] equal_result;
    wire [2*WORD_SIZE-1:0] adder_out;
    wire [2*WORD_SIZE-1:0] sub_result;

    // NOT operation
    ternary_not not_gate(
        .a(input1),
        .enable(not_enable),
        .result(not_result)
    );

    // AND operation
    ternary_and and_gate(
        .a(input1),
        .b(input2),
        .enable(and_enable),
        .result(and_result)
    );

    // OR operation
    ternary_or or_gate(
        .a(input1),
        .b(input2),
        .enable(or_enable),
        .result(or_result)
    );

    // XOR operation
    ternary_xor xor_gate(
        .a(input1),
        .b(input2),
        .enable(xor_enable),
        .result(xor_result)
    );
    
    // Comparison implementation
    wire ltc_output;
    ternary_less_than_comparator comparator(
        .input1(input1),
        .input2(input2),
        .enable(lt_enable),
        .result(ltc_output)
    );
    assign less_than_result = ltc_output ? `_1 : `_0; // Less than check

    // Equality check
    assign equal_result = (input1 == input2) ? `_1_ : `_0; // Equality check

    // Instantiate the ternary ripple carry adder
    ternary_ripple_carry_adder adder(
        .input1(input1),
        .input2(input2),
        .enable(add_enable),
        .result(adder_out)
    );
    
    // Subtraction
    wire [2*WORD_SIZE-1:0] neg_input2;
    ternary_not neg_gate(
        .a(input2),
        .enable(sub_enable),
        .result(neg_input2)
    );
    ternary_ripple_carry_adder subtractor(
        .input1(input1),
        .input2(neg_input2),
        .enable(sub_enable),
        .result(sub_result)
    );


    // Main logic
    always @(posedge clock) begin
        if (alu_enable) begin
            case (opcode)
                `NOT: begin
                    alu_out <= not_result;
                end
                `AND, `ANDI: begin
                    alu_out <= and_result;
                end
                `OR: begin
                    alu_out <= or_result;
                end
                `XOR: begin
                    alu_out <= xor_result;
                end
                `ADD, `ADDI: begin
                    alu_out <= adder_out;
                end
                `SUB: begin
                    alu_out <= sub_result;
                end
                `COMP: begin
                    $display("Currently not implemented");
                    alu_out <= input1;
                end
                `LT: begin
                    alu_out <= less_than_result;
                end
                `EQ: begin
                    alu_out <= equal_result;
                end
                default: begin
                    $display("Unknown opcode %h", opcode);
                    alu_out <= input1; // Default to passing through input1
                end
            endcase
        end
    end

endmodule