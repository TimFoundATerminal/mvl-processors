module fetch_instruction(clock,
    instruction_memory, fetch_enable,
    instruction
    );

    /*
    * Fetches the instruction from memory

    Currently, this is simply a passthrough from memory to the instruction register.
    */

    `include "parameters.vh"

    input wire clock;
    
    input wire [2*WORD_SIZE-1:0] instruction_memory;
    input wire fetch_enable;
    output wire [2*WORD_SIZE-1:0] instruction; // Register to store the instruction

    // assign ins_pointer = pointer;
    assign ins_read_enable = fetch_enable;
    assign instruction = instruction_memory;
    
endmodule