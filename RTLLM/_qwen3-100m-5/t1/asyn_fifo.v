module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire                   wclk,
    input  wire                   rclk,
    input  wire                   wrstn,
    input  wire                   rrstn,
    input  wire                   winc,
    input  wire                   rinc,
    input  wire [WIDTH-1:0]       wdata,
    output reg                    wfull,
    output reg                    rempty,
    output reg [WIDTH-1:0]        rdata
);

localparam ADDR_WIDTH = $clog2(DEPTH);
localparam PTR_WIDTH = ADDR_WIDTH + 1;

reg [ADDR_WIDTH-1:0] waddr_bin;
reg [ADDR_WIDTH-1:0] raddr_bin;

reg [PTR_WIDTH-1:0] wptr;
reg [PTR_WIDTH-1:0] rptr;

reg [PTR_WIDTH-1:0] rptr_syn, rptr_buff;
reg [PTR_WIDTH-1:0] wptr_syn, wptr_buff;

wire wenc = winc && !wfull;
wire renc = rinc && !rempty;

// Gray code conversion
assign wptr = waddr_bin ^ (waddr_bin >> 1);
assign rptr = raddr_bin ^ (raddr_bin >> 1);

// Write address increment logic
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= {ADDR_WIDTH{1'b0}};
    end else if (wenc) begin
        waddr_bin <= waddr_bin + 1'b1;
    end
end

// Read address increment logic
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= {ADDR_WIDTH{1'b0}};
    end else if (renc) begin
        raddr_bin <= raddr_bin + 1'b1;
    end
end

// Read pointer synchronization to write clock
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_syn <= {PTR_WIDTH{1'b0}};
        rptr_buff <= {PTR_WIDTH{1'b0}};
    end else begin
        rptr_syn <= rptr;
        rptr_buff <= rptr_syn;
    end
end

// Write pointer synchronization to read clock
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_syn <= {PTR_WIDTH{1'b0}};
        wptr_buff <= {PTR_WIDTH{1'b0}};
    end else begin
        wptr_syn <= wptr;
        wptr_buff <= wptr_syn;
    end
end

// Full and empty signals
always @* begin
    wfull = (wptr[PTR_WIDTH-1] != rptr_syn[PTR_WIDTH-1]) && 
            (wptr[PTR_WIDTH-2:0] == rptr_syn[PTR_WIDTH-2:0]);
    rempty = (rptr == wptr_syn);
end

// Dual-port RAM instantiation
dual_port_RAM #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) u_ram (
    .wclk(wclk),
    .rclk(rclk),
    .rst_n(1'b1),
    .wenc(wenc),
    .waddr(waddr_bin),
    .wdata(wdata),
    .renc(renc),
    .raddr(raddr_bin),
    .rdata(rdata)
);

endmodule

// Dual-port RAM submodule
module dual_port_RAM #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire                 wclk,
    input  wire                 rclk,
    input  wire                 rst_n,
    input  wire                 wenc,
    input  wire [$clog2(DEPTH)-1:0] waddr,
    input  wire [WIDTH-1:0]     wdata,
    input  wire                 renc,
    input  wire [$clog2(DEPTH)-1:0] raddr,
    output reg  [WIDTH-1:0]     rdata
);

reg [WIDTH-1:0] mem [0:DEPTH-1];

// Write port
always @(posedge wclk or negedge rst_n) begin
    if (!rst_n) begin
        // No special initialization
    end else if (wenc) begin
        mem[waddr] <= wdata;
    end
end

// Read port
always @(posedge rclk or negedge rst_n) begin
    if (!rst_n) begin
        rdata <= {WIDTH{1'b0}};
    end else if (renc) begin
        rdata <= mem[raddr];
    end
end

endmodule
