module fetch_instruction_tb;
    // Parameters
    parameter WORD_SIZE = 16;
    
    // Clock generation
    reg clock;
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 10ns clock period
    end
    
    // Test signals
    reg [WORD_SIZE-1:0] instruction_memory;
    reg fetch_enable;
    wire [WORD_SIZE-1:0] instruction;
    
    // Test tracking
    integer test_count = 0;
    integer pass_count = 0;
    
    // Instantiate the module under test
    fetch_instruction dut (
        .clock(clock),
        .instruction_memory(instruction_memory),
        .fetch_enable(fetch_enable),
        .instruction(instruction)
    );
    
    // Helper task to check if a test passes or fails
    task check_result;
        input [WORD_SIZE-1:0] expected;
        input [8*30:1] test_name;  // 30 character max for test name
    begin
        test_count = test_count + 1;
        
        if (instruction === expected) begin
            $display("Test %0d (%s): PASS - Instruction=0x%h, Expected=0x%h", 
                     test_count, test_name, instruction, expected);
            pass_count = pass_count + 1;
        end else begin
            $display("Test %0d (%s): FAIL - Instruction=0x%h, Expected=0x%h", 
                     test_count, test_name, instruction, expected);
        end
    end
    endtask
    
    // Test procedure
    initial begin
        // Initialize signals
        instruction_memory = 0;
        fetch_enable = 0;
        
        // Wait for a few clock cycles for initialization
        #20;
        
        // Test Case 1: Load instruction with fetch_enable high
        $display("\nTest Case 1: Load instruction with fetch_enable high");
        instruction_memory = 16'hABCD;
        fetch_enable = 1;
        #10; // Wait for one clock cycle
        check_result(16'hABCD, "Initial fetch");
        
        // Test Case 2: Change instruction but keep fetch_enable high
        $display("\nTest Case 2: Change instruction with fetch_enable high");
        instruction_memory = 16'h1234;
        #10;
        check_result(16'h1234, "Consecutive fetch");
        
        // Test Case 3: Change instruction but set fetch_enable low
        // This should maintain the previous instruction
        $display("\nTest Case 3: Change instruction with fetch_enable low");
        instruction_memory = 16'h5678;
        fetch_enable = 0;
        #10;
        check_result(16'h1234, "Latch value when fetch disabled");
        
        // Test Case 4: Change instruction again with fetch_enable still low
        // Should still maintain the old value
        $display("\nTest Case 4: Another change with fetch_enable low");
        instruction_memory = 16'h9ABC;
        #10;
        check_result(16'h1234, "Maintain latch with changing input");
        
        // Test Case 5: Re-enable fetching to load new instruction
        $display("\nTest Case 5: Re-enable fetching");
        fetch_enable = 1;
        #10;
        check_result(16'h9ABC, "New fetch after latching");
        
        // Test Case 6: Finish with fetch_enable low to test holding value
        $display("\nTest Case 6: Return to latching");
        fetch_enable = 0;
        #10;
        check_result(16'h9ABC, "Final latch check");
        
        // End simulation with results summary
        $display("\n===== TEST SUMMARY =====");
        $display("Total tests: %0d", test_count);
        $display("Tests passed: %0d", pass_count);
        $display("Tests failed: %0d", test_count - pass_count);
        
        if (pass_count == test_count)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");
            
        $finish;
    end
    
    // Display state changes
    always @(posedge clock) begin
        $display("Time=%0t, Clock=%b, Fetch=%b, Memory=0x%h, Instruction=0x%h", 
                 $time, clock, fetch_enable, instruction_memory, instruction);
    end
    
    // Optional VCD file for waveform viewing
    initial begin
        $dumpfile("fetch_instruction_tb.vcd");
        $dumpvars(0, fetch_instruction_tb);
    end
    
endmodule