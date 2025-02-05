// unified_system_tb.v
module unified_system_tb;
    reg clock;
    reg reset;
    reg [7:0] prog_data_in;
    reg [4:0] prog_addr;
    reg prog_write_enable;
    reg start_execution;
    wire [7:0] alu_out;
    wire load_done;

    // Instantiate the unified system
    unified_system uut (
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

    // Test scenario
    initial begin
        // Initialize
        reset = 1;
        prog_write_enable = 0;
        prog_data_in = 0;
        prog_addr = 0;
        start_execution = 0;

        // Release reset
        repeat(2) @(posedge clock);
        reset = 0;
        
        // PHASE 1: Program Loading
        $display("Phase 1: Loading Program");
        
        @(posedge clock);
        prog_addr = 5'd16;
        prog_data_in = 8'd42;
        prog_write_enable = 1;
        
        @(posedge clock);
        prog_addr = 5'd17;
        prog_data_in = 8'd24;

        @(posedge clock);
        prog_addr = 5'd0;
        prog_data_in = 8'b11011111;  // LOAD mem[16] to R0
        
        // @(posedge clock);
        // prog_addr = 5'd1;
        // prog_data_in = 8'b11000001;  // LOAD mem[17] to R1
        
        // @(posedge clock);
        // prog_addr = 5'd2;
        // prog_data_in = 8'b00101000;  // ADD R0, R1
        
        // @(posedge clock);
        // prog_addr = 5'd3;
        // prog_data_in = 8'b11110010;  // STORE R0 to mem[18]
        
        // End program loading
        @(posedge clock);
        prog_write_enable = 0;
        
        // Wait for load_done
        wait(load_done);
        $display("Program Loading Complete");
        
        // PHASE 2: Program Execution
        $display("Phase 2: Starting Execution");
        @(posedge clock);
        start_execution = 1;
        
        // Let the program run
        repeat(30) @(posedge clock);
        
        // End simulation
        $display("Execution Complete");
        $finish;
    end

    // Monitor important signals
    initial begin
        $monitor("Time=%0t ld_done=%b exec=%b pc=%d state=%d alu=%d R0=%d R1=%d R2=%d R3=%d mem16=%d mem17=%d mem18=%d", 
                 $time,
                 load_done,
                 start_execution,
                 uut.cpu.program_counter,
                 uut.cpu.state,
                 alu_out,
                 uut.cpu.register_file[0],
                 uut.cpu.register_file[1],
                 uut.cpu.register_file[2],
                 uut.cpu.register_file[3],
                 uut.memory.memory[16],
                 uut.memory.memory[17],
                 uut.memory.memory[18]);
    end
endmodule