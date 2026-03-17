module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

reg [2:0] current_state, next_state;

parameter S0 = 3'd0,
          S1 = 3'd1,
          S2 = 3'd2,
          S3 = 3'd3,
          S4 = 3'd4;

// State flip-flops
always @(posedge CLK or posedge RST) begin
    if (RST)
        current_state <= S0;
    else
        current_state <= next_state;
end

// Next state logic
always @(*) begin
    next_state = current_state; // default
    case (current_state)
        S0: begin
            if (IN == 1)
                next_state = S1;
            else
                next_state = S0;
        end
        S1: begin
            if (IN == 0)
                next_state = S2;
            else
                next_state = S1;
        end
        S2: begin
            if (IN == 0)
                next_state = S3;
            else
                next_state = S1;
        end
        S3: begin
            if (IN == 1)
                next_state = S4;
            else
                next_state = S0;
        end
        S4: begin
            if (IN == 1)
                next_state = S1;
            else
                next_state = S2;
        end
        default: next_state = S0;
    endcase
end

// Output logic
always @(*) begin
    MATCH = 1'b0;
    if (current_state == S4 && IN == 1'b1)
        MATCH = 1'b1;
end

endmodule
