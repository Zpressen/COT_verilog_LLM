module multi_16bit (
    input clk,
    input rst_n,
    input start,
    input [15:0] ain,
    input [15:0] bin,
    output reg [31:0] yout,
    output done
);

reg [15:0] areg, breg;
reg [31:0] yout_r;
reg [4:0] i;  // needs to count up to 16 (5 bits)
reg done_r;

assign done = done_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset all registers
        areg <= 16'b0;
        breg <= 16'b0;
        yout_r <= 32'b0;
        i <= 5'b0;
        done_r <= 1'b0;
    end
    else begin
        // Counter logic
        if (!start) begin
            i <= 5'b0;
        end
        else if (i < 5'd17) begin
            i <= i + 5'b1;
        end

        // Done flag logic
        if (i == 5'd16) begin
            done_r <= 1'b1;
        end
        else if (i == 5'd17) begin
            done_r <= 1'b0;
            // Optionally reset product register here if needed
        end
        else begin
            done_r <= 1'b0;
        end

        // Multiplication logic
        if (start) begin
            if (i == 5'd0) begin
                // Load input registers
                areg <= ain;
                breg <= bin;
                yout_r <= 32'b0;
            end
            else if (i < 5'd17) begin
                // Shift and accumulate
                if (areg[i-1]) begin
                    yout_r <= yout_r + (breg << (i-1));
                end
            end
        end
        else begin
            // When not started, keep outputs at 0
            yout_r <= 32'b0;
        end

        // Output assignment
        yout <= yout_r;
    end
end

endmodule
