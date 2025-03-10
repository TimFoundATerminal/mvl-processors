module cpu_core (
    input wire clock,
    input wire reset,
    input wire start_execution,
    input wire [15:0] mem_read_data,
    output reg [4:0] mem_addr,
    output reg [15:0] mem_write_data,
    output reg mem_write,
    output reg [15:0] alu_out,
    output reg halted // Contains a halted flag
);

    `include "parameters.vh"

    // Registers
    reg [15:0] register_file [0:7];
    reg [2:0] state;
    reg [15:0] program_counter;
    
    // Instruction decode
    wire [15:0] instruction = mem_read_data;
    wire [4:0] opcode = instruction[15:11];
    wire [1:0] reg_dest = instruction[10:8];
    wire [1:0] reg_src = instruction[7:5];
    wire [7:0] immediate = instruction[7:0];
    wire [3:0] shift = instruction[4:1];

    // Instruction decoding registers
    reg [15:0] current_instruction;
    reg [4:0] current_opcode;
    reg [2:0] current_reg_dest;
    reg [2:0] current_reg_src;
    reg [7:0] current_immediate;
    reg signed [6:0] signed_immediate;
    reg [3:0] current_shift;

    // States
    localparam FETCH = 3'd0;
    localparam DECODE = 3'd1;
    localparam EXECUTE = 3'd2;
    localparam WRITE_BACK = 3'd3;
    localparam NEXT_INSTRUCTION = 3'd4;
    localparam MEMORY_READ = 3'd5;
    
    // Temporary variables
    integer i;
    
    always @(posedge clock or posedge reset) begin 
        if (reset) begin
            program_counter <= 0;
            // loop through all registers and set them to 0
            for (i = 0; i < 8; i = i + 1) begin
                register_file[i] <= 16'b0;
            end
            alu_out <= 0;
            state <= FETCH;
            mem_write <= 0;
            mem_addr <= 0;
            halted <= 0;
        end else if (start_execution && !halted) begin
            // Display current state and opcode
            $display("State: %d, Opcode: %d", state, current_opcode);
            case (state)
                FETCH: begin // State 0: Fetch
                    mem_addr <= program_counter;
                    mem_write <= 0;
                    state <= DECODE;
                end

                DECODE: begin // State 1: Decode instruction
                    // Save instruction components for execution stage
                    current_instruction <= mem_read_data;
                    current_opcode <= opcode;
                    current_reg_dest <= reg_dest;
                    current_reg_src <= reg_src;
                    current_immediate <= immediate;
                    current_shift <= shift;
                    // Display the decoded instruction broken down into its components
                    $display("Current Opcode: %d, %d", current_opcode, opcode);
                    $display("Current Reg Dest: %d", current_reg_dest);
                    $display("Current Reg Src: %d", current_reg_src);
                    $display("Current Big Immediate: %d", current_immediate);
                    $display("Current Small Immediate: %d", current_shift);
                    state <= EXECUTE;
                end
                
                EXECUTE: begin // State 1: Decode and Execute
                    case (opcode)
                        `HALT: begin
                            halted <= 1;  // Set halted flag
                            state <= state;  // Stay in current state
                        end
                        `MV: begin
                            register_file[current_reg_dest] <= register_file[current_reg_src];
                            state <= NEXT_INSTRUCTION;
                        end
                        `NOT: begin
                            alu_out <= ~register_file[current_reg_src];
                            state <= WRITE_BACK;
                        end
                        `AND: begin
                            alu_out <= register_file[current_reg_dest] & register_file[current_reg_src];
                            state <= WRITE_BACK;
                        end
                        `OR: begin
                            alu_out <= register_file[current_reg_dest] | register_file[current_reg_src];
                            state <= WRITE_BACK;
                        end
                        `XOR: begin
                            alu_out <= register_file[current_reg_dest] ^ register_file[current_reg_src];
                            state <= WRITE_BACK;
                        end
                        `ADD: begin
                            alu_out <= register_file[current_reg_dest] + register_file[current_reg_src];
                            state <= WRITE_BACK;
                        end
                        `SUB: begin
                            alu_out <= register_file[current_reg_dest] - register_file[current_reg_src];
                            state <= WRITE_BACK;
                        end
                        `COMP: begin
                            alu_out <= (register_file[current_reg_dest] == register_file[current_reg_src]);
                            state <= WRITE_BACK;
                        end
                        `ANDI: begin
                            register_file[current_reg_dest] <= register_file[current_reg_dest] & current_immediate;
                            state <= NEXT_INSTRUCTION;
                        end
                        `ADDI: begin
                            register_file[current_reg_dest] <= register_file[current_reg_dest] + current_immediate;
                            state <= NEXT_INSTRUCTION;
                        end
                        `SRI: begin
                            register_file[current_reg_dest] <= register_file[current_reg_dest] >> current_shift;
                            state <= NEXT_INSTRUCTION;
                        end
                        `SLI: begin
                            register_file[current_reg_dest] <= register_file[current_reg_dest] << current_shift;
                            state <= NEXT_INSTRUCTION;
                        end
                        `LUI: begin
                            $display("Loading upper immediate %d into register %d", current_immediate, current_reg_dest);
                            register_file[current_reg_dest] <= {current_immediate, 8'b0};
                            state <= NEXT_INSTRUCTION;
                        end
                        `LI: begin
                            $display("Loading lower immediate %d into register %d", current_immediate, current_reg_dest);
                            register_file[current_reg_dest] <= {register_file[current_reg_dest][15:8], current_immediate};
                            state <= NEXT_INSTRUCTION;
                        end
                        `BEQ: begin
                            // Check if branch condition is met
                            if (register_file[current_reg_dest][0] == 1'b1) begin
                                // Convert 7 bit immediate using 2's complement
                                signed_immediate = $signed(current_immediate[6:0]);
                                program_counter = program_counter - signed_immediate;
                                $display("Branching to %d", program_counter);
                            end
                            state <= FETCH;
                        end
                        `BNE: begin
                            // Check if branch condition is met
                            if (register_file[current_reg_dest][0] == 1'b0) begin
                                // Convert 7 bit immediate using 2's complement
                                signed_immediate = $signed(current_immediate[6:0]);
                                program_counter = program_counter - signed_immediate;
                                $display("Branching to %d", program_counter);
                            end
                            state <= FETCH;
                        end
                        `LOAD: begin
                            mem_addr <= register_file[current_reg_src] + current_shift;
                            state <= MEMORY_READ;
                        end
                        `STORE: begin
                            mem_addr <= register_file[current_reg_src][4:0];
                            mem_write_data <= register_file[current_reg_dest]; 
                            mem_write <= 1;
                            state <= NEXT_INSTRUCTION;
                        end
                    endcase
                end
                
                WRITE_BACK: begin // State 2: Write Back
                    register_file[current_reg_dest] <= alu_out;
                    mem_write <= 0;
                    state <= NEXT_INSTRUCTION;
                end
                
                NEXT_INSTRUCTION: begin // State 3: Next Instruction
                    program_counter <= program_counter + 1;
                    state <= FETCH;
                end
                
                MEMORY_READ: begin // State 4: Memory Read Complete
                    register_file[current_reg_dest] <= mem_read_data;
                    state <= NEXT_INSTRUCTION;
                end
            endcase
        end
    end
endmodule