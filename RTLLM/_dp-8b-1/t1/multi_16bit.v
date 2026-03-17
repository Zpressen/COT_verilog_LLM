module multi_16bit (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [15:0] ain,
    input wire [15:0] bin,
    output reg [31:0] yout,
    output wire done
);

    reg [4:0] i;            // Shift counter (needs to count up to 16)
    reg [15:0] areg;        // Multiplicand register
    reg [15:0] breg;        // Multiplier register
    reg [31:0] yout_r;      // Product register
    reg done_r;             // Done flag register

    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 5'd0;
        end else begin
            if (start) begin
                if (i < 5'd17) begin
                    i <= i + 5'd1;
                end
            end else begin
                i <= 5'd0;
            end
        end
    end

    // Done flag generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_r <= 1'b0;
        end else begin
            if (i == 5'd16) begin
                done_r <= 1'b1;
            end else if (i == 5'd17) begin
                done_r <= 1'b0;
            end
        end
    end

    // Shift and accumulate operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            areg <= 16'd0;
            breg <= 16'd0;
            yout_r <= 32'd0;
        end else begin
            if (start) begin
                if (i == 5'd0) begin
                    // Load input values
                    areg <= ain;
                    breg <= bin;
                    yout_r <= 32'd0;
                end else if (i < 5'd17) begin
                    // Check current bit and accumulate if set
                    if (areg[i-1]) begin
                        yout_r <= yout_r + (breg << (i-1));
                    end
                end
            end else begin
                yout_r <= 32'd0;
            end
        end
    end

    // Output assignments
    always @(*) begin
        yout = yout_r;
    end

    assign done = done_r;

endmodule
