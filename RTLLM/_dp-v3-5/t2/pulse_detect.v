module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

    // Define states
    localparam IDLE  = 2'b00;
    localparam GOT_0 = 2'b01;
    localparam GOT_1 = 2'b10;

    // State register
    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            data_out <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    data_out <= 1'b0;
                    if (data_in == 1'b0)
                        state <= GOT_0;
                end
                
                GOT_0: begin
                    data_out <= 1'b0;
                    if (data_in == 1'b1)
                        state <= GOT_1;
                    else if (data_in == 1'b0)
                        state <= GOT_0;
                    else
                        state <= IDLE;
                end
                
                GOT_1: begin
                    if (data_in == 1'b0) begin
                        data_out <= 1'b1;
                        state <= IDLE;
                    end
                    else begin
                        data_out <= 1'b0;
                        state <= IDLE;
                    end
                end
                
                default: begin
                    state <= IDLE;
                    data_out <= 1'b0;
                end
            endcase
        end
    end

endmodule
