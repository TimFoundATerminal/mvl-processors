module program_loader (
    clock, reset, start_load,
    load_complete,
    mem_addr, mem_write_data,
    mem_write
);

    `include "parameters.vh"

    input wire clock, reset, start_load;
    output reg load_complete;
    output reg [2*MEM_ADDR_SIZE-1:0] mem_addr;
    output reg [2*WORD_SIZE-1:0] mem_write_data;
    output reg mem_write;

    // Program loading states
    reg [2:0] state;
    integer file_handle;
    reg [2*WORD_SIZE-1:0] instruction;
    integer scan_file;
    integer file_complete;
    integer i;
    reg [7:0] hex_value; // For reading hex value from file
    
    // Pad the memory address with 0s to make it 2*WORD_SIZE bits wide
    wire [2*WORD_SIZE-1:0] mem_addr_input = {{(WORD_SIZE - MEM_ADDR_SIZE){`_0}}, mem_addr};

    // Instantiate a ternary adder to increment the address number by 1 each cycle
    wire [2*WORD_SIZE-1:0] increment_val = {{(WORD_SIZE-1){`_0}}, `_1_}; // padding with 0s
    wire [2*WORD_SIZE-1:0] next_mem_addr;
    ternary_ripple_carry_adder pl_adder(
        .input1(mem_addr_input),
        .input2(increment_val),
        .enable(1'b0),
        .result(next_mem_addr)
    );

    wire mem_addr_compare;
    ternary_less_than pl_compare(
        .input1(mem_addr_input),
        .input2({{(WORD_SIZE - MEM_ADDR_SIZE){`_0}}, {(MEM_ADDR_SIZE){`_1_}}}), // Largest address value
        .enable(1'b0),
        .result(mem_addr_compare)
    );

    // Set default memory address
    wire [2*MEM_ADDR_SIZE-1:0] default_mem_addr = {MEM_ADDR_SIZE{`_1}};
    
    // Program loading FSM
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= 0;
            mem_addr <= default_mem_addr;
            mem_write <= 0;
            load_complete <= 0;
        end else begin
            case (state)
                0: begin // Wait for start signal
                    if (start_load) begin
                        file_handle = $fopen("programs/bin/program.hex", "r");
                        if (file_handle == 0) begin
                            $display("Error: Could not open program.hex");
                            state <= 4; // Go to error state
                        end else begin
                            state <= 1;
                            mem_addr <= default_mem_addr; // Set default memory address
                        end
                    end
                end
                
                1: begin // Read instruction from file
                    scan_file = $fscanf(file_handle, "%h\n", instruction);
                    if (scan_file == 1) begin
                        mem_write_data <= instruction;
                        mem_write <= 1;
                        state <= 2;
                    end else begin
                        $fclose(file_handle);
                        state <= 3;
                    end
                end
                
                2: begin // Write instruction to memory
                    mem_write <= 0;
                    if (mem_addr_compare) begin
                        // $display("Next address: %b", next_mem_addr[2*MEM_ADDR_SIZE-1:0]);
                        mem_addr <= next_mem_addr[2*MEM_ADDR_SIZE-1:0]; // Truncate to MEM_ADDR_SIZE number of trits
                        state <= 1;
                    end else begin
                        $fclose(file_handle);
                        state <= 3;
                    end
                end
                
                3: begin // Loading complete
                    load_complete <= 1;
                    state <= 4;
                end
                
                4: begin // Final state
                    mem_write <= 0;
                    // Stay in this state until reset
                end
            endcase
        end
    end
endmodule