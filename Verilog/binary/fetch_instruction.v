module fetch_instruction(clock,
    instruction_memory, fetch_enable,
    instruction
    );

    `include "parameters.vh"

    input wire clock;
    
    input wire [WORD_SIZE-1:0] instruction_memory;
    input wire fetch_enable;
    output wire [WORD_SIZE-1:0] instruction; // Register to store the instruction
    // output wire ins_read_enable;
    
    // input wire [INS_ADDR_SIZE-1:0] pointer;
    // output wire [INS_ADDR_SIZE-1:0] ins_pointer;

    // assign ins_pointer = pointer;
    assign ins_read_enable = fetch_enable;
    assign instruction = instruction_memory;
    
    // always @(posedge clock) begin
    //     if (fetch_enable) begin
    //         instruction <= instruction_memory;  // Store the instruction to remain stable
    //         $display("instr = %h", instruction_memory);
    //     end
    // end
endmodule