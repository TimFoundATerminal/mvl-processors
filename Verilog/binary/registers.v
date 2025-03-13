module registers(clock, num1, num2, set_val, get_enable, set_enable, reset_enable, out1, out2);

    /* Registers

    This module contains all of the registers used in the CPU core. As detailed in experimental design,
    8 [2:0] general purpose registers are used to cater to the binary and ternary range.

    The registers are each of size WORD_SIZE, which is defined in parameters.vh. */

    `include "parameters.vh"

    input wire clock;
    input wire get_enable, set_enable, reset_enable;
    input wire [REG_ADDR_SIZE-1:0] num1, num2;
    input wire [WORD_SIZE-1:0] set_val;
    output reg [WORD_SIZE-1:0] out1, out2;

    reg [WORD_SIZE-1:0] regs [0:REG_NUM-1];

    integer i;
    always @(posedge clock) begin
        // $display("Get Enable: %d, Set Enable: %d", get_enable, set_enable);
        if (reset_enable) begin
            for (i = 0; i < REG_NUM; i = i + 1) begin
                regs[i] <= 0;
            end
        end
        if (set_enable) begin
            // $display("Setting register %d to %d", num1, set_val);
            regs[num1] <= set_val;
        end
        if (get_enable) begin
            // $display("Getting register %d: %d", num1, regs[num1]);
            out1 <= regs[num1];
            out2 <= regs[num2];
        end
    end

endmodule