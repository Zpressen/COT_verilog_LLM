module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
) (
    input wclk,
    input rclk,
    input wrstn,
    input rrstn,
    input winc,
    input rinc,
    input [WIDTH-1:0] wdata,
    output wfull,
    output rempty,
    output [WIDTH-1:0] rdata
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    // Dual-port RAM instantiation
    dual_port_RAM #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) ram (
        .wclk(wclk),
        .wenc(winc && !wfull),
        .waddr(waddr_bin[ADDR_WIDTH-1:0]),
        .wdata(wdata),
        .rclk(rclk),
        .renc(rinc && !rempty),
        .raddr(raddr_bin[ADDR_WIDTH-1:0]),
        .rdata(rdata)
    );

    // Write pointer and Gray code conversion
    reg [ADDR_WIDTH:0] waddr_bin;
    reg [ADDR_WIDTH:0] wptr;

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= 0;
            wptr <= 0;
        end else begin
            if (winc && !wfull) begin
                waddr_bin <= waddr_bin + 1;
            end
            wptr <= (waddr_bin >> 1) ^ waddr_bin; // Binary to Gray conversion
        end
    end

    // Read pointer and Gray code conversion
    reg [ADDR_WIDTH:0] raddr_bin;
    reg [ADDR_WIDTH:0] rptr;

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= 0;
            rptr <= 0;
        end else begin
            if (rinc && !rempty) begin
                raddr_bin <= raddr_bin + 1;
            end
            rptr <= (raddr_bin >> 1) ^ raddr_bin; // Binary to Gray conversion
        end
    end

    // Synchronize read pointer to write clock domain
    reg [ADDR_WIDTH:0] rptr_syn_wclk [1:0];
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            rptr_syn_wclk[0] <= 0;
            rptr_syn_wclk[1] <= 0;
        end else begin
            rptr_syn_wclk[0] <= rptr;
            rptr_syn_wclk[1] <= rptr_syn_wclk[0];
        end
    end

    // Synchronize write pointer to read clock domain
    reg [ADDR_WIDTH:0] wptr_syn_rclk [1:0];
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            wptr_syn_rclk[0] <= 0;
            wptr_syn_rclk[1] <= 0;
        end else begin
            wptr_syn_rclk[0] <= wptr;
            wptr_syn_rclk[1] <= wptr_syn_rclk[0];
        end
    end

    // Full and empty generation
    assign wfull = (wptr == {~rptr_syn_wclk[1][ADDR_WIDTH:ADDR_WIDTH-1], 
                            rptr_syn_wclk[1][ADDR_WIDTH-2:0]});
    assign rempty = (rptr == wptr_syn_rclk[1]);

endmodule

module dual_port_RAM #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
) (
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
