module multi_16bit (
    input clk,
    input rst_n,
    input start,
    input [15:0] ain,
    input [15:0] bin,
    output reg [31:0] yout,
    output reg done
);

    reg [15:0] areg, breg;
    reg [31:0] yout_r;
    reg [4:0] i;  // Need 5 bits to count up to 17
    reg done_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            areg <= 16'b0;
            breg <= 16'b0;
            yout_r <= 32'b0;
            i <= 5'b0;
            done_r <= 1'b0;
        end else begin
            if (start) begin
                if (i == 5'd0) begin
                    // First cycle - load input values
                    areg <= ain;
                    breg <= bin;
                    yout_r <= 32'b0;
                    i <= i + 1'b1;
                end else if (i <= 5'd16) begin
                    // Shift and accumulate cycles
                    if (areg[i-1]) begin
                        yout_r <= yout_r + (breg << (i-1));
                    end
                    i <= i + 1'b1;
                end else if (i == 5'd17) begin
                    // Extra cycle to reset
                    i <= 5'b0;
                end
            end else begin
                // Not started - reset counter
                i <= 5'b0;
            end

            // Done flag generation
            if (i == 5'd16) begin
                done_r <= 1'b1;
            end else begin
                done_r <= 1'b0;
            end
        end
    end

    // Output assignments
    always @(*) begin
        yout = yout_r;
        done = done_r;
    end

endmodule
