module memory(clock, reset, write_enable, address, data_in, data_out);

    /* Memory Module

    This module contains the memory array, which is used to store data and instructions for the CPU core. */

    `include "parameters.vh"
    
    input wire clock;
    input wire reset;
    input wire write_enable;
    // input wire load_program;                    // Signal to trigger program loading
    input wire [MEM_ADDR_SIZE-1:0] address;     // 5 bits for 32 locations
    input wire [WORD_SIZE-1:0] data_in;         // 16-bit data input
    output reg [WORD_SIZE-1:0] data_out;         // 16-bit data output

    // Memory array: 32 locations of 16 bits each
    reg [WORD_SIZE-1:0] memory [0:MEM_SIZE-1];
    integer i;

    // Load the program from a file into memory outside of the CPU cycle

    // Program loading signals
    // wire loader_write_enable;
    // wire [MEM_ADDR_SIZE-1:0] loader_address;
    // wire [WORD_SIZE-1:0] loader_data_in;
    // wire load_complete;
    // reg load_initiated = 0;

    // // Instantiate the program loader
    // program_loader loader (
    //     .clock(clock),
    //     .reset(reset),
    //     .start_load(load_initiated),
    //     .load_complete(load_complete),
    //     .mem_addr(loader_address),
    //     .mem_write_data(loader_data),
    //     .mem_write(loader_write_enable)
    // );

    // // Load the program into memory outside of the CPU cycle
    // always @(posedge load_program or posedge reset) begin
    //     if (reset) begin
    //         load_initiated <= 0;
    //     end else if (load_program && !load_initiated && !load_complete) begin
    //         load_initiated <= 1;
    //         $display("Program loading initiated");
    //     end
    // end


    // Reset and write operations
    always @(posedge clock) begin
        if (reset) begin
            // Clear all memory locations on reset
            for (i = 0; i < MEM_SIZE; i = i + 1) begin
                memory[i] <= 16'b0;
            end
            data_out <= 16'b0;
            // load_initiated <= 0;
        
        end else begin
            // // Priority given to program loading
            // if (loader_write_enable) begin
            //     memory[loader_address] <= loader_data;
            // end
            // Normal CPU operations
            if (write_enable) begin
                memory[address] <= data_in;
            end
            // Always read the current address (read-during-write returns new data)
            data_out <= memory[address];
        end
    end

    // // Detect when the program loader has completed
    // always @(posedge load_complete) begin
    //     if (load_complete) begin
    //         $display("Program loading complete");
    //         load_initiated <= 0;
    //     end
    // end

endmodule