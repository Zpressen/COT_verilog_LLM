module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    // Write port
    input wire wclk,
    input wire wrstn,
    input wire winc,
    input wire [WIDTH-1:0] wdata,
    output wire wfull,
    
    // Read port
    input wire rclk,
    input wire rrstn,
    input wire rinc,
    output wire [WIDTH-1:0] rdata,
    output wire rempty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    // Dual-port RAM
    wire [ADDR_WIDTH-1:0] waddr;
    wire [ADDR_WIDTH-1:0] raddr;
    wire wenc;
    wire renc;

    dual_port_RAM #(
        .DEPTH(DEPTH),
        .WIDTH(WIDTH)
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

    // Write pointer and gray code
    reg [ADDR_WIDTH:0] waddr_bin = 0;
    reg [ADDR_WIDTH:0] wptr = 0;
    wire [ADDR_WIDTH:0] wgray_next;
    wire [ADDR_WIDTH:0] wbin_next;

    // Read pointer and gray code
    reg [ADDR_WIDTH:0] raddr_bin = 0;
    reg [ADDR_WIDTH:0] rptr = 0;
    wire [ADDR_WIDTH:0] rgray_next;
    wire [ADDR_WIDTH:0] rbin_next;

    // Synchronizers
    reg [ADDR_WIDTH:0] rptr_sync1 = 0;
    reg [ADDR_WIDTH:0] rptr_sync2 = 0;
    reg [ADDR_WIDTH:0] wptr_sync1 = 0;
    reg [ADDR_WIDTH:0] wptr_sync2 = 0;

    // Gray code conversion functions
    function [ADDR_WIDTH:0] bin2gray;
        input [ADDR_WIDTH:0] bin;
        begin
            bin2gray = bin ^ (bin >> 1);
        end
    endfunction

    function [ADDR_WIDTH:0] gray2bin;
        input [ADDR_WIDTH:0] gray;
        integer i;
        begin
            gray2bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for (i = ADDR_WIDTH-1; i >= 0; i = i-1)
                gray2bin[i] = gray2bin[i+1] ^ gray[i];
        end
    endfunction

    // Write controller
    assign wbin_next = waddr_bin + (winc & ~wfull);
    assign wgray_next = bin2gray(wbin_next);

    assign wenc = winc & ~wfull;
    assign waddr = waddr_bin[ADDR_WIDTH-1:0];

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= 0;
            wptr <= 0;
        end else begin
            waddr_bin <= wbin_next;
            wptr <= wgray_next;
        end
    end

    // Read controller
    assign rbin_next = raddr_bin + (rinc & ~rempty);
    assign rgray_next = bin2gray(rbin_next);

    assign renc = rinc & ~rempty;
    assign raddr = raddr_bin[ADDR_WIDTH-1:0];

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= 0;
            rptr <= 0;
        end else begin
            raddr_bin <= rbin_next;
            rptr <= rgray_next;
        end
    end

    // Synchronizers
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            rptr_sync1 <= 0;
            rptr_sync2 <= 0;
        end else begin
            rptr_sync1 <= rptr;
            rptr_sync2 <= rptr_sync1;
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            wptr_sync1 <= 0;
            wptr_sync2 <= 0;
        end else begin
            wptr_sync1 <= wptr;
            wptr_sync2 <= wptr_sync1;
        end
    end

    // Full and empty generation
    assign wfull = (wgray_next == {~rptr_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rptr_sync2[ADDR_WIDTH-2:0]});
    assign rempty = (rgray_next == wptr_sync2);

endmodule

module dual_port_RAM #(
    parameter DEPTH = 16,
    parameter WIDTH = 8
)(
    input wire wclk,
    input wire wenc,
    input wire [$clog2(DEPTH)-1:0] waddr,
    input wire [WIDTH-1:0] wdata,
    input wire rclk,
    input wire renc,
    input wire [$clog2(DEPTH)-1:0] raddr,
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
