// ALU Testbench
`timescale 1ns/1ps

module alu_testbench();
    // Include parameters file
    `include "parameters.vh"
    
    // Testbench signals
    reg clock;
    reg [4:0] opcode;
    reg [WORD_SIZE-1:0] input1, input2;
    reg alu_enable;
    wire [WORD_SIZE-1:0] alu_out;

    // Instantiate the gate count module
    gate_counter_top counter();
    
    // Instantiate the ALU
    alu dut(
        .clock(clock),
        .opcode(opcode),
        .input1(input1),
        .input2(input2),
        .alu_enable(alu_enable),
        .alu_out(alu_out)
    );
    
    // Clock generation
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // 100MHz clock
    end
    
    // Test stimulus and verification
    initial begin
        // Initialize signals
        alu_enable = 0;
        input1 = 0;
        input2 = 0;
        opcode = 0;
        
        // Start by testing with ALU disabled
        #10;
        input1 = 16'hAAAA;
        input2 = 16'h5555;
        opcode = `ADD;
        #10;
        
        // Check that output doesn't change when ALU is disabled
        if (alu_out !== 16'h0000) begin
            $display("TEST FAILED: ALU operated while disabled");
            $display("  Inputs: %h, %h", input1, input2);
            $display("  Opcode: %h", opcode);
            $display("  Output: %h", alu_out);
        end
        
        // Enable ALU and test each operation
        alu_enable = 1;
        
        // Test NOT operation
        test_operation(`NOT, 16'h5A5A, 16'h0000, ~16'h5A5A, "NOT");
        
        // Test AND operation
        test_operation(`AND, 16'hAAAA, 16'h5555, 16'hAAAA & 16'h5555, "AND");
        
        // Test OR operation
        test_operation(`OR, 16'hAAAA, 16'h5555, 16'hAAAA | 16'h5555, "OR");
        
        // Test XOR operation
        test_operation(`XOR, 16'hAAAA, 16'h5555, 16'hAAAA ^ 16'h5555, "XOR");
        
        // Test ADD operation (normal case)
        test_operation(`ADD, 16'h1234, 16'h5678, 16'h1234 + 16'h5678, "ADD");
        
        // Test ADD operation (with carry)
        test_operation(`ADD, 16'hFFFF, 16'h0001, 16'h0000, "ADD with overflow");
        
        // Test ADDI operation
        test_operation(`ADDI, 16'h1234, 16'h0042, 16'h1234 + 16'h0042, "ADDI");
        
        // Test SUB operation (normal case)
        test_operation(`SUB, 16'h5678, 16'h1234, 16'h5678 - 16'h1234, "SUB");
        
        // Test SUB operation (with borrow)
        test_operation(`SUB, 16'h1234, 16'h5678, 16'h1234 - 16'h5678, "SUB with borrow");
        
        // // Test COMP operation (equal)
        // test_operation(`COMP, 16'h1234, 16'h1234, 16'h0001, "COMP equal");
        
        // // Test COMP operation (not equal)
        // test_operation(`COMP, 16'h1234, 16'h5678, 16'h0000, "COMP not equal");
        
        // Test ANDI operation
        test_operation(`ANDI, 16'hAAAA, 16'h5555, 16'hAAAA & 16'h5555, "ANDI");
        
        // Test EQ operation (equal to) - should return 1 when inputs are equal
        test_operation(`EQ, 16'h1234, 16'h1234, 16'h0001, "EQ - equal values");

        // Test EQ operation (equal to) - should return 0 when inputs are different
        test_operation(`EQ, 16'h1234, 16'h5678, 16'h0000, "EQ - different values");

        // Test LT operation (less than) - should return 1 when first input is less than second
        test_operation(`LT, 16'h1234, 16'h5678, 16'h0001, "LT - first < second");

        // Test LT operation (less than) - should return 0 when first input is greater than second
        test_operation(`LT, 16'h5678, 16'h1234, 16'h0000, "LT - first > second");

        // Test LT operation (less than) - should return 0 when inputs are equal
        test_operation(`LT, 16'h1234, 16'h1234, 16'h0000, "LT - equal values");
        
        // Test edge case - all operations with zero values
        test_operation(`ADD, 16'h0000, 16'h0000, 16'h0000, "ADD zeros");
        test_operation(`AND, 16'h0000, 16'hFFFF, 16'h0000, "AND zero");
        test_operation(`OR, 16'h0000, 16'h0000, 16'h0000, "OR zeros");
        test_operation(`XOR, 16'h0000, 16'h0000, 16'h0000, "XOR zeros");
        
        // Special test for ripple carry adder - check multiple bit patterns
        test_ripple_adder_patterns();
        
        // End simulation
        #20;
        $display("All tests completed");
        $finish;
    end
    
    // Task to test a specific ALU operation
    task test_operation;
        input [4:0] op;
        input [WORD_SIZE-1:0] in1;
        input [WORD_SIZE-1:0] in2;
        input [WORD_SIZE-1:0] expected;
        input [8*20:1] op_name; // Character array to store operation name
        
        begin
            // Set inputs
            @(negedge clock);
            opcode = op;
            input1 = in1;
            input2 = in2;
            
            // Wait for operation to complete
            @(posedge clock);
            @(posedge clock);
            
            // Check result
            if (alu_out !== expected) begin
                $display("TEST FAILED: %s operation", op_name);
                $display("  Inputs: %h, %h", in1, in2);
                $display("  Expected: %h", expected);
                $display("  Got: %h", alu_out);
            end else begin
                $display("TEST PASSED: %s operation", op_name);
            end
        end
    endtask
    
    // Task to test ripple carry adder with various bit patterns
    task test_ripple_adder_patterns;
        integer i;
        reg [WORD_SIZE-1:0] a, b, expected;
        begin
            $display("Testing ripple carry adder with various patterns...");
            
            // Test with incrementing values
            for (i = 0; i < 10; i = i + 1) begin
                a = i;
                b = 10 - i;
                expected = a + b;
                
                @(negedge clock);
                opcode = `ADD;
                input1 = a;
                input2 = b;
                
                @(posedge clock);
                @(posedge clock);
                
                if (alu_out !== expected) begin
                    $display("ADDER TEST FAILED");
                    $display("  Inputs: %h, %h", a, b);
                    $display("  Expected: %h", expected);
                    $display("  Got: %h", alu_out);
                end
            end
            
            // Test with alternating bit patterns
            @(negedge clock);
            opcode = `ADD;
            input1 = 16'hAAAA;
            input2 = 16'h5555;
            expected = 16'hFFFF;
            
            @(posedge clock);
            @(posedge clock);
            
            if (alu_out !== expected) begin
                $display("ADDER TEST FAILED: Alternating bits");
                $display("  Inputs: %h, %h", input1, input2);
                $display("  Expected: %h", expected);
                $display("  Got: %h", alu_out);
            end
            
            // Test carry propagation through all bits
            @(negedge clock);
            opcode = `ADD;
            input1 = 16'hFFFF;
            input2 = 16'h0001;
            expected = 16'h0000; // With overflow
            
            @(posedge clock);
            @(posedge clock);
            
            if (alu_out !== expected) begin
                $display("ADDER TEST FAILED: Full carry propagation");
                $display("  Inputs: %h, %h", input1, input2);
                $display("  Expected: %h", expected);
                $display("  Got: %h", alu_out);
            end
            
            $display("Ripple carry adder tests completed");
        end
    endtask

endmodule