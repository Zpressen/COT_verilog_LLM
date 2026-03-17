[BEIGN]
module edge_detect (
    input clk,
    input rst_n,
    input a,
    output reg rise,
    output reg down
);

reg a_prev;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        a_prev <= 1'b0;
    end else begin
        a_prev <= a;
    end
end

always @(*) begin
    rise = 1'b0;
    down = 1'b0;
    if (!rst_n) begin
        rise = 1'b0;
        down = 1'b0;
    end else begin
        if (a_prev == 1'b0 && a == 1'b1) begin
            rise = 1'b1;
        end
        if (a_prev == 1'b1 && a == 1'b0) begin
            down = 1'b1;
        end
    end
end

endmodule
