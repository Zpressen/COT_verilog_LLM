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

reg [ADDR_WIDTH-1:0] waddr_bin, raddr_bin;
reg [GRAY_WIDTH-1:0] wptr, rptr;
reg [GRAY_WIDTH-1:0] rptr_syn1, rptr_syn2;
reg [GRAY_WIDTH-1:0] wptr_syn1, wptr_syn2;

wire wen = winc & ~wfull;
wire ren = rinc & ~rempty;

// Dual-port RAM instance
dual_port_RAM #(.WIDTH(WIDTH), .DEPTH(DEPTH)) ram_inst (
    .wclk(wclk),
    .wenc(wen),
    .waddr(waddr_bin),
    .wdata(wdata),
    .rclk(rclk),
    .renc(ren),
    .raddr(raddr_bin),
    .rdata(rdata)
);

// Write pointer logic
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) waddr_bin <= 0;
    else if (wen) waddr_bin <= waddr_bin + 1;
end

// Read pointer logic
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) raddr_bin <= 0;
    else if (ren) raddr_bin <= raddr_bin + 1;
end

// Gray code conversion
always @(posedge wclk) begin
    wptr <= waddr_bin ^ (waddr_bin >> 1);
end

always @(posedge rclk) begin
    rptr <= raddr_bin ^ (raddr_bin >> 1);
end

// Read pointer synchronization to write clock domain
always @(posedge wclk) begin
    rptr_syn1 <= rptr;
    rptr_syn2 <= rptr_syn1;
end

// Write pointer synchronization to read clock domain
always @(posedge rclk) begin
    wptr_syn1 <= wptr;
    wptr_syn2 <= wptr_syn1;
end

// Full/Empty detection
always @(posedge wclk) begin
    wfull <= (wptr[GRAY_WIDTH-1] != rptr_syn2[GRAY_WIDTH-1]) && 
             (wptr[GRAY_WIDTH-2] != rptr_syn2[GRAY_WIDTH-2]) && 
             (wptr[GRAY_WIDTH-3:0] == rptr_syn2[GRAY_WIDTH-3:0]);
end

always @(posedge rclk) begin
    rempty <= (rptr == wptr_syn2);
end

endmodule

module dual_port_RAM #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
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
    if (wenc) RAM_MEM[waddr] <= wdata;
end

always @(posedge rclk) begin
    if (renc) rdata <= RAM_MEM[raddr];
end

endmodule
