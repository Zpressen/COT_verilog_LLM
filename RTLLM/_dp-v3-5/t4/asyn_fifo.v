module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    // Write interface
    input               wclk,
    input               wrstn,
    input               winc,
    input  [WIDTH-1:0]  wdata,
    output              wfull,
    
    // Read interface
    input               rclk,
    input               rrstn,
    input               rinc,
    output [WIDTH-1:0]  rdata,
    output              rempty
);

localparam ADDR_WIDTH = $clog2(DEPTH);

// Binary pointers
reg [ADDR_WIDTH:0] waddr_bin, raddr_bin;

// Gray code pointers
reg [ADDR_WIDTH:0] wptr, rptr;
wire [ADDR_WIDTH:0] wptr_gray, rptr_gray;

// Synchronized pointers
reg [ADDR_WIDTH:0] wptr_syn0, wptr_syn1, rptr_syn0, rptr_syn1;

// RAM signals
wire wenc, renc;
wire [ADDR_WIDTH-1:0] waddr, raddr;

// Binary to Gray conversion
assign wptr_gray = waddr_bin ^ (waddr_bin >> 1);
assign rptr_gray = raddr_bin ^ (raddr_bin >> 1);

// Full and empty signals
assign wfull = (wptr_gray == {~rptr_syn1[ADDR_WIDTH:ADDR_WIDTH-1], rptr_syn1[ADDR_WIDTH-2:0]});
assign rempty = (rptr_gray == wptr_syn1);

// RAM address (drop MSB)
assign waddr = waddr_bin[ADDR_WIDTH-1:0];
assign raddr = raddr_bin[ADDR_WIDTH-1:0];

// RAM enable signals
assign wenc = winc && !wfull;
assign renc = rinc && !rempty;

// Dual-port RAM instantiation
dual_port_RAM #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) u_dual_port_RAM (
    .wclk(wclk),
    .wenc(wenc),
    .waddr(waddr),
    .wdata(wdata),
    .rclk(rclk),
    .renc(renc),
    .raddr(raddr),
    .rdata(rdata)
);

// Write pointer logic (write clock domain)
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 0;
        wptr <= 0;
    end else begin
        if (wenc) begin
            waddr_bin <= waddr_bin + 1;
            wptr <= wptr_gray;
        end
    end
end

// Read pointer logic (read clock domain)
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 0;
        rptr <= 0;
    end else begin
        if (renc) begin
            raddr_bin <= raddr_bin + 1;
            rptr <= rptr_gray;
        end
    end
end

// Write pointer synchronizer (read clock domain)
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_syn0 <= 0;
        wptr_syn1 <= 0;
    end else begin
        wptr_syn0 <= wptr;
        wptr_syn1 <= wptr_syn0;
    end
end

// Read pointer synchronizer (write clock domain)
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_syn0 <= 0;
        rptr_syn1 <= 0;
    end else begin
        rptr_syn0 <= rptr;
        rptr_syn1 <= rptr_syn0;
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

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

// Write operation
always @(posedge wclk) begin
    if (wenc)
        RAM_MEM[waddr] <= wdata;
end

// Read operation
always @(posedge rclk) begin
    if (renc)
        rdata <= RAM_MEM[raddr];
end

endmodule
