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
    output reg  [WIDTH-1:0]       rdata,
    output wire                   wfull,
    output wire                   rempty
);

    // Binary write/read pointers (log2(DEPTH) bits)
    reg [3:0] waddr_bin;
    reg [3:0] raddr_bin;

    // Gray code write/read pointers
    reg [3:0] wptr;
    reg [3:0] rptr;

    // Synchronized read pointer (write clock domain)
    reg [3:0] rptr_syn1;
    reg [3:0] rptr_syn2;

    // Synchronized write pointer (read clock domain)
    reg [3:0] wptr_syn1;
    reg [3:0] wptr_syn2;

    // Convert Gray to binary for comparison
    wire [3:0] bin_wptr;
    wire [3:0] bin_rptr_syn;

    // Full/empty signals
    assign bin_wptr = wptr ^ (wptr >> 1) ^ (wptr >> 2) ^ (wptr >> 3);
    assign bin_rptr_syn = rptr_syn2 ^ (rptr_syn2 >> 1) ^ (rptr_syn2 >> 2) ^ (rptr_syn2 >> 3);
    assign rempty = (bin_rptr_syn == bin_wptr);
    assign wfull = ((bin_wptr + 1) == bin_rptr_syn) || (bin_wptr == DEPTH-1 && bin_rptr_syn == 0);

    // Write pointer logic
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= 4'd0;
        end else if (winc && !wfull) begin
            waddr_bin <= waddr_bin + 1;
        end
    end

    // Read pointer logic
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= 4'd0;
        end else if (rinc && !rempty) begin
            raddr_bin <= raddr_bin + 1;
        end
    end

    // Gray code conversion
    assign wptr = waddr_bin ^ (waddr_bin >> 1);
    assign rptr = raddr_bin ^ (raddr_bin >> 1);

    // Read pointer synchronizer (write clock domain)
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            rptr_syn1 <= 4'd0;
            rptr_syn2 <= 4'd0;
        end else begin
            rptr_syn1 <= rptr;
            rptr_syn2 <= rptr_syn1;
        end
    end

    // Write pointer synchronizer (read clock domain)
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            wptr_syn1 <= 4'd0;
            wptr_syn2 <= 4'd0;
        end else begin
            wptr_syn1 <= wptr;
            wptr_syn2 <= wptr_syn1;
        end
    end

    // Dual-port RAM instantiation
    dual_port_RAM #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_ram (
        .wclk(wclk),
        .wenc(winc && !wfull),
        .waddr(waddr_bin),
        .wdata(wdata),
        .rclk(rclk),
        .renc(rinc && !rempty),
        .raddr(raddr_bin),
        .rdata(rdata)
    );

endmodule

// Dual-port RAM submodule
module dual_port_RAM #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire                   wclk,
    input  wire                   wenc,
    input  wire [$clog2(DEPTH)-1:0] waddr,
    input  wire [WIDTH-1:0]       wdata,
    input  wire                   rclk,
    input  wire                   renc,
    input  wire [$clog2(DEPTH)-1:0] raddr,
    output reg  [WIDTH-1:0]       rdata
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];

    // Write port
    always @(posedge wclk) begin
        if (wenc) begin
            mem[waddr] <= wdata;
        end
    end

    // Read port
    always @(posedge rclk) begin
        if (renc) begin
            rdata <= mem[raddr];
        end
    end

endmodule
