`include "ternary_defs.v"
`timescale 1ns/100ps

module ternary_full_adder_tb;
    // Test signals
    analog reg a, b, cin;
    analog wire sum, cout;
    
    // Instantiate the full adder
    ternary_full_adder uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    initial begin
        $monitor("Time=%0t a=%v b=%v cin=%v sum=%v cout=%v",
                 $time, V(a), V(b), V(cin), V(sum), V(cout));
        
        // Test case 1: +1 + +1 + 0
        a = `VPOS; b = `VPOS; cin = `VZERO;
        #10;
        
        // Test case 2: +1 + -1 + 0
        a = `VPOS; b = `VNEG; cin = `VZERO;
        #10;
        
        // Test case 3: +1 + +1 + +1
        a = `VPOS; b = `VPOS; cin = `VPOS;
        #10;
        
        // Test case 4: -1 + -1 + -1
        a = `VNEG; b = `VNEG; cin = `VNEG;
        #10;
        
        // Test case 5: 0 + 0 + 0
        a = `VZERO; b = `VZERO; cin = `VZERO;
        #10;
        
        $finish;
    end
endmodule