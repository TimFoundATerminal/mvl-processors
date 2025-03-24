module program_counter(clock, reset_enable, update_enable, value, out);

    /* Program Counter

    This module contains the program counter, which is used to keep track of the current instruction
    which can then be modified and updated by the CPU core. */
    
    `include "parameters.vh"
    
    input wire clock, reset_enable, update_enable;
    input wire [WORD_SIZE-1:0] value;
    output reg [MEM_ADDR_SIZE-1:0] out = 0;
    
    always @(posedge clock) begin
        if (reset_enable) begin
            $display("Resetting program counter");
            out <= 0;
        end
        else if (update_enable) begin
            $display("Updating program counter by %0d", $signed(value));
            out <= out + value;
        end
        else begin
            out <= out;
        end
    end
endmodule