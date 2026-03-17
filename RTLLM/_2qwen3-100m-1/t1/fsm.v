module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

reg [2:0] state, next_state;

parameter IDLE = 3'b000;
parameter S1 = 3'b001;
parameter S10 = 3'b010;
parameter S100 = 3'b011;
parameter S1001 = 3'b100;
parameter S10011 = 3'b101;

// State register
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

// Next state logic
always @(*) begin
    case (state)
        IDLE: next_state = (IN) ? S1 : IDLE;
        S1: next_state = (IN) ? S1 : S10;
        S10: next_state = (IN) ? S1 : S100;
        S100: next_state = (IN) ? S1001 : IDLE;
        S1001: next_state = (IN) ? S10011 : S10;
        S10011: next_state = (IN) ? S1 : S10;
        default: next_state = IDLE;
    endcase
end

// Output logic
always @(*) begin
    if (state == S1001 && IN == 1) begin
        MATCH = 1;
    end else begin
        MATCH = 0;
    end
end

endmodule
