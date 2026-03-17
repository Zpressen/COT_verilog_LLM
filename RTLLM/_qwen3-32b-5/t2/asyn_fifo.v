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
    if (wenc)
        RAM_MEM[waddr] <= wdata;
end

always @(posedge rclk) begin
    if (renc)
        rdata <= RAM_MEM[raddr];
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
localparam GRAY_WIDTH = ADDR_WIDTH + 1;

reg [ADDR_WIDTH:0] waddr_bin;
reg [ADDR_WIDTH:0] raddr_bin;

wire [GRAY_WIDTH-1:0] wptr = waddr_bin ^ (waddr_bin >> 1);
wire [GRAY_WIDTH-1:0] rptr = raddr_bin ^ (raddr_bin >> 1);

wire [ADDR_WIDTH-1:0] waddr_ram = wptr[ADDR_WIDTH-1:0];
wire [ADDR_WIDTH-1:0] raddr_ram = rptr[ADDR_WIDTH-1:0];

dual_port_RAM #(.DEPTH(DEPTH), .WIDTH(WIDTH)) ram_inst (
    .wclk(wclk),
    .wenc(winc && !wfull),
    .waddr(waddr_ram),
    .wdata(wdata),
    .rclk(rclk),
    .renc(rinc && !rempty),
    .raddr(raddr_ram),
    .rdata(rdata)
);

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) 
        waddr_bin <= 0;
    else if (winc && !wfull) begin
        if (waddr_bin == DEPTH-1)
            waddr_bin <= 0;
        else
            waddr_bin <= waddr_bin + 1;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) 
        raddr_bin <= 0;
    else if (rinc && !rempty) begin
        if (raddr_bin == DEPTH-1)
            raddr_bin <= 0;
        else
            raddr_bin <= raddr_bin + 1;
    end
end

// Synchronize read pointer to write domain
reg [GRAY_WIDTH-1:0] rptr_sync_to_write;
reg [GRAY_WIDTH-1:0] rptr_syn_wr1;
reg [GRAY_WIDTH-1:0] rptr_syn_wr2;

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) 
        rptr_sync_to_write <= 0;
    else 
        rptr_sync_to_write <= rptr;
end

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_syn_wr1 <= 0;
        rptr_syn_wr2 <= 0;
    end else begin
        rptr_syn_wr1 <= rptr_sync_to_write;
        rptr_syn_wr2 <= rptr_syn_wr1;
    end
end

// Convert Gray code to binary for full detection
function [ADDR_WIDTH:0] gray_to_bin;
    input [ADDR_WIDTH:0] gray;
    reg [ADDR_WIDTH:0] bin;
    integer i;
    begin
        bin = gray;
        for (i = 1; i <= ADDR_WIDTH; i = i+1)
            bin[i] = bin[i-1] ^ gray[i];
        gray_to_bin = bin;
    end
endfunction

wire [ADDR_WIDTH:0] rptr_syn_wr2_bin = gray_to_bin(rptr_syn_wr2);

assign wfull = ((waddr_bin + 1) & (DEPTH - 1)) == rptr_syn_wr2_bin;

// Synchronize write pointer to read domain
reg [GRAY_WIDTH-1:0] wptr_sync_to_read;
reg [GRAY_WIDTH-1:0] wptr_syn_rd1;
reg [GRAY_WIDTH-1:0] wptr_syn_rd2;

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) 
        wptr_sync_to_read <= 0;
    else 
        wptr_sync_to_read <= wptr;
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_syn_rd1 <= 0;
        wptr_syn_rd2 <= 0;
    end else begin
        wptr_syn_rd1 <= wptr_sync_to_read;
        wptr_syn_rd2 <= wptr_syn_rd1;
    end
end

wire [ADDR_WIDTH:0] wptr_syn_rd2_bin = gray_to_bin(wptr_syn_rd2);

assign rempty = (raddr_bin == wptr_syn_rd2_bin);

endmodule
