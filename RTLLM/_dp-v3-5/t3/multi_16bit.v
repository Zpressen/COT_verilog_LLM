module multi_16bit (
    input clk,
    input rst_n,
    input start,
    input [15:0] ain,
    input [15:0] bin,
    output reg [31:0] yout,
    output done
);

    reg [4:0] i;          // shift counter (0-17)
    reg [15:0] areg;       // multiplicand register
    reg [15:0] breg;       // multiplier register
    reg [31:0] yout_r;     // product register
    reg done_r;           // done flag register

    // Assign output
    assign done = done_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition
            i <= 5'd0;
            areg <= 16'd0;
            breg <= 16'd0;
            yout_r <= 32'd0;
            done_r <= 1'b0;
        end
        else begin
            if (start) begin
                if (i == 5'd0) begin
                    // Initial state - load operands
                    areg <= ain;
                    breg <= bin;
                    yout_r <= 32'd0;
                    i <= i + 1;
                    done_r <= 1'b0;
                end
                else if (i <= 5'd16) begin
                    // Shift and accumulate phase
                    if (areg[i-1]) begin
                        yout_r <= yout_r + (breg << (i-1));
                    end
                    i <= i + 1;
                    
                    // Set done flag when i=16
                    if (i == 5'd16) begin
                        done_r <= 1'b1;
                    end
                    else begin
                        done_r <= 1'b0;
                    end
                end
                else begin
                    // i=17 - clear done flag
                    done_r <= 1'b0;
                    if (!start) begin
                        i <= 5'd0;
                    end
                end
            end
            else begin
                // start=0 - reset counter
                i <= 5'd0;
                done_r <= 1'b0;
            end
        end
    end

    // Output assignment
    always @(*) begin
        yout = yout_r;
    end

endmodule
