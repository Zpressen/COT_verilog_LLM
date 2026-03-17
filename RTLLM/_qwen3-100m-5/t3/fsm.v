module fsm (
    input IN,
    input CLK,
    input RST,
    output MATCH
);

localparam Start = 3'b000;
localparam S1 = 3'b001;
localparam S10 = 3'b010;
localparam S100 = 3'b011;
localparam S1001 = 3'b100;
localparam S10011 = 3'b101;

reg [2:0] state, next_state;

// State flip-flops
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        state <= Start;
    end else begin
        state <= next_state;
    end
end

// Next state logic
always @(*) begin
    next_state = state; // default
    case (state)
        Start: next_state = (IN == 1) ? S1 : Start;
        S1: next_state = (IN == 0) ? S10 : S1;
        S10: next_state = (IN == 0) ? S100 : S1;
        S100: next_state = (IN == 1) ? S1001 : S100;
        S1001: next_state = (IN == 1) ? S10011 : S10;
        S10011: next_state = (IN == 0) ? S10 : S1;
        default: next_state = Start;
    endcase
end

// Output logic
assign MATCH = (state == S1001) && (IN == 1);

endmodule
