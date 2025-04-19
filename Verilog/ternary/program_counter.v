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
        .enable(1'b0),             // Don't want to count this within the cycle
        .result(adder_result)
    );
    
    always @(posedge clock) begin
        if (reset_enable) begin
            $display("Resetting program counter");
            out <= _zero;
        end
        else if (update_enable) begin

            out <= adder_result[2*MEM_ADDR_SIZE-1:0]; // Truncate to MEM_ADDR_SIZE number of trits
        end
        else begin
            out <= out;
        end
    end
endmodule