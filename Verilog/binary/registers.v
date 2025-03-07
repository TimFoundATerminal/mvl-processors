module registers(clock, num1, num2, set_num, set_val, get_enable, set_enable, reset_enable, out1, out2)

    /* Registers

    This module contains all of the registers used in the CPU core. As detailed in experimental design,
    8 [2:0] general purpose registers are used to cater to the binary and ternary range.

    The registers are each of size WORD_SIZE, which is defined in parameters.vh. */

    `include "parameters.vh"

    localparam NUM_REGS = 8;
    localparam REG_BITS = 3;

    input wire clock;
    input wire get_enable, set_enable, reset_enable;
    input wire [REG_BITS-1:0] num1, num2;
    input wire [WORD_SIZE-1:0] set_val;
    output wire [WORD_SIZE-1:0] out1, out2;

    reg [WORD_SIZE-1:0] regs [0:NUM_REGS-1];

    always @(posedge clock) begin
        if (reset_enable) begin
            for (int i = 0; i < NUM_REGS; i = i + 1) begin
                regs[i] <= 0;
            end
        end
        if (set_enable) begin
            regs[set_num] <= set_val;
        end
        if (get_enable) begin
            out1 <= regs[num1];
            out2 <= regs[num2];
        end
    end

endmodule