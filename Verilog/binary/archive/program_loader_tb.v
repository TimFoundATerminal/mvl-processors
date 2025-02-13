module program_loader_tb;
    reg clock;
    reg reset;
    reg [15:0] prog_data_in;
    reg [4:0] prog_addr;
    reg prog_write_enable;
    reg start_execution;
    wire [15:0] alu_out;
    wire load_done;

    // Program memory array to hold parsed instructions
    reg [15:0] program_memory [0:31];
    integer program_size;
    integer i;

    // Instantiate the unified system
    unified_system system (
        .clock(clock),
        .reset(reset),
        .prog_data_in(prog_data_in),
        .prog_addr(prog_addr),
        .prog_write_enable(prog_write_enable),
        .start_execution(start_execution),
        .alu_out(alu_out),
        .load_done(load_done)
    );

    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    // Load program from assembly file
    initial begin
        // Initialize signals
        reset = 1;
        prog_write_enable = 0;
        start_execution = 0;
        
        // Parse assembly file
        $readmemh("programs/program.hex", program_memory);
        program_size = 0;
        while (program_memory[program_size] !== 16'bx && program_size < 32) begin
            program_size = program_size + 1;
        end

        // Release reset after a few cycles
        repeat(3) @(posedge clock);
        reset = 0;
        
        // Load program into memory
        @(posedge clock);
        prog_write_enable = 1;
        
        for (i = 0; i < program_size; i = i + 1) begin
            prog_addr = i;
            prog_data_in = program_memory[i];
            @(posedge clock);
        end
        
        // Finish loading
        prog_write_enable = 0;
        
        // Wait for load_done
        wait(load_done);
        
        // Start execution
        @(posedge clock);
        start_execution = 1;
        
        // Let program run
        repeat(100) @(posedge clock);
        
        $finish;
    end

    // Monitor execution
    initial begin
        $monitor("Time=%0t pc=%d state=%d alu=%h mem[0]=%h mem[1]=%h mem[2]=%h",
                 $time,
                 system.cpu.program_counter,
                 system.cpu.state,
                 alu_out,
                 system.memory.memory[0],
                 system.memory.memory[1],
                 system.memory.memory[2]);
    end
endmodule