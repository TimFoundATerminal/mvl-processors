`timescale 1ns/1ps

module testbench;
    // Test signals
    reg [1:0] a, b;
    wire [1:0] min_out;
    wire [1:0] sum_out;
    wire [1:0] cout;
    
    // Instantiate top level
    top_level uut (
        .input_a(a),
        .input_b(b),
        .min_result(min_out),
        .sum_result(sum_out),
        .carry_out(cout)
    );
    
    // Test stimulus
    initial begin
        // Create waveform file
        $dumpfile("ternary_test.vcd");
        $dumpvars(0, testbench);
        
        // Test cases
        $display("Starting simulation...");
        $display("Time\tA\tB\tMIN\tSUM\tCOUT");
        $display("----------------------------------------");
        
        // Test case 1: False and False
        a = 2'b00; b = 2'b00;
        #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, a, b, min_out, sum_out, cout);
        
        // Test case 2: True and True
        a = 2'b01; b = 2'b10;
        #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, a, b, min_out, sum_out, cout);
        
        // Test case 3: Unknown and True
        a = 2'b01; b = 2'b00;
        #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, a, b, min_out, sum_out, cout);
        
        // Test case 4: True and True
        a = 2'b01; b = 2'b01;
        #10;
        $display("%0t\t%b\t%b\t%b\t%b\t%b", $time, a, b, min_out, sum_out, cout);

        $display("----------------------------------------");
        $display("Simulation complete!");
        $finish;
    end
endmodule
