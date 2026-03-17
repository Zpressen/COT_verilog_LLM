module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

    // State encoding
    localparam IDLE   = 2'b00;
    localparam SAW_0  = 2'b01;
    localparam SAW_01 = 2'b10;

    reg [1:0] state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= IDLE;
            data_out <= 1'b0;
        end else begin
            state <= next_state;
            // Output is high only when we complete the sequence
            data_out <= (state == SAW_01) && (data_in == 1'b0);
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                next_state = data_in ? IDLE : SAW_0;
            end
            SAW_0: begin
                next_state = data_in ? SAW_01 : SAW_0;
            end
            SAW_01: begin
                next_state = data_in ? IDLE : IDLE;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule
