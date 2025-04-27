module memory_tb;
    // Parameters from the DUT
    parameter WORD_SIZE = 16;
    parameter MEM_SIZE = 128;
    parameter MEM_ADDR_SIZE = 8;
    
    // Inputs
    reg clock;
    reg reset;
    reg read_enable;
    reg write_enable;
    reg [MEM_ADDR_SIZE-1:0] address;
    reg [WORD_SIZE-1:0] data_in;
    
    // Outputs
    wire [WORD_SIZE-1:0] data_out;
    
    // Instantiate the Device Under Test (DUT)
    memory dut (
        .clock(clock),
        .reset(reset),
        .read_enable(read_enable),
        .write_enable(write_enable),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    // Generate clock - 10ns period (100MHz)
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end
    
    // Test variables
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;
    
    // Task to check test results
    task check_result;
        input [WORD_SIZE-1:0] expected;
        input [7:0] test_id;
    begin
        test_count = test_count + 1;
        
        if (data_out === expected) begin
            $display("PASS: Test %0d - Expected: %h, Got: %h", test_id, expected, data_out);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: Test %0d - Expected: %h, Got: %h", test_id, expected, data_out);
            fail_count = fail_count + 1;
        end
    end
    endtask
    
    // Task to write to memory
    task write_mem;
        input [MEM_ADDR_SIZE-1:0] addr;
        input [WORD_SIZE-1:0] data;
    begin
        @(negedge clock);
        address = addr;
        data_in = data;
        write_enable = 1;
        read_enable = 0;
        @(posedge clock);
        @(negedge clock);
        write_enable = 0;
    end
    endtask
    
    // Task to read from memory
    task read_mem;
        input [MEM_ADDR_SIZE-1:0] addr;
    begin
        @(negedge clock);
        address = addr;
        read_enable = 1;
        write_enable = 0;
        @(posedge clock);
        @(negedge clock);
        read_enable = 0;
    end
    endtask
    
    // Test scenario
    initial begin
        // Initialize signals
        reset = 0;
        read_enable = 0;
        write_enable = 0;
        address = 0;
        data_in = 0;
        
        // Apply reset
        @(negedge clock);
        reset = 1;
        @(posedge clock);
        @(negedge clock);
        reset = 0;
        
        $display("\n----- STARTING MEMORY MODULE TESTS -----\n");
        
        // Test 1: Write and read from a single address
        write_mem(8'd10, 16'hABCD);
        read_mem(8'd10);
        @(posedge clock); // Wait for data to be available
        check_result(16'hABCD, 1);
        
        // Test 2: Write to multiple addresses and read back
        write_mem(8'd20, 16'h1234);
        write_mem(8'd21, 16'h5678);
        write_mem(8'd22, 16'h9ABC);
        
        read_mem(8'd20);
        @(posedge clock);
        check_result(16'h1234, 2);
        
        read_mem(8'd21);
        @(posedge clock);
        check_result(16'h5678, 3);
        
        read_mem(8'd22);
        @(posedge clock);
        check_result(16'h9ABC, 4);
        
        // Test 5: Write to same address multiple times (check that last write wins)
        write_mem(8'd30, 16'hDEAD);
        write_mem(8'd30, 16'hBEEF);
        read_mem(8'd30);
        @(posedge clock);
        check_result(16'hBEEF, 5);
        
        // Test 6: Read without prior write (should return 0 after reset)
        read_mem(8'd40);
        @(posedge clock);
        check_result(16'h0000, 6);
        
        // Test 7: Write with read_enable also active (write should succeed)
        @(negedge clock);
        address = 8'd50;
        data_in = 16'hAAAA;
        write_enable = 1;
        read_enable = 1; // Both signals active
        @(posedge clock);
        @(negedge clock);
        write_enable = 0;
        read_enable = 0;
        
        // Verify the write succeeded
        read_mem(8'd50);
        @(posedge clock);
        check_result(16'hAAAA, 7);
        
        // Test 8: Read after reset (should show 0)
        write_mem(8'd60, 16'h7777);
        
        // Apply reset
        @(negedge clock);
        reset = 1;
        @(posedge clock);
        @(negedge clock);
        reset = 0;
        
        // Read the address that was written
        read_mem(8'd60);
        @(posedge clock);
        check_result(16'h0000, 8);
        
        // Test 9: Write to address 0
        write_mem(8'd0, 16'h8888);
        read_mem(8'd0);
        @(posedge clock);
        check_result(16'h8888, 9);
        
        // Test 10: Write to highest address
        write_mem(8'd127, 16'h9999);
        read_mem(8'd127);
        @(posedge clock);
        check_result(16'h9999, 10);
        
        // Test 11: Read with write_enable also active (read should return previous value)
        write_mem(8'd70, 16'hCCCC);
        
        @(negedge clock);
        address = 8'd70;
        data_in = 16'hDDDD; // New data, shouldn't be read yet
        read_enable = 1;
        write_enable = 1;
        @(posedge clock);
        @(negedge clock);
        read_enable = 0;
        write_enable = 0;
        
        // Verify what value was read (should be previous value)
        check_result(16'hCCCC, 11);
        
        // Test 12: Verify the write from Test 11 succeeded
        read_mem(8'd70);
        @(posedge clock);
        check_result(16'hDDDD, 12);
        
        // Display test summary
        $display("\n----- TEST SUMMARY -----");
        $display("Total tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("-----------------------\n");
        
        if (fail_count == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");
            
        $finish;
    end
endmodule