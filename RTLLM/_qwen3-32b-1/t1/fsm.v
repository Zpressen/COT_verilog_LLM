module fsm (
    input IN,
    input CLK,
    input RST,
    output MATCH
);

reg [2:0] current_state, next_state;

parameter S0 = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter S4 = 3'd4;
parameter S5 = 3'd5;

// State register
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

// Next state logic
always @(*) begin
    case (current_state)
        S0: next_state = (IN) ? S1 : S0;
        S1: next_state = (IN) ? S1 : S2;
        S2: next_state = (IN) ? S1 : S3;
        S3: next_state = (IN) ? S4 : S3;
        S4: next_state = (IN) ? S5 : S2;
        S5: next_state = (IN) ? S1 : S2;
        default: next_state = S0;
    endcase
end

// Output logic
assign MATCH = (current_state == S4) && IN;

endmodule
