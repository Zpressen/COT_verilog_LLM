module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
) (
    input wclk,
    input rclk,
    input wrstn,
    input rrstn,
    input winc,
    input rinc,
    input [WIDTH-1:0] wdata,
    output wfull,
    output rempty,
    output [WIDTH-1:0] rdata
);

localparam ADDR_WIDTH = $clog2(DEPTH);

// Dual-port RAM module
dual_port_RAM #(
    .DEPTH(DEPTH),
    .WIDTH(WIDTH)
) ram_inst (
    .wclk(wclk),
    .wenc(!wfull && winc),
    .waddr(waddr_bin[ADDR_WIDTH-1:0]),
    .wdata(wdata),
    .rclk(rclk),
    .renc(!rempty && rinc),
    .raddr(raddr_bin[ADDR_WIDTH-1:0]),
    .rdata(rdata)
);

// Write pointer and related signals
reg [ADDR_WIDTH:0] waddr_bin;
reg [ADDR_WIDTH:0] waddr_gray;

// Read pointer and related signals
reg [ADDR_WIDTH:0] raddr_bin;
reg [ADDR_WIDTH:0] raddr_gray;

// Synchronized read pointer (to write clock domain)
reg [ADDR_WIDTH:0] raddr_gray_sync1, raddr_gray_sync2;
reg [ADDR_WIDTH:0] raddr_gray_sync_wclk;

// Synchronized write pointer (to read clock domain)
reg [ADDR_WIDTH:0] waddr_gray_sync1, waddr_gray_sync2;
reg [ADDR_WIDTH:0] waddr_gray_sync_rclk;

// Binary to Gray code conversion
function [ADDR_WIDTH:0] bin2gray;
    input [ADDR_WIDTH:0] bin;
    begin
        bin2gray = bin ^ (bin >> 1);
    end
endfunction

// Write pointer control
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 0;
        waddr_gray <= 0;
    end
    else if (winc && !wfull) begin
        waddr_bin <= waddr_bin + 1;
        waddr_gray <= bin2gray(waddr_bin + 1);
    end
end

// Read pointer control
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 0;
        raddr_gray <= 0;
    end
    else if (rinc && !rempty) begin
        raddr_bin <= raddr_bin + 1;
        raddr_gray <= bin2gray(raddr_bin + 1);
    end
end

// Synchronize read pointer to write clock domain (2-stage)
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        raddr_gray_sync1 <= 0;
        raddr_gray_sync2 <= 0;
        raddr_gray_sync_wclk <= 0;
    end
    else begin
        raddr_gray_sync1 <= raddr_gray;
        raddr_gray_sync2 <= raddr_gray_sync1;
        raddr_gray_sync_wclk <= raddr_gray_sync2;
    end
end

// Synchronize write pointer to read clock domain (2-stage)
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        waddr_gray_sync1 <= 0;
        waddr_gray_sync2 <= 0;
        waddr_gray_sync_rclk <= 0;
    end
    else begin
        waddr_gray_sync1 <= waddr_gray;
        waddr_gray_sync2 <= waddr_gray_sync1;
        waddr_gray_sync_rclk <= waddr_gray_sync2;
    end
end

// Full detection (write clock domain)
assign wfull = (waddr_gray == {~raddr_gray_sync_wclk[ADDR_WIDTH:ADDR_WIDTH-1], 
                              raddr_gray_sync_wclk[ADDR_WIDTH-2:0]});

// Empty detection (read clock domain)
assign rempty = (raddr_gray == waddr_gray_sync_rclk);

endmodule

// Dual-port RAM module
module dual_port_RAM #(
    parameter DEPTH = 16,
    parameter WIDTH = 8
) (
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

// Write operation
always @(posedge wclk) begin
    if (wenc) begin
        RAM_MEM[waddr] <= wdata;
    end
end

// Read operation
always @(posedge rclk) begin
    if (renc) begin
        rdata <= RAM_MEM[raddr];
    end
end

endmodule
