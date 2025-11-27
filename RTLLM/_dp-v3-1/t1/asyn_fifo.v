module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    // Write port
    input               wclk,
    input               wrstn,
    input               winc,
    input  [WIDTH-1:0]  wdata,
    output              wfull,
    
    // Read port
    input               rclk,
    input               rrstn,
    input               rinc,
    output [WIDTH-1:0]  rdata,
    output              rempty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);
    
    // Binary pointers
    reg [ADDR_WIDTH:0] waddr_bin, raddr_bin;
    
    // Gray pointers
    wire [ADDR_WIDTH:0] wptr, rptr;
    reg [ADDR_WIDTH:0] wptr_syn, rptr_syn;
    reg [ADDR_WIDTH:0] wptr_syn_r, rptr_syn_r;
    
    // RAM signals
    wire [ADDR_WIDTH-1:0] waddr = waddr_bin[ADDR_WIDTH-1:0];
    wire [ADDR_WIDTH-1:0] raddr = raddr_bin[ADDR_WIDTH-1:0];
    wire wen = winc && !wfull;
    wire ren = rinc && !rempty;
    
    // Dual-port RAM instantiation
    dual_port_RAM #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_ram (
        .wclk(wclk),
        .wenc(wen),
        .waddr(waddr),
        .wdata(wdata),
        .rclk(rclk),
        .renc(ren),
        .raddr(raddr),
        .rdata(rdata)
    );
    
    // Binary to Gray conversion
    assign wptr = waddr_bin ^ (waddr_bin >> 1);
    assign rptr = raddr_bin ^ (raddr_bin >> 1);
    
    // Write pointer update
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= 0;
        end else if (wen) begin
            waddr_bin <= waddr_bin + 1;
        end
    end
    
    // Read pointer update
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= 0;
        end else if (ren) begin
            raddr_bin <= raddr_bin + 1;
        end
    end
    
    // Write pointer synchronization to read clock domain
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            {wptr_syn, wptr_syn_r} <= 0;
        end else begin
            {wptr_syn, wptr_syn_r} <= {wptr_syn_r, wptr};
        end
    end
    
    // Read pointer synchronization to write clock domain
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            {rptr_syn, rptr_syn_r} <= 0;
        end else begin
            {rptr_syn, rptr_syn_r} <= {rptr_syn_r, rptr};
        end
    end
    
    // Full and empty generation
    assign wfull = (wptr == {~rptr_syn[ADDR_WIDTH:ADDR_WIDTH-1], rptr_syn[ADDR_WIDTH-2:0]});
    assign rempty = (rptr == wptr_syn);
    
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
