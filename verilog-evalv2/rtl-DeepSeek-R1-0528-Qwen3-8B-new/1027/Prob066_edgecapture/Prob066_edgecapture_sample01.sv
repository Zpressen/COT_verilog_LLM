
module TopModule(
    input clk,
    input reset,
    input [31:0] in,
    output reg [31:0] out
);

    reg [31:0] prev_in;
    reg [31:0] out_reg;

    always @(posedge clk) begin
        if (reset) begin
            out_reg <= 32'h1;
        end else begin
            // Check for any bit transitioning from 1 to 0
            for (int i = 0; i < 32; i = i + 1) begin
                if (in[i] == 1'b0 && prev_in[i] == 1'b1) begin
                    out_reg <= 1'b1;
                    break;
                end
            end
        end
    end

    assign out = out_reg;

    always @(posedge clk) begin
        prev_in <= in;
    end

endmodule

