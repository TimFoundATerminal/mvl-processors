module fetch_instruction(clock,
    instruction_address, instruction_memory, fetch_enable,
    instruction
    );

    `include "parameters.vh"

    input wire clock;
    
    input wire [WORD_SIZE-1:0] instruction_memory;
    input wire [MEM_ADDR_SIZE-1:0] instruction_address; // Address the instruction is fetched from
    input wire fetch_enable;
    // output reg [WORD_SIZE-1:0] instruction;
    output wire [WORD_SIZE-1:0] instruction;

    // reg [WORD_SIZE-1:0] instruction_latch; // Latch to hold the fetched instruction

    // always @(posedge clock) begin
    //     if (fetch_enable) begin
    //         instruction_latch <= instruction_memory; // Fetch the instruction from memory
    //         instruction <= instruction_memory;
    //         $display("Fetched instruction: %b", instruction_memory); // Display the fetched instruction
    //     end
    //     else begin
    //         instruction <= instruction_latch; // Maintain the current instruction if not fetching
    //         $display("Current instruction: %b", instruction_latch); // Display the current instruction
    //     end
    // end

    assign instruction = instruction_memory; 

    always @(posedge clock) begin
        if (fetch_enable) begin
            $display("Fetched instruction: %b at address: %d", instruction_memory, instruction_address); // Display the fetched instruction
        end
    end
    
endmodule