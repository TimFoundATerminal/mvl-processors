`timescale 1ns / 1ps

module memory_tb();
    // Define ternary encodings for readability in the testbench
    `define _1  2'b11 // -1
    `define _0  2'b00 // 0
    `define _1_ 2'b01 // 1

    // Define parameters
    parameter WORD_SIZE = 9;      // 9 trits for each word
    parameter MEM_ADDR_SIZE = 3;  // 3 trits for addressing
    parameter MEM_SIZE = 27;      // 3^3 = 27 memory locations

    // Create a mock parameters.vh file contents
    `define WORD_SIZE 9
    `define MEM_ADDR_SIZE 3
    `define MEM_SIZE 27

    // Clock parameters
    parameter CLK_PERIOD = 10;  // Clock period in ns

    // Test bench signals
    reg clock;
    reg reset;
    reg read_enable;
    reg write_enable;
    reg [2*MEM_ADDR_SIZE-1:0] address;
    reg [2*WORD_SIZE-1:0] data_in;
    wire [2*WORD_SIZE-1:0] data_out;

    // Instantiate the module under test
    memory dut (
        .clock(clock),
        .reset(reset),
        .read_enable(read_enable),
        .write_enable(write_enable),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Generate clock
    always begin
        #(CLK_PERIOD/2) clock = ~clock;
    end

    // Helper task to display ternary value
    task display_ternary_value;
        input [2*WORD_SIZE-1:0] ternary_val;
        reg [1:0] trit;
        integer i;
        begin
            $write("[");
            for (i = WORD_SIZE-1; i >= 0; i = i - 1) begin
                // Manual bit selection to avoid variable part select
                case(i)
                    0: trit = ternary_val[1:0];
                    1: trit = ternary_val[3:2];
                    2: trit = ternary_val[5:4];
                    3: trit = ternary_val[7:6];
                    4: trit = ternary_val[9:8];
                    5: trit = ternary_val[11:10];
                    6: trit = ternary_val[13:12];
                    7: trit = ternary_val[15:14];
                    8: trit = ternary_val[17:16];
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
            $write("]");
        end
    endtask

    // Helper task to display ternary address
    task display_ternary_address;
        input [2*MEM_ADDR_SIZE-1:0] ternary_val;
        reg [1:0] trit;
        integer i;
        begin
            $write("[");
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
            $write("]");
        end
    endtask

    // Helper function to convert ternary to decimal (for addresses)
    function integer address_to_decimal;
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
            address_to_decimal = result;
        end
    endfunction

    // Main test procedure
    initial begin
        // Initialize values
        clock = 0;
        reset = 0;
        read_enable = 0;
        write_enable = 0;
        address = 0;
        data_in = 0;
        
        // Wait a few clock cycles
        #(3*CLK_PERIOD);
        
        $display("\n=== TERNARY MEMORY TESTBENCH STARTED ===\n");
        
        // TEST 1: Reset the memory
        reset = 1;
        #(CLK_PERIOD);
        reset = 0;
        
        $display("Memory reset completed");
        
        // TEST 2: Write data to a few memory locations
        
        // Write to address [0,0,0]
        write_enable = 1;
        read_enable = 0;
        address = {`_0, `_0, `_0};
        data_in = {`_1_, `_0, `_1_, `_0, `_1_, `_0, `_1_, `_0, `_1_};  // Some pattern: 1,0,1,0,1,0,1,0,1
        
        #(CLK_PERIOD);
        
        $write("Wrote to address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_in);
        $display("");
        
        // Write to address [0,0,1]
        address = {`_0, `_0, `_1_};
        data_in = {`_1, `_1, `_1, `_1, `_1, `_1, `_1, `_1, `_1};  // All -1s
        
        #(CLK_PERIOD);
        
        $write("Wrote to address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_in);
        $display("");
        
        // Write to address [0,0,-1]
        address = {`_0, `_0, `_1};
        data_in = {`_0, `_0, `_0, `_0, `_0, `_0, `_0, `_0, `_0};  // All 0s
        
        #(CLK_PERIOD);
        
        $write("Wrote to address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_in);
        $display("");
        
        // Write to a negative address [-1,-1,-1]
        address = {`_1, `_1, `_1};
        data_in = {`_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_};  // All 1s
        
        #(CLK_PERIOD);
        
        $write("Wrote to address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_in);
        $display("");
        
        write_enable = 0;
        
        // TEST 3: Read data from memory locations
        
        // Read from address [0,0,0]
        read_enable = 1;
        address = {`_0, `_0, `_0};
        
        #(CLK_PERIOD);
        
        $write("Read from address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_out);
        $display("");
        
        // Verify data is what we wrote
        if (data_out == {`_1_, `_0, `_1_, `_0, `_1_, `_0, `_1_, `_0, `_1_})
            $display("PASS: Data matches what was written");
        else
            $display("FAIL: Data doesn't match what was written");
        
        // Read from address [0,0,1]
        address = {`_0, `_0, `_1_};
        
        #(CLK_PERIOD);
        
        $write("Read from address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_out);
        $display("");
        
        // Verify data is what we wrote
        if (data_out == {`_1, `_1, `_1, `_1, `_1, `_1, `_1, `_1, `_1})
            $display("PASS: Data matches what was written");
        else
            $display("FAIL: Data doesn't match what was written");
        
        // Read from address [0,0,-1]
        address = {`_0, `_0, `_1};
        
        #(CLK_PERIOD);
        
        $write("Read from address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_out);
        $display("");
        
        // Verify data is what we wrote
        if (data_out == {`_0, `_0, `_0, `_0, `_0, `_0, `_0, `_0, `_0})
            $display("PASS: Data matches what was written");
        else
            $display("FAIL: Data doesn't match what was written");
        
        // Read from address [-1,-1,-1]
        address = {`_1, `_1, `_1};
        
        #(CLK_PERIOD);
        
        $write("Read from address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_out);
        $display("");
        
        // Verify data is what we wrote
        if (data_out == {`_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_, `_1_})
            $display("PASS: Data matches what was written");
        else
            $display("FAIL: Data doesn't match what was written");
        
        read_enable = 0;
        
        // TEST 4: Test read and write in the same cycle
        write_enable = 1;
        read_enable = 1;
        address = {`_1_, `_1_, `_1_};  // Address [1,1,1]
        data_in = {`_1, `_0, `_1_, `_0, `_1, `_0, `_1_, `_0, `_1};  // Mixed pattern
        
        #(CLK_PERIOD);
        
        $write("Wrote to address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_in);
        $display("");
        
        $write("Simultaneous read from address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_out);
        $display("");
        
        // Special case: When reading and writing to the same address in the same cycle,
        // behavior can vary, so we just observe what happens without verification.
        
        // TEST 5: Test reading after simultaneous read/write
        write_enable = 0;
        read_enable = 1;
        
        #(CLK_PERIOD);
        
        $write("Read after simultaneous read/write from address ");
        display_ternary_address(address);
        $write(" (Decimal: %0d): ", address_to_decimal(address));
        display_ternary_value(data_out);
        $display("");
        
        // Verify data is what we wrote in the previous cycle
        if (data_out == {`_1, `_0, `_1_, `_0, `_1, `_0, `_1_, `_0, `_1})
            $display("PASS: Data matches what was written");
        else
            $display("FAIL: Data doesn't match what was written");
        
        // TEST 6: Test reset operation
        reset = 1;
        read_enable = 1;
        
        #(CLK_PERIOD);
        
        $display("Memory reset completed");
        
        // Read after reset to confirm memory was cleared
        reset = 0;
        read_enable = 1;
        // Read from the last address we wrote to
        
        #(CLK_PERIOD);
        
        $write("Read after reset from address ");
        display_ternary_address(address);
        $write(": ");
        display_ternary_value(data_out);
        $display("");
        
        // Verify data is all zeros after reset
        if (data_out == {`_0, `_0, `_0, `_0, `_0, `_0, `_0, `_0, `_0})
            $display("PASS: Memory is cleared to all zeros after reset");
        else
            $display("FAIL: Memory is not properly cleared after reset");
        
        read_enable = 0;
        
        $display("\n=== TERNARY MEMORY TESTBENCH COMPLETED ===\n");
        
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