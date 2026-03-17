module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wclk,
    input  rclk,
    input  wrstn,
    input  rrstn,
    input  winc,
    input  rinc,
    input  [WIDTH-1:0] wdata,
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
    .wenc(winc && !wfull),
    .waddr(waddr_bin[ADDR_WIDTH-1:0]),
    .wdata(wdata),
    .rclk(rclk),
    .renc(rinc && !rempty),
    .raddr(raddr_bin[ADDR_WIDTH-1:0]),
    .rdata(rdata)
);

// Write domain signals
reg [ADDR_WIDTH:0] waddr_bin, waddr_gray;
wire [ADDR_WIDTH:0] waddr_gnext, waddr_bnext;
reg [ADDR_WIDTH:0] raddr_gray_syn1, raddr_gray_syn2;

// Read domain signals
reg [ADDR_WIDTH:0] raddr_bin, raddr_gray;
wire [ADDR_WIDTH:0] raddr_gnext, raddr_bnext;
reg [ADDR_WIDTH:0] waddr_gray_syn1, waddr_gray_syn2;

// Binary to Gray code conversion
function [ADDR_WIDTH:0] bin2gray;
    input [ADDR_WIDTH:0] bin;
    begin
        bin2gray = bin ^ (bin >> 1);
    end
endfunction

// Gray to binary conversion
function [ADDR_WIDTH:0] gray2bin;
    input [ADDR_WIDTH:0] gray;
    integer i;
    begin
        gray2bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
        for (i = ADDR_WIDTH-1; i >= 0; i = i-1)
            gray2bin[i] = gray2bin[i+1] ^ gray[i];
    end
endfunction

// Write pointer control
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 0;
        waddr_gray <= 0;
    end else begin
        waddr_bin <= waddr_bnext;
        waddr_gray <= waddr_gnext;
    end
end

assign waddr_bnext = waddr_bin + (winc && !wfull);
assign waddr_gnext = bin2gray(waddr_bnext);

// Read pointer control
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 0;
        raddr_gray <= 0;
    end else begin
        raddr_bin <= raddr_bnext;
        raddr_gray <= raddr_gnext;
    end
end

assign raddr_bnext = raddr_bin + (rinc && !rempty);
assign raddr_gnext = bin2gray(raddr_bnext);

// Write pointer synchronization to read domain
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        waddr_gray_syn1 <= 0;
        waddr_gray_syn2 <= 0;
    end else begin
        waddr_gray_syn1 <= waddr_gray;
        waddr_gray_syn2 <= waddr_gray_syn1;
    end
end

// Read pointer synchronization to write domain
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        raddr_gray_syn1 <= 0;
        raddr_gray_syn2 <= 0;
    end else begin
        raddr_gray_syn1 <= raddr_gray;
        raddr_gray_syn2 <= raddr_gray_syn1;
    end
end

// Full and empty generation
assign wfull = (waddr_gnext == {~raddr_gray_syn2[ADDR_WIDTH:ADDR_WIDTH-1], 
                               raddr_gray_syn2[ADDR_WIDTH-2:0]});
assign rempty = (raddr_gray == waddr_gray_syn2);

endmodule

// Dual-port RAM module
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
