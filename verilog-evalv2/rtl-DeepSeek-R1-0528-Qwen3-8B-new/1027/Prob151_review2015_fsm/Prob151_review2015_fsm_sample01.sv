
module TopModule (
    input clk,
    input reset,
    input data,
    input done_counting,
    input ack,
    output shift_ena,
    output counting,
    output done
);

    // State definitions
    typedef enum {IDLE, SHIFT, COUNTING, DONE} state_t;
    state_t state, next_state;

    // FSM always block
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // FSM logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (data == 4'b1101) next_state = SHIFT;
                else next_state = IDLE;
            end
            SHIFT: begin
                next_state = COUNTING;
            end
            COUNTING: begin
                if (done_counting) next_state = DONE;
                else next_state = COUNTING;
            end
            DONE: begin
                if (ack) next_state = IDLE;
                else next_state = DONE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output assignments
    assign shift_ena = (state == SHIFT);
    assign counting = (state == COUNTING);
    assign done = (state == DONE);
endmodule

