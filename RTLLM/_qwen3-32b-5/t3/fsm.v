module fsm(
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

reg [2:0] current_state, next_state;

parameter S0 = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter S4 = 3'd4;
parameter S5 = 3'd5;

// State flip-flops
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

// Next state and output logic
always @(*) begin
    next_state = current_state; // default
    MATCH = 1'b0; // default

    case (current_state)
        S0: begin
            if (IN) begin
                next_state = S1;
            end else begin
                next_state = S0;
            end
        end
        S1: begin
            if (~IN) begin
                next_state = S2;
            end else begin
                next_state = S1;
            end
        end
        S2: begin
            if (~IN) begin
                next_state = S3;
            end else begin
                next_state = S1;
            end
        end
        S3: begin
            if (IN) begin
                next_state = S4;
            end else begin
                next_state = S0;
            end
        end
        S4: begin
            if (~IN) begin
                next_state = S2;
            end else begin
                next_state = S5;
                MATCH = 1'b1;
            end
        end
        S5: begin
            if (~IN) begin
                next_state = S2;
            end else begin
                next_state = S1;
            end
        end
        default: begin
            next_state = S0;
        end
    endcase
end

endmodule
