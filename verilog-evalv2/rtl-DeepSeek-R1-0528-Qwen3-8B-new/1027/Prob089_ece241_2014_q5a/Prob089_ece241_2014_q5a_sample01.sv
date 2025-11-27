
module TopModule(
    input clk,
    input areset,
    input x,
    output z
);

    // State definitions
    localparam IDLE = 2'b00,
              PROCESS_BIT = 2'b01,
              DONE = 2'b10;

    // State register
    reg [1:0] state, next_state;

    // Output register
    reg [7:0] output_reg;

    // Always block for state transitions
    always @(posedge clk or posedge areset) begin
        if (areset) begin
            state <= IDLE;
            output_reg <= 8'b0;
        end else begin
            state <= next_state;
            if (state == DONE) begin
                z <= output_reg;
            end
        end
    end

    // Combinational logic for next state and output
    always @(*) begin
        case (state)
            IDLE: begin
                if (x) begin
                    next_state = PROCESS_BIT;
                    output_reg <= 1'b1;
                end else begin
                    next_state = IDLE;
                    output_reg <= 8'b0;
                end
            end
            PROCESS_BIT: begin
                next_state = (x) ? PROCESS_BIT : DONE;
                output_reg <= {output_reg[6:0], x};
            end
            DONE: begin
                next_state = IDLE;
                output_reg <= output_reg;
            end
        endcase
    end

endmodule

