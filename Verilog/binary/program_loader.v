module program_loader (
    clock, reset, start_load,
    load_complete,
    mem_addr, mem_write_data,
    mem_write
);

    `include "parameters.vh"

    input wire clock, reset, start_load;
    output reg load_complete;
    output reg [MEM_ADDR_SIZE-1:0] mem_addr;
    output reg [WORD_SIZE-1:0] mem_write_data;
    output reg mem_write;

    // Program loading states
    reg [2:0] state;
    integer file_handle;
    reg [WORD_SIZE-1:0] instruction;
    integer scan_file;
    integer file_complete;
    
    // Program loading FSM
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= 0;
            mem_addr <= 0;
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
                            mem_addr <= 0;
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
                    if (mem_addr < 31) begin
                        mem_addr <= mem_addr + 1;
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