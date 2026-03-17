
module TopModule(
    input clk,
    input reset,
    output [9:0] q
);

    reg [9:0] counter;

    always @(posedge clk) begin
        if (reset)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    assign q = counter;
endmodule

