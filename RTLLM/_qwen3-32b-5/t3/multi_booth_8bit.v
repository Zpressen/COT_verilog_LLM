module multi_booth_8bit (
    input clk,
    input reset,
    input [7:0] a,
    input [7:0] b,
    output reg [15:0] p,
    output reg rdy
);

reg [15:0] multiplier_register;
reg [15:0] multiplicand_register;
reg [4:0] counter;

always @(posedge clk) begin
    if (reset) begin
        multiplier_register <= { {8{b[7]}}, b };
        multiplicand_register <= { {8{a[7]}}, a };
        p <= 16'b0;
        counter <= 5'd0;
        rdy <= 1'b0;
    end else begin
        if (counter < 16) begin
            multiplicand_register <= multiplicand_register << 1;
            if (multiplier_register[counter]) begin
                p <= p + multiplicand_register;
            end
            counter <= counter + 1;
        end else begin
            rdy <= 1'b1;
        end
    end
end

endmodule
