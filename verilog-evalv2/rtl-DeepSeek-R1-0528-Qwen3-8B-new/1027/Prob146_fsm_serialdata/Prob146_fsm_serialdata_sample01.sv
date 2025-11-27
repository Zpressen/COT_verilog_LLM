
module TopModule(
    input clk,
    input in,
    input reset,
    output [7:0] out_byte,
    output done
);

    // FSM states
    typedef enum {IDLE, DATA_0, DATA_1, DATA_2, DATA_3, DATA_4, DATA_5, DATA_6, DATA_7, STOP, DONE} state_t;
    state_t state, next_state;

    // Data storage
    reg [7:0] data_reg;
    reg [7:0] out_byte_reg;

    // FSM logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            data_reg <= 8'b0;
            out_byte_reg <= 8'b0;
        end else begin
            state <= next_state;
            if (state == DONE) begin
                out_byte_reg <= data_reg;
            end
        end
    end

    // FSM transition logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (in == 1'b0) next_state = DATA_0;
                else next_state = IDLE;
            end
            DATA_0: next_state = DATA_1;
            DATA_1: next_state = DATA_2;
            DATA_2: next_state = DATA_3;
            DATA_3: next_state = DATA_4;
            DATA_4: next_state = DATA_5;
            DATA_5: next_state = DATA_6;
            DATA_6: next_state = DATA_7;
            DATA_7: next_state = STOP;
            STOP: begin
                if (in == 1'b1) next_state = DONE;
                else next_state = STOP;
            end
            DONE: next_state = IDLE;
        endcase
    end

    // Output assignments
    assign out_byte = out_byte_reg;
    assign done = (state == DONE);

endmodule

