module multi_pipe_4bit #(parameter size = 4) (
    input clk,
    input rst_n,
    input [size-1:0] mul_a,
    input [size-1:0] mul_b,
    output reg [2*size-1:0] mul_out
);

    // Extended inputs
    wire [2*size-1:0] ext_a = {{size{1'b0}}, mul_a};
    wire [2*size-1:0] ext_b = {{size{1'b0}}, mul_b};

    // Partial products
    wire [2*size-1:0] pp [0:size-1];
    
    generate
        genvar i;
        for (i = 0; i < size; i = i + 1) begin : pp_gen
            assign pp[i] = ext_b[i] ? (ext_a << i) : {(2*size){1'b0}};
        end
    endgenerate

    // Pipeline registers
    reg [2*size-1:0] sum01, sum23;

    // Stage 1: Sum of pp0 and pp1
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum01 <= {(2*size){1'b0}};
        end else begin
            sum01 <= pp[0] + pp[1];
        end
    end

    // Stage 2: Sum of pp2 and pp3
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum23 <= {(2*size){1'b0}};
        end else begin
            sum23 <= pp[2] + pp[3];
        end
    end

    // Stage 3: Final sum
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= {(2*size){1'b0}};
        end else begin
            mul_out <= sum01 + sum23;
        end
    end

endmodule
