module edge_detect (
    input clk,
    input rst_n,
    input a,
    output reg rise,
    output reg down
);

reg a_prev;
reg detect_rise_prev;
reg detect_down_prev;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        a_prev <= 1'b0;
        detect_rise_prev <= 1'b0;
        detect_down_prev <= 1'b0;
        rise <= 1'b0;
        down <= 1'b0;
    end else begin
        a_prev <= a;
        detect_rise_prev <= (a_prev == 1'b0) && (a == 1'b1);
        detect_down_prev <= (a_prev == 1'b1) && (a == 1'b0);
        rise <= detect_rise_prev;
        down <= detect_down_prev;
    end
end

endmodule
