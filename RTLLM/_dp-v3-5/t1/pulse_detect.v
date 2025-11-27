module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

    // Define states
    localparam [1:0] IDLE  = 2'b00;
    localparam [1:0] GOT_0 = 2'b01;
    localparam [1:0] GOT_1 = 2'b10;

    reg [1:0] state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            data_out <= 0;
        end else begin
            state <= next_state;
            // Output is 1 only when we complete a pulse (0->1->0)
            data_out <= (state == GOT_1) && !data_in;
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                next_state = data_in ? IDLE : GOT_0;
            end
            GOT_0: begin
                next_state = data_in ? GOT_1 : GOT_0;
            end
            GOT_1: begin
                next_state = data_in ? IDLE : GOT_0;
            end
            default: next_state = IDLE;
        endcase
    end

endmodule
