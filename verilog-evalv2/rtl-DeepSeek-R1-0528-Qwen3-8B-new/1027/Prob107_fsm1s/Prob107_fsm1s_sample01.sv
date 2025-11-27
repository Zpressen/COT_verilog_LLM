
module TopModule(
    input clk,
    input reset,
    input in,
    output out
);

    parameter A = 2'b00,
            B = 2'b01;

    reg [1:0] state;

    always @(posedge clk) begin
        if (reset)
            state <= B;
        else begin
            case (state)
                A: begin
                    if (in == 1'b0)
                        state <= B;
                    else
                        state <= A;
                end
                B: begin
                    if (in == 1'b0)
                        state <= A;
                    else
                        state <= B;
                end
            endcase
        end
    end

    assign out = (state == B) ? 1'b1 : 1'b0;

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

