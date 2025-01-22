// program_loader.v
module program_loader (
    input wire clock,
    input wire reset,
    input wire [7:0] data_in,
    input wire [4:0] addr,
    input wire write_enable,
    output reg load_done,
    // Memory interface
    output reg mem_write,
    output reg [4:0] mem_addr,
    output reg [7:0] mem_data
);

    // States for the loader
    localparam IDLE = 1'b0;
    localparam LOADING = 1'b1;
    
    reg state;
    
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            load_done <= 0;
            mem_write <= 0;
            mem_addr <= 0;
            mem_data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (write_enable) begin
                        state <= LOADING;
                        mem_write <= 1;
                        mem_addr <= addr;
                        mem_data <= data_in;
                        load_done <= 0;
                    end else begin
                        mem_write <= 0;
                        load_done <= 1;
                    end
                end
                
                LOADING: begin
                    if (write_enable) begin
                        mem_addr <= addr;
                        mem_data <= data_in;
                    end else begin
                        state <= IDLE;
                        mem_write <= 0;
                    end
                end
            endcase
        end
    end
endmodule