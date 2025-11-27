module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

reg [2:0] current_state, next_state;

parameter S0 = 3'b000,
          S1 = 3'b001,
          S10 = 3'b010,
          S100 = 3'b011,
          S1001 = 3'b100;

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

always @(*) begin
    next_state = current_state;
    MATCH = 0;

    case (current_state)
        S0: begin
            if (IN == 1) next_state = S1;
            else next_state = S0;
        end

        S1: begin
            if (IN == 0) next_state = S10;
            else next_state = S1;
        end

        S10: begin
            if (IN == 0) next_state = S100;
            else next_state = S1;
        end

        S100: begin
            if (IN == 1) next_state = S1001;
            else next_state = S0;
        end

        S1001: begin
            if (IN == 1) begin
                next_state = S1;
                MATCH = 1;
            end else begin
                next_state = S10;
            end
        end

        default: next_state = S0;
    endcase
end

endmodule
