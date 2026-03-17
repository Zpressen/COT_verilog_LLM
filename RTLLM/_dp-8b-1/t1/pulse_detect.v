module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

// Define states for pulse detection
localparam IDLE = 2'b00;
localparam GOT_0 = 2'b01;
localparam GOT_1 = 2'b10;
localparam GOT_0_AFTER_1 = 2'b11;

reg [1:0] state, next_state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        data_out <= 1'b0;
    end
    else begin
        state <= next_state;
        
        // Output is high only when we complete the pulse (010 sequence)
        data_out <= (next_state == GOT_0_AFTER_1);
    end
end

always @(*) begin
    case (state)
        IDLE: begin
            if (data_in == 1'b0)
                next_state = GOT_0;
            else
                next_state = IDLE;
        end
        
        GOT_0: begin
            if (data_in == 1'b1)
                next_state = GOT_1;
            else
                next_state = GOT_0; // Stay in GOT_0 if we get another 0
        end
        
        GOT_1: begin
            if (data_in == 1'b0)
                next_state = GOT_0_AFTER_1;
            else
                next_state = IDLE; // If we get another 1, reset (not part of pulse)
        end
        
        GOT_0_AFTER_1: begin
            if (data_in == 1'b0)
                next_state = GOT_0;
            else
                next_state = GOT_1;
        end
        
        default: next_state = IDLE;
    endcase
end

endmodule
