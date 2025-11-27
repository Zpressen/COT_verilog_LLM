module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

reg [2:0] state, next_state;

localparam S0 = 3'b000;
localparam S1 = 3'b001;
localparam S2 = 3'b010;
localparam S3 = 3'b011;
localparam S4 = 3'b100;
localparam S5 = 3'b101;

always @(posedge CLK or posedge RST) begin
    if (RST)
        state <= S0;
    else
        state <= next_state;
end

always @(*) begin
    case (state)
        S0: next_state = (IN) ? S1 : S0;
        S1: next_state = (IN) ? S1 : S2;
        S2: next_state = (IN) ? S1 : S3;
        S3: next_state = (IN) ? S4 : S3;
        S4: next_state = (IN) ? S5 : S2;
        S5: next_state = (IN) ? S1 : S2;
        default: next_state = S0;
    endcase
end

assign MATCH = (state == S4) && IN;

endmodule
