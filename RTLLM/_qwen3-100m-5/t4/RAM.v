module RAM #(
    parameter WIDTH = 6,
    parameter DEPTH = 8
)(
    input clk,
    input rst_n,
    input write_en,
    input [WIDTH-1:0] write_data,
    input [$clog2(DEPTH)-1:0] write_addr,
    input read_en,
    input [$clog2(DEPTH)-1:0] read_addr,
    output [WIDTH-1:0] read_data
);

reg [WIDTH-1:0] RAM [0:DEPTH-1];
reg [WIDTH-1:0] read_data_reg;

// Initialize RAM to zero at simulation start
initial begin
    integer i;
    for (i = 0; i < DEPTH; i = i + 1) begin
        RAM[i] = 0;
    end
end

// Write logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        integer i;
        for (i = 0; i < DEPTH; i = i + 1) begin
            RAM[i] <= 0;
        end
    end else if (write_en) begin
        RAM[write_addr] <= write_data;
    end
end

// Read logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_data_reg <= 0;
    end else begin
        if (read_en) begin
            read_data_reg <= RAM[read_addr];
        end else begin
            read_data_reg <= 0;
        end
    end
end

assign read_data = read_data_reg;

endmodule
