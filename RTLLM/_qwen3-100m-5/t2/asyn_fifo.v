module asyn_fifo #(
    parameter WIDTH     = 8,
    parameter DEPTH     = 16
)(
    input  wire                   wclk,
    input  wire                   rclk,
    input  wire                   wrstn,
    input  wire                   rrstn,
    input  wire                   winc,
    input  wire                   rinc,
    input  wire [WIDTH-1:0]       wdata,
    output wire                   wfull,
    output wire                   rempty,
    output wire [WIDTH-1:0]       rdata
);

    // Internal signals
    wire [WIDTH-1:0]              ram_rdata;
    wire                          ram_wenc;
    wire                          ram_renc;

    // Write pointer logic
    reg [3:0]                     waddr_bin;
    reg [3:0]                     wptr;

    // Read pointer logic
    reg [3:0]                     raddr_bin;
    reg [3:0]                     rptr;

    // Synchronized read pointer in write domain
    reg [3:0]                     wptr_buff1;
    reg [3:0]                     wptr_buff2;

    // Synchronized write pointer in read domain
    reg [3:0]                     rptr_buff1;
    reg [3:0]                     rptr_buff2;

    // RAM write enable
    assign ram_wenc = winc & wrstn;

    // RAM read enable
    assign ram_renc = rinc & rrstn;

    // Instantiate dual-port RAM
    dual_port_RAM #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_ram (
        .wclk(wclk),
        .rclk(rclk),
        .wen(ram_wenc),
        .waddr(waddr_bin),
        .wdata(wdata),
        .ren(ram_renc),
        .raddr(raddr_bin),
        .rdata(ram_rdata)
    );

    // Write pointer update and Gray code conversion
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= 4'b0;
            wptr      <= 4'b0;
        end else if (winc) begin
            waddr_bin <= waddr_bin + 1'b1;
            wptr      <= waddr_bin ^ (waddr_bin >> 1'b1); // Gray code conversion
        end
    end

    // Read pointer update and Gray code conversion
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= 4'b0;
            rptr      <= 4'b0;
        end else if (rinc) begin
            raddr_bin <= raddr_bin + 1'b1;
            rptr      <= raddr_bin ^ (raddr_bin >> 1'b1); // Gray code conversion
        end
    end

    // Synchronize read pointer to write domain (two-stage synchronizer)
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            wptr_buff1 <= 4'b0;
            wptr_buff2 <= 4'b0;
        end else begin
            wptr_buff1 <= rptr;
            wptr_buff2 <= wptr_buff1;
        end
    end

    // Synchronize write pointer to read domain (two-stage synchronizer)
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            rptr_buff1 <= 4'b0;
            rptr_buff2 <= 4'b0;
        end else begin
            rptr_buff1 <= wptr;
            rptr_buff2 <= rptr_buff1;
        end
    end

    // Empty detection (read pointer == synchronized write pointer)
    assign rempty = (rptr == rptr_buff2);

    // Full detection (write pointer has one more cycle than read pointer)
    // Gray code comparison: higher two bits opposite, lower two bits same
    assign wfull = (wptr[3:2] != wptr_buff2[3:2]) && (wptr[1:0] == wptr_buff2[1:0]);

    // Output read data
    assign rdata = ram_rdata;

endmodule

// Dual-port RAM submodule
module dual_port_RAM #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire                   wclk,
    input  wire                   rclk,
    input  wire                   wen,
    input  wire [3:0]             waddr,
    input  wire [WIDTH-1:0]       wdata,
    input  wire                   ren,
    input  wire [3:0]             raddr,
    output reg  [WIDTH-1:0]       rdata
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];

    // Write port
    always @(posedge wclk) begin
        if (wen) begin
            mem[waddr] <= wdata;
        end
    end

    // Read port
    always @(posedge rclk) begin
        if (ren) begin
            rdata <= mem[raddr];
        end
    end

endmodule
