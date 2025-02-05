module ram_32x8(
    input wire clock,
    input wire reset,
    input wire write_enable,
    input wire [4:0] address,     // 5 bits for 32 locations
    input wire [15:0] data_in,     // 16-bit data input
    output reg [15:0] data_out     // 16-bit data output
);

    // Memory array: 32 locations of 16 bits each
    reg [15:0] memory [0:31];
    integer i;

    // Reset and write operations
    always @(posedge clock) begin
        if (reset) begin
            // Clear all memory locations on reset
            for (i = 0; i < 32; i = i + 1) begin
                memory[i] <= 16'b0;
            end
            data_out <= 16'b0;
        end else begin
            if (write_enable) begin
                memory[address] <= data_in;
            end
            // Always read the current address (read-during-write returns new data)
            data_out <= memory[address];
        end
    end

endmodule

// // Testbench
// module ram_32x8_tb;
//     reg clock;
//     reg reset;
//     reg write_enable;
//     reg [4:0] address;
//     reg [7:0] data_in;
//     wire [7:0] data_out;

//     // Instantiate the RAM
//     ram_32x8 ram (
//         .clock(clock),
//         .reset(reset),
//         .write_enable(write_enable),
//         .address(address),
//         .data_in(data_in),
//         .data_out(data_out)
//     );

//     // Clock generation
//     initial begin
//         clock = 0;
//         forever #5 clock = ~clock;
//     end

//     // Test sequence
//     initial begin
//         // Initialize
//         reset = 1;
//         write_enable = 0;
//         address = 0;
//         data_in = 0;

//         // Wait a few clock cycles and release reset
//         #20;
//         reset = 0;
        
//         // Write test pattern
//         write_enable = 1;
        
//         // Write to first location
//         address = 5'd0;
//         data_in = 8'hAA;
//         #10;
        
//         // Write to second location
//         address = 5'd1;
//         data_in = 8'h55;
//         #10;
        
//         // Write to last location
//         address = 5'd31;
//         data_in = 8'hFF;
//         #10;
        
//         // Stop writing and read back values
//         write_enable = 0;
        
//         // Read from first location
//         address = 5'd0;
//         #10;
        
//         // Read from second location
//         address = 5'd1;
//         #10;
        
//         // Read from last location
//         address = 5'd31;
//         #10;
        
//         // End simulation
//         #10 $finish;
//     end

//     // Monitor changes
//     initial begin
//         $monitor("Time=%0t reset=%b we=%b addr=%d din=%h dout=%h",
//                  $time, reset, write_enable, address, data_in, data_out);
//     end

// endmodule