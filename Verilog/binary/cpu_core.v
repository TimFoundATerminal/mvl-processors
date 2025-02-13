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
    localparam MV    = 5'b00000;
    localparam NOT   = 5'b00010;
    localparam AND   = 5'b00100;
    localparam OR    = 5'b00101;
    localparam XOR   = 5'b00110;
    localparam ADD   = 5'b00111;
    localparam SUB   = 5'b01000;
    localparam COMP  = 5'b01011;
    localparam LUI   = 5'b10000;
    localparam LI    = 5'b10001;
    localparam LOAD  = 5'b10110;
    localparam STORE = 5'b10111;
    localparam HALT  = 5'b11111;

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
            $display("State: %d", state); // this will throw a compilation error
            case (state)
                0: begin // Fetch
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
                            register_file[reg_dest] <= register_file[reg_src];
                            state <= 3;
                        end
                        NOT: begin
                            alu_out <= ~register_file[reg_src];
                            state <= 2;
                        end
                        AND: begin
                            alu_out <= register_file[reg_dest] & register_file[reg_src];
                            state <= 2;
                        end
                        OR: begin
                            alu_out <= register_file[reg_dest] | register_file[reg_src];
                            state <= 2;
                        end
                        XOR: begin
                            alu_out <= register_file[reg_dest] ^ register_file[reg_src];
                            state <= 2;
                        end
                        ADD: begin
                            alu_out <= register_file[reg_dest] + register_file[reg_src];
                            state <= 2;
                        end
                        SUB: begin
                            alu_out <= register_file[reg_dest] - register_file[reg_src];
                            state <= 2;
                        end
                        COMP: begin
                            alu_out <= register_file[reg_dest] == register_file[reg_src];
                            state <= 2;
                        end
                        LUI: begin
                            register_file[reg_dest] <= {immediate, 8'b0};
                            state <= 3;
                        end
                        LI: begin
                            register_file[reg_dest] <= {register_file[reg_dest][15:8], immediate};
                            state <= 3;
                        end
                        LOAD: begin
                            mem_addr <= register_file[reg_src] + shift;
                            state <= 4;
                        end
                        STORE: begin
                            mem_addr <= register_file[reg_src][4:0];
                            mem_write_data <= register_file[reg_dest]; 
                            mem_write <= 1;
                            state <= 3;
                        end
                    endcase
                end
                
                2: begin // Write Back
                    // if (opcode <= LOAD) begin
                    $display("ALU Result: %h", alu_out);
                    register_file[reg_dest] <= alu_out;
                    // end
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