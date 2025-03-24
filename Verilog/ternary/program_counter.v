module program_counter(clock, reset_enable, update_enable, value, out);

    /* Program Counter

    This module contains the program counter, which is used to keep track of the current instruction
    which can then be modified and updated by the CPU core. */
    
    `include "parameters.vh"

    localparam [2*WORD_SIZE-1:0] _zero = {WORD_SIZE{`_1}};
    
    input wire clock, reset_enable, update_enable;
    input wire [2*WORD_SIZE-1:0] value;
    output reg [2*MEM_ADDR_SIZE-1:0] out = _zero;

    // adder_result will have size 2*WORD_SIZE but will need to be truncated to 2*MEM_ADDR_SIZE
    wire [2*WORD_SIZE-1:0] adder_input1 = {{(WORD_SIZE - MEM_ADDR_SIZE){`_0}}, out};
    wire [2*WORD_SIZE-1:0] adder_result;

    // Unable to use behavioural logic to update the program counter so will need to instantiate a ternary adder
    ternary_ripple_carry_adder pc_adder(
        .input1(adder_input1),
        .input2(value),
        .result(adder_result)
    );
    
    always @(posedge clock) begin
        if (reset_enable) begin
            $display("Resetting program counter");
            out <= _zero;
        end
        else if (update_enable) begin
            // // Convert ternary value to decimal for display purposes
            // integer dec_value = 0;
            // integer i;
            // reg [1:0] trit;
            
            // // Calculate decimal value of the ternary input
            // for (i = 0; i < WORD_SIZE; i = i + 1) begin
            //     case (i)
            //         0: trit = value[1:0];
            //         1: trit = value[3:2];
            //         2: trit = value[5:4];
            //         3: trit = value[7:6];
            //         4: trit = value[9:8];
            //         5: trit = value[11:10];
            //         6: trit = value[13:12];
            //         7: trit = value[15:14];
            //         8: trit = value[17:16];
            //         default: trit = 2'b00;
            //     endcase
                
            //     case (trit)
            //         `_1: dec_value = dec_value - (3**i);    // -1 × 3^i
            //         `_1_: dec_value = dec_value + (3**i);   // 1 × 3^i
            //         default: dec_value = dec_value;         // 0 × 3^i
            //     endcase
            // end
            
            // $display("Updating program counter by %0d", dec_value);

            out <= adder_result[2*MEM_ADDR_SIZE-1:0]; // Truncate to MEM_ADDR_SIZE number of trits
        end
        else begin
            out <= out;
        end
    end
endmodule