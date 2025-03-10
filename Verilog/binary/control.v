module control(clock,
    opcode, is_alu_operation,
    fetch_, reg_load_, alu_, mem_load_, mem_store_, reg_store_, next_, reset_, halt_,
    state);

    /* 
    Control Module for the CPU

    Does not need to take any signals from a Bus as this system does not have any I/O devices
    */

    `include "parameters.vh"

    input wire clock;

    input wire [OPCODE_SIZE-1:0] opcode;
    input wire is_alu_operation;

    output wire fetch_, reg_load_, alu_, mem_load_, mem_store_, reg_store_, next_, reset_, halt_;

    output reg [3:0] state = `STATE_INSMEM_LOAD;

    always @(posedge clock) begin
        $display("State: %d, Opcode: %d", state, opcode);

        case (state)
            `STATE_RESET: begin
                state <= `STATE_FETCH;
            end

            `STATE_FETCH: begin
                state <= `STATE_REGLOAD;
            end

            `STATE_REGLOAD: begin
                if (is_alu_operation) 
                    state <= `STATE_ALU;
                else case (opcode)
                    // TODO MV operation
                    `LOAD:
                        state <= `STATE_LOAD;
                    `STORE:
                        state <= `STATE_STORE;
                    `LUI:
                        state <= `STATE_REGSTORE;
                    `LI:
                        state <= `STATE_REGSTORE;
                    `BEQ:
                        state <= `STATE_NEXT;
                    `BNE:
                        state <= `STATE_NEXT;
                    `HALT:
                        state <= `STATE_HALT;
                endcase
            end

            `STATE_ALU: begin
                state <= `STATE_REGSTORE;
            end

            `STATE_REGSTORE: begin
                state <= `STATE_NEXT;
            end

            `STATE_LOAD: begin
                state <= `STATE_REGSTORE;
            end

            `STATE_STORE: begin
                state <= `STATE_NEXT;
            end

            `STATE_NEXT: begin
                state <= `STATE_FETCH;
            end

        endcase
    end

    // Control the CPU with the following signals
    assign fetch_ = (state == `STATE_FETCH);
    assign reg_load_ = (state == `STATE_REGLOAD);
    assign alu_ = (state == `STATE_ALU);
    assign mem_load_ = (state == `STATE_LOAD);
    assign mem_store_ = (state == `STATE_STORE);
    assign reg_store_ = (state == `STATE_REGSTORE);
    assign next_ = (state == `STATE_NEXT);
    assign reset_ = (state == `STATE_RESET);
    assign halt_ = (state == `STATE_HALT);

endmodule