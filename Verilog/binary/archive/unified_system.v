// unified_system.v
module unified_system (
    input wire clock,
    input wire reset,
    input wire [15:0] prog_data_in,
    input wire [4:0] prog_addr,
    input wire prog_write_enable,
    input wire start_execution,
    output wire [15:0] alu_out,
    output wire load_done
);

    // Internal signals
    wire [15:0] memory_read_data;
    wire [4:0] memory_address;
    wire [15:0] memory_write_data;
    wire memory_write;
    
    // Loader signals
    wire [4:0] loader_mem_addr;
    wire [15:0] loader_mem_data;
    wire loader_mem_write;
    
    // CPU signals
    wire [4:0] cpu_mem_addr;
    wire [15:0] cpu_mem_write_data;
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
        .mem_read_data(memory_read_data),                   // Comes from the RAM
        .mem_addr(cpu_mem_addr),                            // Goes to the RAM
        .mem_write_data(cpu_mem_write_data),                // Goes to the RAM
        .mem_write(cpu_mem_write),                          // Goes to the RAM
        .alu_out(alu_out)
    );

    // Unified Memory Instance
    ram_32x16 memory (
        .clock(clock),
        .reset(reset),
        .write_enable(memory_write),                        // Connected to CPU's mem_write
        .address(memory_address),                           // Connected to CPU's mem_addr
        .data_in(memory_write_data),                        // Connected to CPU's mem_write_data
        .data_out(memory_read_data)                         // Connected to CPU's mem_read_data
    );

endmodule