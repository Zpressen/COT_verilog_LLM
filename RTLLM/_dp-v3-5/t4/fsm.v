module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

// State encoding
parameter IDLE      = 3'b000;
parameter S1        = 3'b001;
parameter S10       = 3'b010;
parameter S100      = 3'b011;
parameter S1001     = 3'b100;
parameter MATCH_STATE = 3'b101;

reg [2:0] current_state, next_state;

// State transition logic
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// Next state logic
always @(*) begin
    case (current_state)
        IDLE: next_state = IN ? S1 : IDLE;
        S1: next_state = IN ? S1 : S10;
        S10: next_state = IN ? S1 : S100;
        S100: next_state = IN ? S1001 : IDLE;
        S1001: begin
            if (IN) 
                next_state = MATCH_STATE;
            else 
                next_state = IDLE;
        end
        MATCH_STATE: next_state = IN ? S1 : S10;
        default: next_state = IDLE;
    endcase
end

// Output logic (Mealy)
always @(*) begin
    case (current_state)
        S1001: MATCH = IN ? 1'b1 : 1'b0;
        MATCH_STATE: MATCH = 1'b0;
        default: MATCH = 1'b0;
    endcase
end

endmodule
