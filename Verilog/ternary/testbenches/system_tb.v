`timescale 1ns/1ps

module system_tb;
    // Configuration parameter
    parameter VERBOSE = 1; // Set to 0 to disable display messages, 1 to enable
    
    // Test bench signals
    reg clock;
    reg reset;
    reg start;
    reg execution_done;
    reg [17:0] prev_pc;
    integer wait_cycles;

    // Define a function to convert ternary values to integer
    function integer ternary_to_integer_func;
        input [17:0] ternary_val;

        integer i, result;
        reg [1:0] current_trit;

        begin
            result = 0; // Initialize result to 0

            for (i = 0; i < 18; i = i + 1) begin
                // Extract the trit using a case statement instead of variable indexing
                case(i)
                    0: current_trit = ternary_val[1:0];
                    1: current_trit = ternary_val[3:2];
                    2: current_trit = ternary_val[5:4];
                    3: current_trit = ternary_val[7:6];
                    4: current_trit = ternary_val[9:8];
                    5: current_trit = ternary_val[11:10];
                    6: current_trit = ternary_val[13:12];
                    7: current_trit = ternary_val[15:14];
                    8: current_trit = ternary_val[17:16];
                    default: current_trit = 2'b00;
                endcase

                case(current_trit)
                    `_1: result = result - (3**i);  // - contribution
                    `_0: result = result;           // 0 contribution
                    `_1_: result = result + (3**i); // + contribution
                    default: result = result;  // Invalid input, do nothing
                endcase
            end

            ternary_to_integer_func = result;
        end
    endfunction
    
    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock;  // 100MHz clock
    end

    // Instantiate the gate count module
    gate_counter_top counter();
    
    // Instantiate the system
    system uut (
        .clock(clock),
        .reset(reset),
        .start(start)
    );
    
    // Monitor CPU registers for debugging
    wire [17:0] r0 = uut.cpu.regs.regs[0];
    wire [17:0] r1 = uut.cpu.regs.regs[1];
    wire [17:0] r2 = uut.cpu.regs.regs[2];
    wire [17:0] r3 = uut.cpu.regs.regs[3];
    wire [17:0] r4 = uut.cpu.regs.regs[4];
    wire [17:0] r5 = uut.cpu.regs.regs[5];
    wire [17:0] r6 = uut.cpu.regs.regs[6];
    wire [17:0] r7 = uut.cpu.regs.regs[7];
    
    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        start = 0;
        execution_done = 0;
        prev_pc = 18'hFFFF;  // Invalid initial value
        wait_cycles = 0;
        
        // Setup waveform dumping
        $dumpfile("testbenches/system_tb.vcd");
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
        if (VERBOSE) $display("Program Execution Started");
        
        // Monitor execution
        while (!execution_done && uut.system_state == uut.EXECUTING) begin
            // Display register values on each clock cycle
            @(posedge clock);
            if (VERBOSE) begin
                $display("PC    =%0d, State=%1d", ternary_to_integer_func(uut.cpu.program_counter), uut.cpu.ctrl.state);
                $display("Opcode=%6b", uut.cpu.opcode);
                // $display("Time=%0t PC=%0d", $time, uut.cpu.program_counter);
                $display("R0=%3d R1=%3d R2=%3d R3=%3d R4=%3d R5=%3d", 
                    ternary_to_integer_func(r0), 
                    ternary_to_integer_func(r1), 
                    ternary_to_integer_func(r2), 
                    ternary_to_integer_func(r3), 
                    ternary_to_integer_func(r4), 
                    ternary_to_integer_func(r5)
                );
                
                // Display memory operations
                if (uut.cpu.mem_write)
                    $display("Memory Write: Addr=%h Data=%h",
                            uut.cpu.mem_address, uut.cpu.mem_write_data);
                
                // Display ALU operations
                if (uut.cpu.state == 4)  // Write Back state
                    $display("ALU Result=%d", uut.cpu.alu_out);
            end
                
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
        
        // Display final register values - always show these regardless of verbose setting
        $display("\nFinal Register Values:");
        for (integer i = 0; i < 8; i = i + 1) begin
            // Display the values in decimal
            $display("R%0d=%3d - %b", i, ternary_to_integer_func(uut.cpu.regs.regs[i]), uut.cpu.regs.regs[i]);
        end

        // Display gate counts - always show regardless of verbose setting
        counter.display_counts;

        // Save gate counts to file
        counter.save_counts("programs/program_gate_counts.csv");

        // // Display the memory contents
        // $display("\nMemory Contents:");
        // // for (integer i = 0; i < uut.loader.MEM_SIZE; i = i + 1) begin
        // for (integer i = 16; i < 20; i = i + 1) begin
        //     $display("Addr=%0d Data=%b", i, uut.loader.memory[i]);
        // end
        
        #100;
        $finish;
    end
    
    // Monitor for errors
    initial begin
        // Timeout after 10000 cycles
        #10000;
        $display("Timeout - simulation stopped");
        $finish;
    end
    
    // Monitor program loading
    always @(posedge clock) begin
        if (uut.system_state == uut.LOADING && VERBOSE) begin
            if (uut.loader.mem_write)
                $display("Loading instruction: Addr=%b Data=%b",
                        uut.loader.mem_addr, uut.loader.mem_write_data);
        end
    end
    
endmodule