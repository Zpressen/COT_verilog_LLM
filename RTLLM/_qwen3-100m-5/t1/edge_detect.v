module edge_detect(
    input clk,
    input rst_n,
    input a,
    output reg rise,
    output reg down
);

reg a_prev;
reg edge_rise_prev;
reg edge_down_prev;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        a_prev <= 1'b0;
        edge_rise_prev <= 1'b0;
        edge_down_prev <= 1'b0;
        rise <= 1'b0;
        down <= 1'b0;
    end else begin
        a_prev <= a;
        rise <= edge_rise_prev;
        down <= edge_down_prev;
        edge_rise_prev <= (a_prev == 1'b0) && (a == 1'b1);
        edge_down_prev <= (a_prev == 1'b1) && (a == 1'b0);
    end
end

endmodule
