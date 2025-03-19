// `include "ternary_defs.v"

module balanced_ternary_buffer(
    input wire [1:0] in,     // We still need 2 bits to encode 3 states
    output reg [1:0] out
);
    // Encoding:
    // 10 = Negative (-1)
    // 00 = Zero (0)
    // 01 = Positive (+1)
    // 11 = Invalid (should not occur)
    
    always @(*) begin
        case (in)
            2'b10: out = 2'b10;  // Negative
            2'b00: out = 2'b00;  // Zero
            2'b01: out = 2'b01;  // Positive
            default: out = 2'b00; // Invalid input defaults to zero
        endcase
    end
endmodule

module ternary_full_adder(
    input wire [1:0] a,
    input wire [1:0] b,
    input wire [1:0] cin,    // Carry input
    output reg [1:0] sum,
    output reg [1:0] cout    // Carry output
);
    reg [1:0] partial_sum;
    reg [1:0] partial_carry;
    reg [1:0] final_carry;

    always @(*) begin
        // First add a + b
        case ({a, b})
            // Same sign additions
            {2'b01, 2'b01}: begin      // +1 + +1
                partial_sum = 2'b00;    // 0
                partial_carry = 2'b01;  // +1
            end
            {2'b10, 2'b10}: begin      // -1 + -1
                partial_sum = 2'b00;    // 0
                partial_carry = 2'b10;  // -1
            end
            
            // Opposite sign additions
            {2'b01, 2'b10}, 
            {2'b10, 2'b01}: begin      // +1 + -1 or -1 + +1
                partial_sum = 2'b00;    // 0
                partial_carry = 2'b00;  // 0
            end
            
            // Adding zero
            {2'b00, 2'b00}: begin      // 0 + 0
                partial_sum = 2'b00;
                partial_carry = 2'b00;
            end
            {2'b01, 2'b00},
            {2'b00, 2'b01}: begin      // +1 + 0 or 0 + +1
                partial_sum = 2'b01;
                partial_carry = 2'b00;
            end
            {2'b10, 2'b00},
            {2'b00, 2'b10}: begin      // -1 + 0 or 0 + -1
                partial_sum = 2'b10;
                partial_carry = 2'b00;
            end
            
            default: begin             // Invalid inputs
                partial_sum = 2'b00;
                partial_carry = 2'b00;
            end
        endcase

        // Then add partial_sum + cin
        case ({partial_sum, cin})
            // Same sign additions
            {2'b01, 2'b01}: begin      // +1 + +1
                sum = 2'b00;           // 0
                final_carry = 2'b01;   // +1
            end
            {2'b10, 2'b10}: begin      // -1 + -1
                sum = 2'b00;           // 0
                final_carry = 2'b10;   // -1
            end
            
            // Opposite sign additions
            {2'b01, 2'b10}, 
            {2'b10, 2'b01}: begin      // +1 + -1 or -1 + +1
                sum = 2'b00;           // 0
                final_carry = 2'b00;   // 0
            end
            
            // Adding zero
            {2'b00, 2'b00}: begin      // 0 + 0
                sum = 2'b00;
                final_carry = 2'b00;
            end
            {2'b01, 2'b00},
            {2'b00, 2'b01}: begin      // +1 + 0 or 0 + +1
                sum = 2'b01;
                final_carry = 2'b00;
            end
            {2'b10, 2'b00},
            {2'b00, 2'b10}: begin      // -1 + 0 or 0 + -1
                sum = 2'b10;
                final_carry = 2'b00;
            end
            
            default: begin             // Invalid inputs
                sum = 2'b00;
                final_carry = 2'b00;
            end
        endcase

        // Combine carries
        case ({partial_carry, final_carry})
            // Same sign carries
            {2'b01, 2'b01}: cout = 2'b01;  // +1 + +1 = +1 (overflow)
            {2'b10, 2'b10}: cout = 2'b10;  // -1 + -1 = -1 (underflow)
            
            // Opposite sign carries
            {2'b01, 2'b10},
            {2'b10, 2'b01}: cout = 2'b00;  // +1 + -1 = 0
            
            // Single carry
            {2'b01, 2'b00},
            {2'b00, 2'b01}: cout = 2'b01;  // +1
            {2'b10, 2'b00},
            {2'b00, 2'b10}: cout = 2'b10;  // -1
            
            // No carry
            {2'b00, 2'b00}: cout = 2'b00;  // 0
            
            default: cout = 2'b00;          // Invalid inputs
        endcase
    end
endmodule

module ternary_min(
    input wire [1:0] a,
    input wire [1:0] b,
    output reg [1:0] out
);
    always @(*) begin
        case ({a, b})
            // False and anything = False
            {2'b10, 2'b10}: out = 2'b10;
            {2'b10, 2'b00}: out = 2'b10;
            {2'b10, 2'b01}: out = 2'b10;
            {2'b00, 2'b10}: out = 2'b10;
            {2'b01, 2'b10}: out = 2'b10;
            
            // 0 and non-negative = 0
            {2'b00, 2'b00}: out = 2'b00;
            {2'b00, 2'b01}: out = 2'b00;
            {2'b01, 2'b00}: out = 2'b00;
            
            // +1 and +1 = +1
            {2'b01, 2'b01}: out = 2'b01;
            
            default: out = 2'b00;
        endcase
    end
endmodule

module top_level(
    input wire [1:0] input_a,
    input wire [1:0] input_b,
    output wire [1:0] min_result,
    output wire [1:0] sum_result,
    output wire [1:0] carry_out
);
    // Instantiate ternary MIN
    ternary_min min_inst(
        .a(input_a),
        .b(input_b),
        .out(min_result)
    );
    
    // Instantiate ternary full adder
    ternary_full_adder adder_inst(
        .a(input_a),
        .b(input_b),
        .cin(2'b00),  // Zero carry in
        .sum(sum_result),
        .cout(carry_out)
    );
endmodule