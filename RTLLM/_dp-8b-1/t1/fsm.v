module fsm (
    input wire IN,
    input wire CLK,
    input wire RST,
    output reg MATCH
);

// Define states
typedef enum {
    IDLE,
    S1,     // Received 1
    S10,    // Received 10
    S100,   // Received 100
    S1001,  // Received 1001
    S10011  // Received 10011 (match state)
} state_t;

// State registers
state_t current_state, next_state;

// State transition logic
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= IDLE;
    end else begin
        current_state <= next_state;
    end
end

// Next state and output logic
always @(*) begin
    case (current_state)
        IDLE: begin
            MATCH = 1'b0;
            if (IN == 1'b1)
                next_state = S1;
            else
                next_state = IDLE;
        end
        
        S1: begin
            MATCH = 1'b0;
            if (IN == 1'b0)
                next_state = S10;
            else
                next_state = S1;  // Stay in S1 if we get another 1
        end
        
        S10: begin
            MATCH = 1'b0;
            if (IN == 1'b0)
                next_state = S100;
            else
                next_state = S1;  // Got 1 after 10, restart from S1
        end
        
        S100: begin
            MATCH = 1'b0;
            if (IN == 1'b1)
                next_state = S1001;
            else
                next_state = IDLE; // Got 0 after 100, reset to IDLE
        end
        
        S1001: begin
            MATCH = 1'b0;
            if (IN == 1'b1)
                next_state = S10011;
            else
                next_state = S10; // Got 0 after 1001, transition to S10 (already have 10)
        end
        
        S10011: begin
            MATCH = 1'b1;
            if (IN == 1'b1)
                next_state = S1;  // Start new sequence with this 1
            else
                next_state = S10; // Start new sequence with 10
        end
        
        default: begin
            MATCH = 1'b0;
            next_state = IDLE;
        end
    endcase
end

endmodule
