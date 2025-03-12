module control(clock, execute, reset,
    opcode, is_alu_operation,
    do_fetch, do_reg_load, do_alu, do_mem_load, do_mem_store, do_reg_store, do_next, do_reset, do_halt,
    state);

    /* 
    Control Module for the CPU

    Does not need to take any signals from a Bus as this system does not have any I/O devices

    Execute in a high state allows the CPU to perform cycles
    Reset in a high state resets the CPU to the initial state
    */

    `include "parameters.vh"

    input wire clock;

    input wire [OPCODE_SIZE-1:0] opcode;
    input wire is_alu_operation;
    input wire execute, reset;

    output wire do_fetch, do_reg_load, do_alu, do_mem_load, do_mem_store, do_reg_store, do_next, do_reset, do_halt;

    output reg [3:0] state = `STATE_INSMEM_LOAD;
    reg [3:0] next_state;

    reg halt_latch = 1'b0;

    always @(posedge clock or posedge reset) begin
        // $display("State: %d, Opcode: %d", state, opcode);
        if (reset) begin
            state <= `STATE_RESET;
            halt_latch <= 1'b0;
        end
        else if (execute) begin
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
                        default: begin
                            $display("Invalid opcode: %d", opcode);
                            $display("Halting CPU");
                            halt_latch <= 1'b1;
                            state <= `STATE_HALT;
                        end
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

                // explicit declaration of halt state
                `STATE_HALT: begin
                    state <= `STATE_HALT;
                    halt_latch <= 1'b1;
                end
            endcase
        end
    end

    // Control signals are active only when execute is high and not halted
    assign do_fetch = (state == `STATE_FETCH) && execute && !halt_latch;
    assign do_reg_load = (state == `STATE_REGLOAD) && execute && !halt_latch;
    assign do_alu = (state == `STATE_ALU) && execute && !halt_latch;
    assign do_mem_load = (state == `STATE_LOAD) && execute && !halt_latch;
    assign do_mem_store = (state == `STATE_STORE) && execute && !halt_latch;
    assign do_reg_store = (state == `STATE_REGSTORE) && execute && !halt_latch;
    assign do_next = (state == `STATE_NEXT) && execute && !halt_latch;
    assign do_reset = (state == `STATE_RESET) || reset;
    assign do_halt = halt_latch || (state == `STATE_HALT);

endmodule