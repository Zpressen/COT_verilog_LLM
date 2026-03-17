
module TopModule(
    input clk,
    input reset,
    input w,
    output z
);

    // State encoding: A=000, B=001, C=010, D=011, E=100, F=101
    typedef enum {A, B, C, D, E, F} state_t;
    state_t current_state, next_state;

    // Output logic
    assign z = (current_state == E) ? 1'b1 : 1'b0;

    // State transition logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= A;
        end else begin
            case (current_state)
                A: next_state = (w == 1'b0) ? B : A;
                B: next_state = (w == 1'b0) ? C : D;
                C: next_state = (w == 1'b0) ? E : D;
                D: next_state = (w == 1'b0) ? F : A;
                E: next_state = (w == 1'b0) ? E : D;
                F: next_state = (w == 1'b0) ? C : D;
                default: next_state = A;
            endcase
            current_state <= next_state;
        end
    end
endmodule

