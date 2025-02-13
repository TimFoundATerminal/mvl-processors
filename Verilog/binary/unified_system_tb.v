// unified_system_tb.v
module unified_system_tb;
    reg clock;
    reg reset;
    reg [15:0] prog_data_in;
    reg [4:0] prog_addr;
    reg prog_write_enable;
    reg start_execution;
    wire [15:0] alu_out;
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
    
        // Load program
        @(posedge clock);
        prog_write_enable = 1;

        // LUI R1, 0xAA
        prog_addr = 5'd0;
        prog_data_in = {5'b10000, 3'b001, 8'b00000001};
        @(posedge clock);

        // LI R1, 0x55
        prog_addr = 5'd1;
        prog_data_in = {5'b10001, 3'b001, 8'b00000001};
        @(posedge clock);

        // MV R2, R1
        prog_addr = 5'd2;
        prog_data_in = {5'b00000, 3'b010, 3'b001, 5'b0};
        @(posedge clock);

        // // NOT R0, R1
        // prog_addr = 5'd3;
        // prog_data_in = {5'b00010, 3'b000, 3'b001, 5'b0};
        // @(posedge clock);

        // // AND R3, R4
        // prog_addr = 5'd4;
        // prog_data_in = {5'b00100, 3'b011, 3'b100, 5'b0};
        // @(posedge clock);

        // // OR R5, R2, R1
        // prog_addr = 5'd5;
        // prog_data_in = {5'b00101, 3'b101, 3'b001, 5'b0};
        // @(posedge clock);

        // // XOR R6, R2, R1
        // prog_addr = 5'd6;
        // prog_data_in = {5'b00110, 3'b110, 3'b001, 5'b0};
        // @(posedge clock);

        // ADD R7, R2, R1
        prog_addr = 5'd7;
        prog_data_in = {5'b00111, 3'b111, 3'b001, 5'b0};
        @(posedge clock);

        // SUB R0, R2, R1
        prog_addr = 5'd8;
        prog_data_in = {5'b01000, 3'b000, 3'b001, 5'b0};
        @(posedge clock);

        // COMP R1, R2
        prog_addr = 5'd9;
        prog_data_in = {5'b01011, 3'b001, 3'b010, 5'b0};
        @(posedge clock);

        // STORE R1, R0
        prog_addr = 5'd10;
        prog_data_in = {5'b10111, 3'b001, 3'b000, 5'b0};
        @(posedge clock);

        // LOAD R3, R0
        prog_addr = 5'd11;
        prog_data_in = {5'b10110, 3'b011, 3'b000, 5'b0};
        @(posedge clock);
        
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
        $monitor("Time=%0t pc=%d state=%d alu=%d R0=%d R1=%d R2=%d R3=%d R4=%d R5=%d R6=%d R7=%d", 
                 $time,
                 uut.cpu.program_counter,
                 uut.cpu.state,
                 alu_out,
                 uut.cpu.register_file[0],
                 uut.cpu.register_file[1],
                 uut.cpu.register_file[2],
                 uut.cpu.register_file[3],
                 uut.cpu.register_file[4],
                 uut.cpu.register_file[5],
                 uut.cpu.register_file[6],
                 uut.cpu.register_file[7]);
    end
endmodule