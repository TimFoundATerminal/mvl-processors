// cpu_core.v
module cpu_core (
    input wire clock,
    input wire reset,
    input wire start_execution,
    input wire [7:0] mem_read_data,
    output reg [4:0] mem_addr,
    output reg [7:0] mem_write_data,
    output reg mem_write,
    output reg [7:0] alu_out
);

    // Registers
    reg [7:0] register_file [0:3];
    reg [2:0] state;
    reg [4:0] program_counter;
    
    // Instruction decode
    wire [7:0] instruction = mem_read_data;
    wire [2:0] opcode = instruction[7:5];
    wire [1:0] reg_dest = instruction[4:3];
    wire [1:0] reg_src = instruction[2:1];
    wire [4:0] mem_offset = {2'b00, instruction[2:0]};
    
    always @(posedge clock or posedge reset) begin 
        if (reset) begin
            program_counter <= 0;
            register_file[0] <= 0;
            register_file[1] <= 0;
            register_file[2] <= 0;
            register_file[3] <= 0;
            alu_out <= 0;
            state <= 0;
            mem_write <= 0;
            mem_addr <= 0;
        end else if (start_execution) begin
            case (state)
                0: begin // Fetch
                    mem_addr <= program_counter;
                    mem_write <= 0;
                    state <= 1;
                end
                
                1: begin // Decode and Execute
                    case (opcode)
                        3'b000: alu_out <= register_file[reg_dest] - register_file[reg_src]; // MOVE
                        3'b001: alu_out <= ~register_file[reg_src];                          // NOT (Requires 3 in ternary logic)
                        3'b010: alu_out <= register_file[reg_dest] & register_file[reg_src]; // AND
                        3'b011: alu_out <= register_file[reg_dest] | register_file[reg_src]; // OR
                        3'b100: alu_out <= register_file[reg_dest] ^ register_file[reg_src]; // XOR
                        // other instructions...
                        3'b110: begin // LOAD
                            mem_addr <= register_file[reg_src][4:0];
                            state <= 4; // Extra state for memory read
                        end
                        3'b111: begin // STORE
                            mem_addr <= register_file[reg_src][4:0];
                            mem_write_data <= register_file[reg_dest]; 
                            mem_write <= 1;
                        end
                    endcase
                    if (opcode != 3'b110) state <= 2;
                end
                
                2: begin // Write Back
                    if (opcode <= 3'b100) begin
                        register_file[reg_dest] <= alu_out;
                    end
                    mem_write <= 0;
                    state <= 3;
                end
                
                3: begin // Next Instruction
                    program_counter <= program_counter + 1;
                    state <= 0;
                end
                
                4: begin // Memory Read Complete
                    register_file[reg_dest] <= mem_read_data;
                    state <= 3;
                end
            endcase
        end
    end
endmodule