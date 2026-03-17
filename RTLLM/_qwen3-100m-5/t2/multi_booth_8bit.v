module multi_booth_8bit (
    input clk,
    input reset,
    input [7:0] a,
    input [7:0] b,
    output reg [15:0] p,
    output reg rdy
);

reg [15:0] multiplier_reg;
reg [15:0] multiplicand_reg;
reg [4:0] counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        multiplier_reg <= {{8{a[7]}}, a};
        multiplicand_reg <= {{8{b[7]}}, b};
        counter <= 0;
        p <= 0;
        rdy <= 0;
    end else begin
        if (counter < 16) begin
            multiplicand_reg <= multiplicand_reg << 1;
            if (multiplier_reg[counter]) begin
                p <= p + multiplicand_reg;
            end
            counter <= counter + 1;
        end else begin
            rdy <= 1;
        end
    end
end

endmodule
