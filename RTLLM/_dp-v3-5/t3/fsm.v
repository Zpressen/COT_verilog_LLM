module fsm (
    input CLK,
    input RST,
    input IN,
    output reg MATCH
);

// Define states
parameter IDLE = 2'b00;
parameter S1   = 2'b01;
parameter S10  = 2'b10;
parameter S100 = 2'b11;
parameter S1001 = 3'b100; // Extra bit needed for 5 states

reg [2:0] current_state, next_state;

// State transition logic
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= IDLE;
        MATCH <= 0;
    end else begin
        current_state <= next_state;
        // Mealy output depends on current state and input
        MATCH <= (current_state == S1001) && (IN == 1'b1);
    end
end

// Next state logic
always @(*) begin
    case (current_state)
        IDLE: begin
            if (IN == 1'b1)
                next_state = S1;
            else
                next_state = IDLE;
        end
        S1: begin
            if (IN == 1'b0)
                next_state = S10;
            else
                next_state = S1; // Stay if another '1' comes
        end
        S10: begin
            if (IN == 1'b0)
                next_state = S100;
            else
                next_state = S1;
        end
        S100: begin
            if (IN == 1'b1)
                next_state = S1001;
            else
                next_state = IDLE;
        end
        S1001: begin
            if (IN == 1'b1)
                next_state = S1; // Restart detection for continuous input
            else
                next_state = S10; // Partial match "1001" + '0' -> "10010", continue from S10
        end
        default: next_state = IDLE;
    endcase
end

endmodule
