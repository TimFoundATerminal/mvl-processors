module memory(clock, reset, read_enable, write_enable, address, data_in, data_out);

    /* Memory Module
    * This module contains the memory array, which is used to store data and instructions for the CPU core.
    */

    `include "parameters.vh"

    input wire clock;
    input wire reset;
    input wire write_enable;
    input wire read_enable;
    input wire [2*MEM_ADDR_SIZE-1:0] address;     // 3 trits
    input wire [2*WORD_SIZE-1:0] data_in;         // 9 trit data input
    output reg [2*WORD_SIZE-1:0] data_out;         // 9 trit data output

    // Memory array
    reg [2*WORD_SIZE-1:0] memory [0:2*MEM_SIZE-1];
    integer i;

    // Reset and write operations
    always @(posedge clock) begin
        if (reset) begin
            // Clear all memory locations on reset
            for (i = 0; i < 2*MEM_SIZE; i = i + 1) begin
                memory[i] <= 18'b0;
            end
            data_out <= 18'b0;
            // load_initiated <= 0;
        
        end else begin
            if (write_enable) begin
                memory[address] <= data_in;
            end
            if (read_enable) begin
                data_out <= memory[address];
            end
            // data_out remains the same if no read operation is initiated
        end
    end


endmodule