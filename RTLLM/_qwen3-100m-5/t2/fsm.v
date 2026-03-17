module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

reg [2:0] current_state, next_state;

parameter S0 = 3'b000;
parameter S1 = 3'b001;
parameter S2 = 3'b010;
parameter S3 = 3'b011;
parameter S4 = 3'b100;
parameter S5 = 3'b101;

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

always @(*) begin
    case (current_state)
        S0: begin
            if (IN) next_state = S1;
            else next_state = S0;
        end
        S1: begin
            if (IN == 0) next_state = S2;
            else next_state = S1;
        end
        S2: begin
            if (IN == 0) next_state = S3;
            else next_state = S1;
        end
        S3: begin
            if (IN) next_state = S4;
            else next_state = S0;
        end
        S4: begin
            if (IN) next_state = S5;
            else next_state = S0;
        end
        S5: begin
            if (IN) next_state = S1;
            else next_state = S2;
        end
        default: next_state = S0;
    endcase
end

assign MATCH = (current_state == S4 && IN) ? 1 : 0;

endmodule
