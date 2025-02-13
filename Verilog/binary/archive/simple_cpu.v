`include "ram_32x16.v"

// Program Loader Module
module program_loader (
    input wire clock,
    input wire reset,
    input wire [7:0] data_in,
    input wire [4:0] addr,
    input wire write_enable,
    output reg load_done,
    // Memory interface
    output reg mem_write,
    output reg [4:0] mem_addr,
    output reg [7:0] mem_data
);

    // States for the loader
    localparam IDLE = 1'b0;
    localparam LOADING = 1'b1;
    
    reg state;
    
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            load_done <= 0;
            mem_write <= 0;
            mem_addr <= 0;
            mem_data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (write_enable) begin
                        state <= LOADING;
                        mem_write <= 1;
                        mem_addr <= addr;
                        mem_data <= data_in;
                        load_done <= 0;
                    end else begin
                        mem_write <= 0;
                        load_done <= 1;
                    end
                end
                
                LOADING: begin
                    if (write_enable) begin
                        mem_addr <= addr;
                        mem_data <= data_in;
                    end else begin
                        state <= IDLE;
                        mem_write <= 0;
                    end
                end
            endcase
        end
    end
endmodule

// CPU Module with Clean Memory Interface
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
                        3'b000: alu_out <= register_file[reg_dest] - register_file[reg_src];
                        3'b001: alu_out <= register_file[reg_dest] + register_file[reg_src];
                        3'b010: alu_out <= register_file[reg_dest] & register_file[reg_src];
                        3'b011: alu_out <= register_file[reg_dest] | register_file[reg_src];
                        3'b100: alu_out <= register_file[reg_dest] ^ register_file[reg_src];
                        3'b110: begin // LOAD
                            mem_addr <= mem_offset;
                            state <= 4; // Extra state for memory read
                        end
                        3'b111: begin // STORE
                            mem_addr <= mem_offset;
                            mem_write_data <= register_file[reg_src];
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

// Top Module Connecting Everything
module unified_system (
    input wire clock,
    input wire reset,
    input wire [7:0] prog_data_in,
    input wire [4:0] prog_addr,
    input wire prog_write_enable,
    input wire start_execution,
    output wire [7:0] alu_out,
    output wire load_done
);

    // Internal signals
    wire [7:0] memory_read_data;
    wire [4:0] memory_address;
    wire [7:0] memory_write_data;
    wire memory_write;
    
    // Loader signals
    wire [4:0] loader_mem_addr;
    wire [7:0] loader_mem_data;
    wire loader_mem_write;
    
    // CPU signals
    wire [4:0] cpu_mem_addr;
    wire [7:0] cpu_mem_write_data;
    wire cpu_mem_write;

    // Memory address and data multiplexing
    assign memory_address = load_done ? cpu_mem_addr : loader_mem_addr;
    assign memory_write_data = load_done ? cpu_mem_write_data : loader_mem_data;
    assign memory_write = load_done ? cpu_mem_write : loader_mem_write;

    // Program Loader Instance
    program_loader loader (
        .clock(clock),
        .reset(reset),
        .data_in(prog_data_in),
        .addr(prog_addr),
        .write_enable(prog_write_enable),
        .load_done(load_done),
        .mem_write(loader_mem_write),
        .mem_addr(loader_mem_addr),
        .mem_data(loader_mem_data)
    );

    // CPU Core Instance
    cpu_core cpu (
        .clock(clock),
        .reset(reset),
        .start_execution(start_execution && load_done),
        .mem_read_data(memory_read_data),
        .mem_addr(cpu_mem_addr),
        .mem_write_data(cpu_mem_write_data),
        .mem_write(cpu_mem_write),
        .alu_out(alu_out)
    );

    // Unified Memory Instance
    ram_32x16 memory (
        .clock(clock),
        .reset(reset),
        .write_enable(memory_write),
        .address(memory_address),
        .data_in(memory_write_data),
        .data_out(memory_read_data)
    );

endmodule