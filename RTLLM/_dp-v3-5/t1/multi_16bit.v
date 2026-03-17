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
reg [4:0] i;  // counter 0-16 (needs 5 bits)

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset all registers
        areg <= 16'b0;
        breg <= 16'b0;
        yout_r <= 32'b0;
        i <= 5'b0;
        done <= 1'b0;
    end
    else begin
        if (start) begin
            if (i == 0) begin
                // Initialize registers
                areg <= ain;
                breg <= bin;
                yout_r <= 32'b0;
                i <= i + 1;
                done <= 1'b0;
            end
            else if (i < 17) begin
                // Shift and accumulate phase
                if (breg[0]) begin
                    yout_r <= yout_r + (areg << (i-1));
                end
                breg <= breg >> 1;
                i <= i + 1;
                
                // Set done flag when complete
                if (i == 16) begin
                    done <= 1'b1;
                end
                else begin
                    done <= 1'b0;
                end
            end
            else begin  // i == 17
                // Operation complete
                done <= 1'b0;
                i <= 0;
            end
        end
        else begin
            // Start not asserted
            i <= 0;
            done <= 1'b0;
        end
        
        // Output assignment
        yout <= yout_r;
    end
end

endmodule
