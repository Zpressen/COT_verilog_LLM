module dual_port_RAM #(
    parameter DEPTH = 16,
    parameter WIDTH = 8
)(
    input wclk,
    input wenc,
    input [$clog2(DEPTH)-1:0] waddr,
    input [WIDTH-1:0] wdata,
    input rclk,
    input renc,
    input [$clog2(DEPTH)-1:0] raddr,
    output reg [WIDTH-1:0] rdata
);

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

always @(posedge wclk) begin
    if (wenc) begin
        RAM_MEM[waddr] <= wdata;
    end
end

always @(posedge rclk) begin
    if (renc) begin
        rdata <= RAM_MEM[raddr];
    end
end

endmodule

module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input wclk,
    input rclk,
    input wrstn,
    input rrstn,
    input winc,
    input rinc,
    input [WIDTH-1:0] wdata,
    output reg wfull,
    output reg rempty,
    output reg [WIDTH-1:0] rdata
);

localparam ADDR_WIDTH = $clog2(DEPTH);
localparam GRAY_WIDTH = ADDR_WIDTH;

reg [ADDR_WIDTH-1:0] waddr_bin, raddr_bin;
wire [GRAY_WIDTH-1:0] wptr, rptr;
assign wptr = waddr_bin ^ (waddr_bin >> 1);
assign rptr = raddr_bin ^ (raddr_bin >> 1);

wire [ADDR_WIDTH-1:0] raddr;
wire [ADDR_WIDTH-1:0] waddr;
wire wenc;
wire renc;

dual_port_RAM #(.DEPTH(DEPTH), .WIDTH(WIDTH)) ram_inst (
    .wclk(wclk),
    .wenc(wenc),
    .waddr(waddr),
    .wdata(wdata),
    .rclk(rclk),
    .renc(renc),
    .raddr(raddr),
    .rdata(rdata)
);

assign waddr = waddr_bin;
assign wenc = winc && !wfull;
assign raddr = raddr_bin;
assign renc = rinc && !rempty;

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 0;
    end else if (wenc) begin
        waddr_bin <= (waddr_bin == DEPTH - 1) ? 0 : waddr_bin + 1;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 0;
    end else if (renc) begin
        raddr_bin <= (raddr_bin == DEPTH - 1) ? 0 : raddr_bin + 1;
    end
end

reg [GRAY_WIDTH-1:0] rptr_buff, rptr_syn;
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_buff <= 0;
        rptr_syn <= 0;
    end else begin
        rptr_buff <= rptr;
        rptr_syn <= rptr_buff;
    end
end

reg [GRAY_WIDTH-1:0] wptr_buff, wptr_syn;
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_buff <= 0;
        wptr_syn <= 0;
    end else begin
        wptr_buff <= wptr;
        wptr_syn <= wptr_buff;
    end
end

function [ADDR_WIDTH-1:0] gray_to_bin;
    input [ADDR_WIDTH-1:0] gray;
    reg [ADDR_WIDTH-1:0] bin;
    integer i;
    begin
        bin[0] = gray[0];
        for (i = 1; i < ADDR_WIDTH; i = i + 1) begin
            bin[i] = gray[i] ^ bin[i-1];
        end
        gray_to_bin = bin;
    end
endfunction

wire [ADDR_WIDTH-1:0] rptr_syn_bin = gray_to_bin(rptr_syn);
wire [ADDR_WIDTH-1:0] rptr_syn_plus_1 = rptr_syn_bin + 1;
wire full_condition = (waddr_bin == rptr_syn_plus_1);

wire [ADDR_WIDTH-1:0] wptr_syn_bin = gray_to_bin(wptr_syn);
wire empty_condition = (raddr_bin == wptr_syn_bin);

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        wfull <= 0;
    end else begin
        wfull <= full_condition;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        rempty <= 0;
    end else begin
        rempty <= empty_condition;
    end
end

endmodule
