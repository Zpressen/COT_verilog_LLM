module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

    // Define states
    parameter IDLE       = 3'b000;
    parameter S1         = 3'b001;
    parameter S10        = 3'b010;
    parameter S100       = 3'b011;
    parameter S1001      = 3'b100;
    parameter MATCH_STATE = 3'b101;

    reg [2:0] current_state, next_state;

    // State transition logic
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            current_state <= IDLE;
            MATCH <= 1'b0;
        end else begin
            current_state <= next_state;
            
            // Mealy output: only set MATCH during transition to MATCH_STATE
            MATCH <= (current_state == S1001 && IN == 1'b1) ? 1'b1 : 1'b0;
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                next_state = (IN == 1'b1) ? S1 : IDLE;
            end
            S1: begin
                next_state = (IN == 1'b0) ? S10 : S1;
            end
            S10: begin
                next_state = (IN == 1'b0) ? S100 : S1;
            end
            S100: begin
                next_state = (IN == 1'b1) ? S1001 : S100;
            end
            S1001: begin
                next_state = (IN == 1'b1) ? MATCH_STATE : S100;
            end
            MATCH_STATE: begin
                next_state = (IN == 1'b1) ? S1 : IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
