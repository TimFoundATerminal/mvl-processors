module alu(clock, opcode, input1, input2, alu_enable, alu_out);

    `include "parameters.vh"

    input wire clock, alu_enable;
    input wire [4:0] opcode;
    input wire [WORD_SIZE-1:0] input1, input2;
    output reg [WORD_SIZE-1:0] alu_out;

    always @(posedge clock) begin
        if (alu_enable) begin
            case (opcode)
                `NOT: begin
                    alu_out <= ~input1;
                end
                `AND, `ANDI: begin
                    alu_out <= input1 & input2;
                end
                `OR: begin
                    alu_out <= input1 | input2;
                end
                `XOR: begin
                    alu_out <= input1 ^ input2;
                end
                `ADD, `ADDI: begin
                    alu_out <= input1 + input2;
                end
                `SUB: begin
                    alu_out <= input1 - input2;
                end
                `COMP: begin
                    alu_out <= (input1 == input2);
                end
                `SRI: begin
                    alu_out <= input1 >> input2;
                end
                `SLI: begin
                    alu_out <= input1 << input2;
                end
                // All the immediate instructions can use the same circuitry as the memory instructions
            endcase
        end
    end

endmodule