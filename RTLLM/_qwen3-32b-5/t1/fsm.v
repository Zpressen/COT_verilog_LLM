module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

typedef enum logic [2:0] {
    S0 = 3'd0,
    S1 = 3'd1,
    S2 = 3'd2,
    S3 = 3'd3,
    S4 = 3'd4,
    S5 = 3'd5
} state_t;

state_t current_state, next_state;
reg mealy_output;

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= S0;
        MATCH <= 1'b0;
    end else begin
        current_state <= next_state;
        MATCH <= mealy_output;
    end
end

always @(*) begin
    next_state = current_state;
    mealy_output = 1'b0;
    case (current_state)
        S0: begin
            if (IN) next_state = S1;
            else next_state = S0;
            mealy_output = 1'b0;
        end
        S1: begin
            if (IN) next_state = S1;
            else next_state = S2;
            mealy_output = 1'b0;
        end
        S2: begin
            if (IN) next_state = S1;
            else next_state = S3;
            mealy_output = 1'b0;
        end
        S3: begin
            if (IN) next_state = S4;
            else next_state = S3;
            mealy_output = 1'b0;
        end
        S4: begin
            if (IN) begin
                next_state = S5;
                mealy_output = 1'b1;
            end else begin
                next_state = S2;
                mealy_output = 1'b0;
            end
        end
        S5: begin
            if (IN) next_state = S1;
            else next_state = S2;
            mealy_output = 1'b0;
        end
        default: begin
            next_state = S0;
            mealy_output = 1'b0;
        end
    endcase
end

endmodule
