module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output [7:0] mul_out
);

    parameter size = 4;

    wire [7:0] extended_a = { {4{1'b0}}, mul_a };
    wire [7:0] extended_b = { {4{1'b0}}, mul_b };

    wire [size-1:0][7:0] partial_products;

    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial
            assign partial_products[i] = (mul_b[i]) ? (extended_a << i) : 8'd0;
        end
    endgenerate

    reg [8:0] reg_stage1;
    reg [8:0] reg_stage2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_stage1 <= 9'd0;
            reg_stage2 <= 9'd0;
        end else begin
            reg_stage1 <= {1'b0, partial_products[0]} + {1'b0, partial_products[1]};
            reg_stage2 <= reg_stage1 + {1'b0, partial_products[2]} + {1'b0, partial_products[3]};
        end
    end

    assign mul_out = reg_stage2[7:0];

endmodule
