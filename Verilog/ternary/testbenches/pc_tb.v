`timescale 1ns / 1ps

module program_counter_tb();

    // Define ternary encodings for readability in the testbench
    `define _1  2'b11 // -1
    `define _0  2'b00 // 0
    `define _1_ 2'b01 // 1
    
    // Define parameters 
    parameter WORD_SIZE = 9;      // 9 trits for the CPU word size
    parameter MEM_ADDR_SIZE = 3;  // 3 trits for the program counter
    
    // Create a mock parameters.vh file contents
    `define WORD_SIZE 9
    `define MEM_ADDR_SIZE 3
    
    // Clock parameters
    parameter CLK_PERIOD = 10;  // Clock period in ns
    
    // Test bench signals
    reg clock;
    reg reset_enable;
    reg update_enable;
    reg [2*WORD_SIZE-1:0] value;
    wire [2*MEM_ADDR_SIZE-1:0] out;
    
    // Instantiate the module under test
    program_counter dut (
        .clock(clock),
        .reset_enable(reset_enable),
        .update_enable(update_enable),
        .value(value),
        .out(out)
    );
    
    // Generate clock
    always begin
        #(CLK_PERIOD/2) clock = ~clock;
    end
    
    // Helper task to display ternary value
    task display_ternary;
        input [2*MEM_ADDR_SIZE-1:0] ternary_val;
        // input string label;
        reg [1:0] trit;
        integer i;
        begin
            // $write("%s: [", label);
            for (i = MEM_ADDR_SIZE-1; i >= 0; i = i - 1) begin
                // Manual bit selection to avoid variable part select
                case(i)
                    0: trit = ternary_val[1:0];
                    1: trit = ternary_val[3:2];
                    2: trit = ternary_val[5:4];
                    default: trit = 2'bxx;
                endcase
                
                case(trit)
                    `_1: $write("-1");
                    `_0: $write("0");
                    `_1_: $write("1");
                    default: $write("X");
                endcase
                if (i > 0) $write(",");
            end
            // $write("]");
        end
    endtask
    
    // Helper function to convert ternary to decimal
    function integer ternary_to_decimal;
        input [2*MEM_ADDR_SIZE-1:0] ternary_val;
        integer result, i;
        reg [1:0] trit;
        begin
            result = 0;
            for (i = 0; i < MEM_ADDR_SIZE; i = i + 1) begin
                case (i)
                    0: trit = ternary_val[1:0];
                    1: trit = ternary_val[3:2];
                    2: trit = ternary_val[5:4];
                    default: trit = 2'b00;
                endcase
                
                case (trit)
                    `_1: result = result - (3**i);    // -1 × 3^i
                    `_1_: result = result + (3**i);   // 1 × 3^i
                    default: result = result;         // 0 × 3^i
                endcase
            end
            ternary_to_decimal = result;
        end
    endfunction
    
    // Main test procedure
    initial begin
        // Initialize values
        clock = 0;
        reset_enable = 0;
        update_enable = 0;
        value = 0;
        
        // Wait a few clock cycles
        #(3*CLK_PERIOD);
        
        $display("\n=== PROGRAM COUNTER TESTBENCH STARTED ===\n");
        
        // TEST 1: Reset the program counter
        reset_enable = 1;
        update_enable = 0;
        
        #(CLK_PERIOD);
        
        $write("After reset: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        reset_enable = 0;
        
        // TEST 2: Increment by 1
        update_enable = 1;
        // Set value to [0,0,0,0,0,0,0,0,1] = 1 in decimal
        value = {`_0, `_0, `_0, `_0, `_0, `_0, `_0, `_0, `_1_};
        
        #(CLK_PERIOD);
        
        $write("After increment by 1: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        // TEST 3: Increment by another 1
        update_enable = 1;
        // Keep value as [0,0,0,0,0,0,0,0,1] = 1 in decimal
        
        #(CLK_PERIOD);
        
        $write("After increment by 1 again: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        // TEST 4: Increment by a larger value
        update_enable = 1;
        // Set value to [0,0,0,0,0,0,0,1,0] = 3 in decimal
        value = {`_0, `_0, `_0, `_0, `_0, `_0, `_0, `_1_, `_0};
        
        #(CLK_PERIOD);
        
        $write("After increment by 3: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        // TEST 5: Decrement by 1
        update_enable = 1;
        // Set value to [0,0,0,0,0,0,0,0,-1] = -1 in decimal
        value = {`_0, `_0, `_0, `_0, `_0, `_0, `_0, `_0, `_1};
        
        #(CLK_PERIOD);
        
        $write("After decrement by 1: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        // TEST 6: Use a large value that requires truncation
        update_enable = 1;
        // Set value to [0,0,0,0,0,1,0,0,0] = 27 in decimal
        // But PC is only 3 trits, so only the lower 3 trits will be used
        value = {`_0, `_0, `_0, `_0, `_0, `_1_, `_0, `_0, `_0};
        
        #(CLK_PERIOD);
        
        $write("After adding a value requiring truncation: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        // TEST 7: Reset and ensure it clears to 0
        reset_enable = 1;
        update_enable = 0;
        
        #(CLK_PERIOD);
        
        $write("After reset: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        reset_enable = 0;
        
        // TEST 8: Test both positive and negative wrapping behavior
        // First, set to a large positive value
        update_enable = 1;
        // Set to maximum 3-trit value: [1,1,1] = 13 in decimal by adding twice
        value = {`_0, `_0, `_0, `_0, `_0, `_0, `_1_, `_1_, `_1_};
        
        #(CLK_PERIOD);
        #(CLK_PERIOD);
        
        $write("After setting to max value: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        // Then increment to cause overflow
        update_enable = 1;
        value = {`_0, `_0, `_0, `_0, `_0, `_0, `_0, `_0, `_1_};
        
        #(CLK_PERIOD);
        
        $write("After overflow: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        // Then, set to a large negative value
        reset_enable = 1;
        #(CLK_PERIOD);
        reset_enable = 0;
        
        // update_enable = 1;
        // // Set to minimum 3-trit value: [-1,-1,-1] = -13 in decimal
        // value = {`_0, `_0, `_0, `_0, `_0, `_0, `_1, `_1, `_1};
        
        // #(CLK_PERIOD);
        
        $write("After setting to min value: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        // Then decrement to cause underflow
        update_enable = 1;
        value = {`_0, `_0, `_0, `_0, `_0, `_0, `_0, `_0, `_1};
        
        #(CLK_PERIOD);
        
        $write("After underflow: ");
        display_ternary(out);
        $display(" (Decimal: %0d)", ternary_to_decimal(out));
        
        // Disable updates
        update_enable = 0;
        
        $display("\n=== PROGRAM COUNTER TESTBENCH COMPLETED ===\n");
        
        // End simulation
        #(5*CLK_PERIOD);
        $finish;
    end
    
    // Add a timeout to prevent infinite loops
    initial begin
        #(1000*CLK_PERIOD);  // Timeout after 1000 clock cycles
        $display("ERROR: Testbench timeout reached. Simulation forcibly terminated.");
        $finish;
    end

endmodule