module fsm (
    input CLK,
    input RST,
    input IN,
    output reg MATCH
);

    // Define states
    parameter IDLE = 3'b000;
    parameter S1   = 3'b001; // 1
    parameter S2   = 3'b010; // 10
    parameter S3   = 3'b011; // 100
    parameter S4   = 3'b100; // 1001

    reg [2:0] current_state, next_state;

    // State transition logic
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            current_state <= IDLE;
            MATCH <= 1'b0;
        end
        else begin
            current_state <= next_state;
            // Mealy output depends on current state and input
            MATCH <= (current_state == S4) && (IN == 1'b1);
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: next_state = (IN == 1'b1) ? S1 : IDLE;
            S1:   next_state = (IN == 1'b0) ? S2 : S1;
            S2:   next_state = (IN == 1'b0) ? S3 : S1;
            S3:   next_state = (IN == 1'b1) ? S4 : IDLE;
            S4:   next_state = (IN == 1'b1) ? S1 : S2;
            default: next_state = IDLE;
        endcase
    end

endmodule
