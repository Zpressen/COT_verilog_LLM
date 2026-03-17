module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    // Write interface
    input wclk,
    input wrstn,
    input winc,
    input [WIDTH-1:0] wdata,
    output reg wfull,
    
    // Read interface
    input rclk,
    input rrstn,
    input rinc,
    output [WIDTH-1:0] rdata,
    output reg rempty
);

localparam ADDR_WIDTH = $clog2(DEPTH);

// Dual-port RAM
dual_port_RAM #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) ram_inst (
    .wclk(wclk),
    .wenc(~wfull & winc),
    .waddr(waddr_bin[ADDR_WIDTH-1:0]),
    .wdata(wdata),
    .rclk(rclk),
    .renc(~rempty & rinc),
    .raddr(raddr_bin[ADDR_WIDTH-1:0]),
    .rdata(rdata)
);

// Binary and Gray code pointers
reg [ADDR_WIDTH:0] waddr_bin, raddr_bin;  // Extra bit for full/empty detection
wire [ADDR_WIDTH:0] waddr_gray, raddr_gray;

// Convert binary to Gray code
assign waddr_gray = waddr_bin ^ (waddr_bin >> 1);
assign raddr_gray = raddr_bin ^ (raddr_bin >> 1);

// Write pointer control (write clock domain)
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 0;
    end else if (winc && !wfull) begin
        waddr_bin <= waddr_bin + 1;
    end
end

// Read pointer control (read clock domain)
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 0;
    end else if (rinc && !rempty) begin
        raddr_bin <= raddr_bin + 1;
    end
end

// Synchronizers
reg [ADDR_WIDTH:0] rptr_sync1, rptr_sync2;
reg [ADDR_WIDTH:0] wptr_sync1, wptr_sync2;

// Synchronize read pointer to write clock domain
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_sync1 <= 0;
        rptr_sync2 <= 0;
    end else begin
        rptr_sync1 <= raddr_gray;
        rptr_sync2 <= rptr_sync1;
    end
end

// Synchronize write pointer to read clock domain
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_sync1 <= 0;
        wptr_sync2 <= 0;
    end else begin
        wptr_sync1 <= waddr_gray;
        wptr_sync2 <= wptr_sync1;
    end
end

// Full and empty generation
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        wfull <= 1'b0;
    end else begin
        wfull <= (waddr_gray == {~rptr_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rptr_sync2[ADDR_WIDTH-2:0]});
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        rempty <= 1'b1;
    end else begin
        rempty <= (raddr_gray == wptr_sync2);
    end
end

endmodule

// Dual-port RAM module
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

localparam ADDR_WIDTH = $clog2(DEPTH);
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
