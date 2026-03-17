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
    output reg [WIDTH-1:0]        rdata
);

    localparam ADDR_WIDTH = $clog2(DEPTH);
    localparam GRAY_WIDTH = ADDR_WIDTH + 1;

    wire [ADDR_WIDTH-1:0] waddr;
    wire [ADDR_WIDTH-1:0] raddr;
    wire                    wen;
    wire                    ren;
    wire [WIDTH-1:0]      rdata_int;
    assign rdata = rdata_int;

    // Write pointer logic
    reg [ADDR_WIDTH-1:0] waddr_bin;
    wire [GRAY_WIDTH-1:0] wptr;
    assign waddr = wptr[ADDR_WIDTH-1:0];
    assign wptr = {waddr_bin[ADDR_WIDTH-1], waddr_bin} ^ ({waddr_bin[ADDR_WIDTH-1], waddr_bin} >> 1);

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= {ADDR_WIDTH{1'b0}};
        end else if (winc && !wfull) begin
            waddr_bin <= waddr_bin + 1'b1;
        end
    end

    // Read pointer logic
    reg [ADDR_WIDTH-1:0] raddr_bin;
    wire [GRAY_WIDTH-1:0] rptr;
    assign raddr = rptr[ADDR_WIDTH-1:0];
    assign rptr = {raddr_bin[ADDR_WIDTH-1], raddr_bin} ^ ({raddr_bin[ADDR_WIDTH-1], raddr_bin} >> 1);

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= {ADDR_WIDTH{1'b0}};
        end else if (rinc && !rempty) begin
            raddr_bin <= raddr_bin + 1'b1;
        end
    end

    // Read pointer synchronizer (write domain)
    reg [GRAY_WIDTH-1:0] rptr_syn1;
    reg [GRAY_WIDTH-1:0] rptr_syn2;

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            rptr_syn1 <= {GRAY_WIDTH{1'b0}};
            rptr_syn2 <= {GRAY_WIDTH{1'b0}};
        end else begin
            rptr_syn1 <= rptr;
            rptr_syn2 <= rptr_syn1;
        end
    end

    // Write pointer synchronizer (read domain)
    reg [GRAY_WIDTH-1:0] wptr_syn1;
    reg [GRAY_WIDTH-1:0] wptr_syn2;

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            wptr_syn1 <= {GRAY_WIDTH{1'b0}};
            wptr_syn2 <= {GRAY_WIDTH{1'b0}};
        end else begin
            wptr_syn1 <= wptr;
            wptr_syn2 <= wptr_syn1;
        end
    end

    // Full/empty detection
    assign wfull = (wptr[GRAY_WIDTH-1] != rptr_syn2[GRAY_WIDTH-1]) && 
                   (wptr[GRAY_WIDTH-2] != rptr_syn2[GRAY_WIDTH-2]) && 
                   (wptr[GRAY_WIDTH-3:0] == rptr_syn2[GRAY_WIDTH-3:0]);
    assign rempty = (rptr == wptr_syn2);

    // RAM enable signals
    assign wen = winc && !wfull;
    assign ren = rinc && !rempty;

    // Dual-port RAM instantiation
    dual_port_RAM #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) u_ram (
        .wclk(wclk),
        .rclk(rclk),
        .wen(wen),
        .waddr(waddr),
        .wdata(wdata),
        .ren(ren),
        .raddr(raddr),
        .rdata(rdata_int)
    );

endmodule

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

    reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

    // Write port
    always @(posedge wclk) begin
        if (wen) begin
            RAM_MEM[waddr] <= wdata;
        end
    end

    // Read port
    always @(posedge rclk) begin
        if (ren) begin
            rdata <= RAM_MEM[raddr];
        end
    end

endmodule
