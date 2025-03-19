`timescale 1ns / 1ps

module ternary_alu_tb();

    // Include parameters file
    `include "parameters.vh"
    
    // Define ternary encodings for readability in the testbench
    `define _1  2'b11 // -1
    `define _0  2'b00 // 0
    `define _1_ 2'b01 // 1
    
    // Opcodes (3 trits) - represented as 6 bits
    `define MV    6'b000000 // 0
    `define NOT   6'b000011 // 2
    `define AND   6'b000101 // 4
    `define OR    6'b000111 // 5
    `define XOR   6'b001100 // 6
    `define ADD   6'b001101 // 7
    `define SUB   6'b001111 // 8
    `define COMP  6'b010011 // 11
    `define ANDI  6'b010100 // 12
    `define ADDI  6'b010101 // 13
    `define SRI   6'b010111 // 14
    `define SLI   6'b011100 // 15
    
    // Define local parameters for testing
    localparam TB_WORD_SIZE = 4; // Use a smaller word size for testing
    localparam CLK_PERIOD = 10;  // Clock period in ns
    
    // Define signals for the DUT (Device Under Test)
    reg clock;
    reg alu_enable;
    reg [5:0] opcode;
    reg [2*TB_WORD_SIZE-1:0] input1, input2;
    wire [2*TB_WORD_SIZE-1:0] alu_out;
    
    // Instantiate the ternary ALU
    ternary_alu #(.WORD_SIZE(TB_WORD_SIZE)) dut (
        .clock(clock),
        .opcode(opcode),
        .input1(input1),
        .input2(input2),
        .alu_enable(alu_enable),
        .alu_out(alu_out)
    );
    
    // Generate clock
    always begin
        #(CLK_PERIOD/2) clock = ~clock;
    end
    
    // Helper tasks and functions
    
    // Display a ternary value
    task display_ternary;
        input [2*TB_WORD_SIZE-1:0] ternary_val;
        reg [1:0] trit;
        integer i;
        begin
            $write("[");
            for (i = TB_WORD_SIZE-1; i >= 0; i = i - 1) begin
                // Manual bit selection to avoid variable part select
                case(i)
                    0: trit = ternary_val[1:0];
                    1: trit = ternary_val[3:2];
                    2: trit = ternary_val[5:4];
                    3: trit = ternary_val[7:6];
                    // Add more cases if TB_WORD_SIZE > 4
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
    
    // Display opcode name
    task display_opcode;
        input [5:0] op;
        begin
            case(op)
                `MV:    $write("MV");
                `NOT:   $write("NOT");
                `AND:   $write("AND");
                `OR:    $write("OR");
                `XOR:   $write("XOR");
                `ADD:   $write("ADD");
                `SUB:   $write("SUB");
                `COMP:  $write("COMP");
                `ANDI:  $write("ANDI");
                `ADDI:  $write("ADDI");
                `SRI:   $write("SRI");
                `SLI:   $write("SLI");
                default: $write("UNKNOWN");
            endcase
        end
    endtask
    
    // Task to run a test case
    task run_test;
        input [5:0] test_opcode;
        input [2*TB_WORD_SIZE-1:0] test_input1;
        input [2*TB_WORD_SIZE-1:0] test_input2;
        input [2*TB_WORD_SIZE-1:0] expected_out;
        begin
            opcode = test_opcode;
            input1 = test_input1;
            input2 = test_input2;
            alu_enable = 1;
            
            // Wait for next clock cycle
            @(posedge clock);
            #1; // Small delay to allow outputs to stabilize
            
            // Check results
            if (alu_out === expected_out) begin
                $write("PASS: ");
                display_opcode(test_opcode);
                $write(" - Input1: ");
                display_ternary(test_input1);
                $write(", Input2: ");
                display_ternary(test_input2);
                $write(", Output: ");
                display_ternary(alu_out);
                $display("");
            end else begin
                $write("FAIL: ");
                display_opcode(test_opcode);
                $write(" - Input1: ");
                display_ternary(test_input1);
                $write(", Input2: ");
                display_ternary(test_input2);
                $display("");
                $write("  Expected: ");
                display_ternary(expected_out);
                $write(", Got: ");
                display_ternary(alu_out);
                $display("");
            end
            
            // Disable ALU
            alu_enable = 0;
            #(CLK_PERIOD);
        end
    endtask
    
    // Test vectors
    // Each test vector contains: {opcode, input1, input2, expected output}
    reg [6:0] test_cases;
    
    // Main test procedure
    initial begin
        // Initialize signals
        clock = 0;
        alu_enable = 0;
        opcode = `MV;
        input1 = 0;
        input2 = 0;
        
        // Wait for a few clock cycles to ensure stable state
        #(3*CLK_PERIOD);
        
        $display("\n=== TERNARY ALU TESTBENCH STARTED ===\n");
        
        // TEST 1: NOT Operation
        // Test NOT on various values
        run_test(`NOT, 
                {`_1, `_0, `_1_, `_0}, // Input1 = [-1,0,1,0]
                {`_0, `_0, `_0, `_0},  // Input2 (unused for NOT)
                {`_1_, `_0, `_1, `_0}); // Expected: [1,0,-1,0]
                
        // TEST 2: AND Operation
        // Test AND between two values
        run_test(`AND, 
                {`_1_, `_1, `_0, `_1_}, // Input1 = [1,-1,0,1]
                {`_1, `_1_, `_0, `_1_}, // Input2 = [-1,1,0,1]
                {`_1, `_1, `_0, `_1_}); // Expected: [-1,0,0,1]
                
        // TEST 3: OR Operation
        run_test(`OR, 
                {`_1_, `_1, `_0, `_1_}, // Input1 = [1,-1,0,1]
                {`_1, `_1_, `_0, `_1_}, // Input2 = [-1,1,0,1]
                {`_1_, `_1_, `_0, `_1_}); // Expected: [1,1,0,1]
                
        // TEST 4: XOR Operation
        run_test(`XOR, 
                {`_1_, `_1, `_0, `_1_}, // Input1 = [1,-1,0,1]
                {`_1, `_1_, `_0, `_1_}, // Input2 = [-1,1,0,1]
                {`_0, `_0, `_0, `_1}); // Expected: [0,0,0,-1]
                
        // TEST 5: ADD Operation
        run_test(`ADD, 
                {`_1_, `_1, `_0, `_1_}, // Input1 = [1,-1,0,1]
                {`_1, `_1_, `_0, `_1_}, // Input2 = [-1,1,0,1]
                {`_0, `_0, `_1_, `_1}); // Expected: [0,0,1,-1]
                
        // // TEST 6: SUB Operation
        // run_test(`SUB, 
        //         {`_1_, `_1, `_0, `_1_}, // Input1 = [1,-1,0,1]
        //         {`_1_, `_1, `_0, `_1}, // Input2 = [1,-1,0,-1]
        //         {`_0, `_0, `_1_, `_1}); // Expected: [0,0,1,-1]
                
        // TEST 7: COMP Operation (Equal)
        run_test(`COMP, 
                {`_1_, `_1_, `_0, `_1_}, // Input1 = [1,1,0,1]
                {`_1_, `_1_, `_0, `_1_}, // Input2 = [1,1,0,1]
                {`_0, `_0, `_0, `_1_}); // Expected: [0,0,0,1] (1 for equal)
                
        // TEST 8: COMP Operation (Not Equal)
        run_test(`COMP, 
                {`_1_, `_1_, `_0, `_1_}, // Input1 = [1,1,0,1]
                {`_1_, `_1_, `_0, `_1}, // Input2 = [1,1,0,-1]
                {`_0, `_0, `_0, `_0}); // Expected: [0,0,0,0] (0 for not equal)
                
        // TEST 9: SRI Operation (Shift Right)
        run_test(`SRI, 
                {`_1_, `_1, `_0, `_1_}, // Input1 = [1,-1,0,1]
                {`_0, `_0, `_0, `_1_}, // Input2 = [0,0,0,1] (shift by 1)
                {`_0, `_1_, `_1, `_0}); // Expected: [0,1,-1,0]
                
        // TEST 10: SLI Operation (Shift Left)
        run_test(`SLI, 
                {`_1_, `_1, `_0, `_1_}, // Input1 = [1,-1,0,1]
                {`_0, `_0, `_0, `_1_}, // Input2 = [0,0,0,1] (shift by 1)
                {`_1, `_0, `_1_, `_0}); // Expected: [-1,0,1,0]
                
        // TEST 11: ANDI (Same as AND)
        run_test(`ANDI, 
                {`_1_, `_1, `_0, `_1_}, // Input1 = [1,-1,0,1]
                {`_1, `_1_, `_0, `_1_}, // Input2 = [-1,1,0,1]
                {`_1, `_1, `_0, `_1_}); // Expected: [-1,0,0,1]
                
        // TEST 12: ADDI (Same as ADD)
        run_test(`ADDI, 
                {`_1_, `_1, `_0, `_1_}, // Input1 = [1,-1,0,1]
                {`_1, `_1_, `_0, `_1_}, // Input2 = [-1,1,0,1]
                {`_0, `_0, `_1_, `_1}); // Expected: [0,0,0,0]
                
        // // Additional Tests: More complex additions with carries
        // run_test(`ADD, 
        //         {`_1_, `_1_, `_1_, `_1_}, // Input1 = [1,1,1,1]
        //         {`_1_, `_1_, `_1_, `_1_}, // Input2 = [1,1,1,1]
        //         {`_1, `_1, `_1, `_0}); // Expected: [-1,-1,-1,0]
        
        // // Complex subtraction
        // run_test(`SUB, 
        //         {`_1_, `_1_, `_1_, `_1_}, // Input1 = [1,1,1,1]
        //         {`_1, `_1, `_1, `_1}, // Input2 = [-1,-1,-1,-1]
        //         {`_0, `_0, `_0, `_0}); // Expected: [0,0,0,0]
                
        // Larger shift amount
        run_test(`SRI, 
                {`_1_, `_1, `_0, `_1_}, // Input1 = [1,-1,0,1]
                {`_0, `_0, `_1_, `_0}, // Input2 = [0,0,1,0] (shift by 3 in ternary) 
                {`_0, `_0, `_0, `_1_}); // Expected: [0,0,0,1]
                
        $display("\n=== TERNARY ALU TESTBENCH COMPLETED ===\n");
        
        // End simulation
        #(5*CLK_PERIOD);
        $finish;
    end

    // Add a timeout in case of infinite loops
        // Add a timeout to prevent infinite loops
    initial begin
        #(1000*CLK_PERIOD);  // Timeout after 1000 clock cycles
        $display("ERROR: Testbench timeout reached. Simulation forcibly terminated.");
        $finish;
    end

endmodule