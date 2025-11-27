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

    localparam PTR_WIDTH = $clog2(DEPTH);
    localparam GRAY_WIDTH = PTR_WIDTH;

    // Write pointer and binary address
    reg [PTR_WIDTH-1:0] waddr_bin;
    wire [GRAY_WIDTH-1:0] wptr;
    assign wptr = waddr_bin ^ (waddr_bin >> 1);

    // Read pointer and binary address
    reg [PTR_WIDTH-1:0] raddr_bin;
    wire [GRAY_WIDTH-1:0] rptr;
    assign rptr = raddr_bin ^ (raddr_bin >> 1);

    // Synchronized pointers
    wire [GRAY_WIDTH-1:0] wptr_syn;
    wire [GRAY_WIDTH-1:0] rptr_syn;

    // Full and empty conditions
    wire full_condition;
    assign full_condition = 
        (wptr[GRAY_WIDTH-1] != wptr_syn[GRAY_WIDTH-1]) && 
        (wptr[GRAY_WIDTH-2] != wptr_syn[GRAY_WIDTH-2]) && 
        (wptr[GRAY_WIDTH-3] == wptr_syn[GRAY_WIDTH-3]) && 
        (wptr[GRAY_WIDTH-4] == wptr_syn[GRAY_WIDTH-4]);

    assign wfull = full_condition;
    assign rempty = (rptr == rptr_syn);

    // Write pointer increment logic
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= {PTR_WIDTH{1'b0}};
        end else if (winc && !wfull) begin
            waddr_bin <= waddr_bin + 1;
        end
    end

    // Read pointer increment logic
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= {PTR_WIDTH{1'b0}};
        end else if (rinc && !rempty) begin
            raddr_bin <= raddr_bin + 1;
        end
    end

    // Write pointer synchronizer to read clock domain
    reg [GRAY_WIDTH-1:0] wptr_buff0, wptr_buff1;
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            wptr_buff0 <= {GRAY_WIDTH{1'b0}};
            wptr_buff1 <= {GRAY_WIDTH{1'b0}};
        end else begin
            wptr_buff0 <= wptr;
            wptr_buff1 <= wptr_buff0;
        end
    end
    assign wptr_syn = wptr_buff1;

    // Read pointer synchronizer to write clock domain
    reg [GRAY_WIDTH-1:0] rptr_buff0, rptr_buff1;
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            rptr_buff0 <= {GRAY_WIDTH{1'b0}};
            rptr_buff1 <= {GRAY_WIDTH{1'b0}};
        end else begin
            rptr_buff0 <= rptr;
            rptr_buff1 <= rptr_buff0;
        end
    end
    assign rptr_syn = rptr_buff1;

    // RAM write enable and read enable
    wire wenc = winc && !wfull;
    wire renc = rinc && !rempty;

    // Instantiate dual-port RAM
    dual_port_RAM #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_ram (
        .wclk(wclk),
        .rclk(rclk),
        .wen(wenc),
        .waddr(waddr_bin),
        .wdata(wdata),
        .ren(ren),
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
    input  wire                 wen,
    input  wire [$clog2(DEPTH)-1:0] waddr,
    input  wire [WIDTH-1:0]     wdata,
    input  wire                 ren,
    input  wire [$clog2(DEPTH)-1:0] raddr,
    output reg  [WIDTH-1:0]     rdata
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
