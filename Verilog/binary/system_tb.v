`timescale 1ns/1ps

module system_tb;
    // Test bench signals
    reg clock;
    reg reset;
    reg start;
    reg execution_done;
    reg [15:0] prev_pc;
    integer wait_cycles;
    
    // Monitor signals
    wire [15:0] alu_result;
    
    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock;  // 100MHz clock
    end
    
    // Instantiate the system
    system uut (
        .clock(clock),
        .reset(reset),
        .start(start)
    );
    
    // Monitor CPU registers for debugging
    wire [15:0] r0 = uut.cpu.register_file[0];
    wire [15:0] r1 = uut.cpu.register_file[1];
    wire [15:0] r2 = uut.cpu.register_file[2];
    wire [15:0] r3 = uut.cpu.register_file[3];
    wire [15:0] r4 = uut.cpu.register_file[4];
    wire [15:0] r5 = uut.cpu.register_file[5];
    wire [15:0] r6 = uut.cpu.register_file[6];
    wire [15:0] r7 = uut.cpu.register_file[7];
    
    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        start = 0;
        execution_done = 0;
        prev_pc = 16'hFFFF;  // Invalid initial value
        wait_cycles = 0;
        
        // Setup waveform dumping
        $dumpfile("system_tb.vcd");
        $dumpvars(0, system_tb);
        
        // Apply reset
        #20;
        reset = 0;
        #10;
        
        // Start program loading
        start = 1;
        #10;
        start = 0;
        
        // Wait for program to load and execute
        // Monitor system state
        wait(uut.system_state == uut.EXECUTING);
        $display("Program execution started");
        
        // Monitor execution
        while (!execution_done && uut.system_state == uut.EXECUTING) begin
            // Display register values on each clock cycle
            @(posedge clock);
            $display("Time=%0t PC=%0d", $time, uut.cpu.program_counter);
            $display("R0=%h R1=%h R2=%h R3=%h R4=%h R5=%h", r0, r1, r2, r3, r4, r5);
            
            // Display memory operations
            if (uut.cpu.mem_write)
                $display("Memory Write: Addr=%h Data=%h",
                        uut.cpu.mem_addr, uut.cpu.mem_write_data);
            
            // Display ALU operations
            if (uut.cpu.state == 2)  // Write Back state
                $display("ALU Result=%d", uut.cpu.alu_out);
                
            // Check if program counter has stopped changing
            if (prev_pc == uut.cpu.program_counter && uut.cpu.state == 0) begin
                wait_cycles = wait_cycles + 1;
                if (wait_cycles >= 5) begin  // Wait for 5 cycles to confirm it's truly stuck
                    execution_done = 1;
                end
            end else begin
                wait_cycles = 0;
            end
            prev_pc = uut.cpu.program_counter;
        end
        
        // Display final register values
        $display("\nFinal Register Values:");
        for (integer i = 0; i < 8; i = i + 1) begin
            // Display the values in decimal
            $display("R%0d=%d", i, uut.cpu.register_file[i]);
        end
        
        // // Display final memory values
        // $display("\nFinal Memory Values (first 8 locations):");
        // for (integer i = 0; i < 8; i = i + 1) begin
        //     $display("Mem[%0d]=%h", i, uut.ram.memory[i]);
        // end
        
        #100;
        $finish;
    end
    
    // Monitor for errors
    initial begin
        // Timeout after 10000 cycles
        #5000;
        $display("Timeout - simulation stopped");
        $finish;
    end
    
    // Monitor program loading
    always @(posedge clock) begin
        if (uut.system_state == uut.LOADING) begin
            if (uut.loader.mem_write)
                $display("Loading instruction: Addr=%h Data=%h",
                        uut.loader.mem_addr, uut.loader.mem_write_data);
        end
    end
    
endmodule