
module TopModule(
    input clk,
    input areset,
    input x,
    output z
);

    parameter NUM_STATES = 2;
    parameter STATE_A = 2'b00;
    parameter STATE_B = 2'b01;

    reg [NUM_STATES-1:0] state, next_state;
    reg z;

    always @(posedge clk or posedge areset) begin
        if (areset) begin
            state <= STATE_A;
            z <= 1'b0;
        end else begin
            state <= next_state;
            z <= (state == STATE_A && x) ? 1'b1 :
                 (state == STATE_B && ~x) ? 1'b0 : 1'b1;
        end
    end

    always @(*) begin
        case (state)
            STATE_A: next_state <= (x) ? STATE_B : STATE_A;
            STATE_B: next_state <= STATE_B;
            default: next_state <= STATE_A;
        endcase
    end

endmodule

