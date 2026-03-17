module fsm (
    input CLK,
    input RST,
    input IN,
    output reg MATCH
);

    // Define states
    localparam [2:0] IDLE       = 3'b000;
    localparam [2:0] S1         = 3'b001;
    localparam [2:0] S10        = 3'b010;
    localparam [2:0] S100       = 3'b011;
    localparam [2:0] S1001      = 3'b100;
    localparam [2:0] MATCH_STATE = 3'b101;

    reg [2:0] current_state, next_state;

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
                if (IN) next_state = S1;
                else next_state = IDLE;
            end
            S1: begin
                MATCH = 1'b0;
                if (!IN) next_state = S10;
                else next_state = S1;
            end
            S10: begin
                MATCH = 1'b0;
                if (!IN) next_state = S100;
                else next_state = S1;
            end
            S100: begin
                MATCH = 1'b0;
                if (IN) next_state = S1001;
                else next_state = IDLE;
            end
            S1001: begin
                if (IN) begin
                    MATCH = 1'b1;
                    next_state = MATCH_STATE;
                end else begin
                    MATCH = 1'b0;
                    next_state = S100;
                end
            end
            MATCH_STATE: begin
                MATCH = 1'b0;
                if (IN) next_state = S1;
                else next_state = S10;
            end
            default: begin
                MATCH = 1'b0;
                next_state = IDLE;
            end
        endcase
    end

endmodule
