
module TopModule(
    input clk,
    input load,
    input [511:0] data,
    output reg [511:0] q
);

    always @(posedge clk) begin
        if (load) begin
            q <= data;
        end else begin
            // Rule 110 transition logic
            for (int i = 0; i < 512; i++) begin
                // Handle boundary conditions (implicitly zero)
                if (i == 0) begin
                    q[i] <= (q[i] ^ q[i+1]) ^ q[i+2];
                end else if (i == 511) begin
                    q[i] <= (q[i-2] ^ q[i-1]) ^ q[i];
                end else begin
                    q[i] <= (q[i-1] ^ q[i] ^ q[i+1]) ^ q[i+2];
                end
            end
        end
    end
endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

