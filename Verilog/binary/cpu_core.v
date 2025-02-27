module cpu_core (
    input wire clock,
    input wire reset,
    input wire start_execution,
    input wire [15:0] mem_read_data,
    output reg [4:0] mem_addr,
    output reg [15:0] mem_write_data,
    output reg mem_write,
    output reg [15:0] alu_out,
    output reg halted    // New output signal to indicate halt state
);
    // Instruction types:
    // R-type: [15:11] opcode, [10:8] Ta, [7:5] Tb, [4:0] unused
    // I-type: [15:11] opcode, [10:8] Ta, [7:0] immediate
    // M-type: [15:11] opcode, [10:8] Ta, [7:5] Tb, [4:1] shift, [0] unused

    // Opcodes (3 bits)
    localparam MV    = 5'b00000; // 0
    localparam NOT   = 5'b00010; // 2
    localparam AND   = 5'b00100; // 4
    localparam OR    = 5'b00101; // 5
    localparam XOR   = 5'b00110; // 6
    localparam ADD   = 5'b00111; // 7
    localparam SUB   = 5'b01000; // 8
    localparam COMP  = 5'b01011; // 11
    localparam ANDI  = 5'b01100; // 12
    localparam ADDI  = 5'b01101; // 13
    localparam SRI   = 5'b01110; // 14
    localparam SLI   = 5'b01111; // 15
    localparam LUI   = 5'b10000; // 16
    localparam LI    = 5'b10001; // 17
    localparam BEQ   = 5'b10010; // 18
    localparam BNE   = 5'b10011; // 19
    localparam LOAD  = 5'b10110; // 22
    localparam STORE = 5'b10111; // 23
    localparam HALT  = 5'b11111; // 31

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
            state <= 0;
            mem_write <= 0;
            mem_addr <= 0;
            halted <= 0;
        end else if (start_execution && !halted) begin
            case (state)
                0: begin // Fetch
                    if (mem_read_data != 0) begin // Save the current instruction for future states
                        current_instruction <= mem_read_data;
                        current_opcode <= mem_read_data[15:11];
                        current_reg_dest <= mem_read_data[10:8];
                        current_reg_src <= mem_read_data[7:5];
                        current_immediate <= mem_read_data[7:0];
                        // current_signed_immediate <= $signed(mem_read_data[6:0]);
                        current_shift <= mem_read_data[4:1];
                    end
                    mem_addr <= program_counter;
                    mem_write <= 0;
                    state <= 1;
                end
                
                1: begin // Decode and Execute
                    case (opcode)
                        HALT: begin
                            halted <= 1;  // Set halted flag
                            state <= state;  // Stay in current state
                        end
                        MV: begin
                            register_file[current_reg_dest] <= register_file[current_reg_src];
                            state <= 3;
                        end
                        NOT: begin
                            alu_out <= ~register_file[current_reg_src];
                            state <= 2;
                        end
                        AND: begin
                            alu_out <= register_file[current_reg_dest] & register_file[current_reg_src];
                            state <= 2;
                        end
                        OR: begin
                            alu_out <= register_file[current_reg_dest] | register_file[current_reg_src];
                            state <= 2;
                        end
                        XOR: begin
                            alu_out <= register_file[current_reg_dest] ^ register_file[current_reg_src];
                            state <= 2;
                        end
                        ADD: begin
                            alu_out <= register_file[current_reg_dest] + register_file[current_reg_src];
                            state <= 2;
                        end
                        SUB: begin
                            alu_out <= register_file[current_reg_dest] - register_file[current_reg_src];
                            state <= 2;
                        end
                        COMP: begin
                            alu_out <= (register_file[current_reg_dest] == register_file[current_reg_src]);
                            state <= 2;
                        end
                        ANDI: begin
                            register_file[current_reg_dest] <= register_file[current_reg_dest] & immediate;
                            state <= 3;
                        end
                        ADDI: begin
                            register_file[current_reg_dest] <= register_file[current_reg_dest] + immediate;
                            state <= 3;
                        end
                        SRI: begin
                            register_file[current_reg_dest] <= register_file[current_reg_dest] >> shift;
                            state <= 3;
                        end
                        SLI: begin
                            register_file[current_reg_dest] <= register_file[current_reg_dest] << shift;
                            state <= 3;
                        end
                        LUI: begin
                            register_file[current_reg_dest] <= {immediate, 8'b0};
                            state <= 3;
                        end
                        LI: begin
                            register_file[current_reg_dest] <= {register_file[current_reg_dest][15:8], immediate};
                            state <= 3;
                        end
                        BEQ: begin
                            // If the register address's last bit is bit B first immediate, then apply the immediate value to the PC
                            if (register_file[current_reg_dest][0] == 1'b1) begin
                                // convert 7 bit immediate using 2's complement
                                signed_immediate = $signed(immediate[6:0]);
                                $display("PC: %d, Signed Imm: %d", program_counter, signed_immediate);
                                program_counter <= program_counter - signed_immediate;
                            end
                            state <= 0;
                        end
                        BNE: begin
                            // If the register address's last bit is not equal to the immediate value, then apply the immediate value to the PC
                            // check if the register does not equal 1
                            if (register_file[current_reg_dest][0] == 1'b0) begin
                                // convert 7 bit immediate using 2's complement
                                signed_immediate = $signed(immediate[6:0]);
                                $display("PC: %d, Signed Imm: %d", program_counter, signed_immediate);
                                program_counter <= program_counter - signed_immediate;
                            end
                            state <= 0;
                        end
                        LOAD: begin
                            mem_addr <= register_file[current_reg_src] + shift;
                            state <= 4;
                        end
                        STORE: begin
                            mem_addr <= register_file[current_reg_src][4:0];
                            mem_write_data <= register_file[current_reg_dest]; 
                            mem_write <= 1;
                            state <= 3;
                        end
                    endcase
                end
                
                2: begin // Write Back
                    register_file[current_reg_dest] <= alu_out;
                    mem_write <= 0;
                    state <= 3;
                end
                
                3: begin // Next Instruction
                    program_counter <= program_counter + 1;
                    state <= 0;
                end
                
                4: begin // Memory Read Complete
                    register_file[current_reg_dest] <= mem_read_data;
                    state <= 3;
                end
            endcase
        end
    end
endmodule