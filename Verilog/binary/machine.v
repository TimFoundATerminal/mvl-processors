module system (
    input wire clock,
    input wire reset,
    input wire start
);

    `include "parameters.vh"

    // Internal signals for memory interface
    wire [MEM_ADDR_SIZE-1:0] mem_addr;
    wire [WORD_SIZE-1:0] mem_write_data;
    wire [WORD_SIZE-1:0] mem_read_data;
    wire mem_write;
    wire cpu_halted;
    
    // Control signals
    reg start_execution;
    wire load_complete;
    
    // Multiplexed memory control signals
    wire [MEM_ADDR_SIZE-1:0] cpu_mem_addr;
    wire [WORD_SIZE-1:0] cpu_mem_write_data;
    wire cpu_mem_write;
    wire cpu_mem_read;
    wire [MEM_ADDR_SIZE-1:0] loader_mem_addr;
    wire [WORD_SIZE-1:0] loader_mem_write_data;
    wire loader_mem_write;
    
    // State machine for system control
    reg [1:0] system_state;
    localparam IDLE = 2'b00;
    localparam LOADING = 2'b01;
    localparam EXECUTING = 2'b10;
    localparam HALTED = 2'b11;
    
    // Instantiate CPU Core
    cpu cpu (
        .clock(clock),
        .reset(reset),
        .execute(start_execution),
        .mem_read_data(mem_read_data),
        .mem_address(cpu_mem_addr),
        .mem_write_data(cpu_mem_write_data),
        .mem_write(cpu_mem_write),
        .mem_read(cpu_mem_read),
        .halted(cpu_halted)
    );
    
    // Instantiate RAM
    memory ram (
        .clock(clock),
        .reset(reset),
        .write_enable(mem_write),
        .read_enable(mem_read),
        .address(mem_addr),
        .data_in(mem_write_data),
        .data_out(mem_read_data)
    );
    
    // Instantiate Program Loader
    program_loader loader (
        .clock(clock),
        .reset(reset),
        .start_load(system_state == LOADING),
        .load_complete(load_complete),
        .mem_addr(loader_mem_addr),
        .mem_write_data(loader_mem_write_data),
        .mem_write(loader_mem_write)
    );
    
    // Memory interface multiplexing
    assign mem_addr = (system_state == LOADING) ? loader_mem_addr : cpu_mem_addr;
    assign mem_write_data = (system_state == LOADING) ? loader_mem_write_data : cpu_mem_write_data;
    assign mem_write = (system_state == LOADING) ? loader_mem_write : cpu_mem_write;
    assign mem_read = cpu_mem_read;
    
    // System control state machine
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            system_state <= IDLE;
            start_execution <= 0;
        end else begin
            case (system_state)
                IDLE: begin
                    if (start) begin
                        system_state <= LOADING;
                        start_execution <= 0;
                    end
                end
                
                LOADING: begin
                    if (load_complete) begin
                        system_state <= EXECUTING;
                        start_execution <= 1;
                    end
                end
                
                EXECUTING: begin
                    if (cpu_halted) begin
                        system_state <= HALTED;
                        start_execution <= 0;  // Stop CPU execution
                    end else begin
                        start_execution <= 1;
                    end
                end
                
                HALTED: begin
                    // Stay halted until reset
                    start_execution <= 0;
                end
                
                default: begin
                    system_state <= IDLE;
                end
            endcase
        end
    end
    
    // // Debug/monitoring statements
    // always @(posedge clock) begin
    //     case (system_state)
    //         IDLE: $display("System State: IDLE");
    //         LOADING: $display("System State: LOADING Program");
    //         EXECUTING: $display("System State: EXECUTING Program");
    //         HALTED: $display("System State: HALTED");
    //     endcase
    // end

endmodule