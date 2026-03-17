module RAM (
    input clk,
    input rst_n,
    input write_en,
    input [2:0] write_addr,
    input [5:0] write_data,
    input read_en,
    input [2:0] read_addr,
    output reg [5:0] read_data
);

    parameter WIDTH = 6;
    parameter DEPTH = 8;

    reg [WIDTH-1:0] memory [0:DEPTH-1];

    // Write operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize all memory locations to 0
            memory[0] <= 0;
            memory[1] <= 0;
            memory[2] <= 0;
            memory[3] <= 0;
            memory[4] <= 0;
            memory[5] <= 0;
            memory[6] <= 0;
            memory[7] <= 0;
        end
        else if (write_en) begin
            memory[write_addr] <= write_data;
        end
    end

    // Read operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data <= 0;
        end
        else if (read_en) begin
            read_data <= memory[read_addr];
        end
        else begin
            read_data <= 0;
        end
    end

endmodule
