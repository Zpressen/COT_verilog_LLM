module dual_port_RAM #(
    parameter DEPTH = 16,
    parameter WIDTH = 8
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

reg [WIDTH-1:0] ram [0:DEPTH-1];

always @(posedge wclk) begin
    if (wenc) begin
        ram[waddr] <= wdata;
    end
end

always @(posedge rclk) begin
    if (renc) begin
        rdata <= ram[raddr];
    end
end

endmodule

module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
)(
    input wclk,
    input rclk,
    input wrstn,
    input rrstn,
    input winc,
    input rinc,
    input [WIDTH-1:0] wdata,
    output reg wfull,
    output reg rempty,
    output reg [WIDTH-1:0] rdata
);

localparam ADDR_WIDTH = $clog2(DEPTH);

dual_port_RAM #(.DEPTH(DEPTH), .WIDTH(WIDTH)) u_ram (
    .wclk(wclk),
    .wenc(winc & ~wfull),
    .waddr(waddr_bin),
    .wdata(wdata),
    .rclk(rclk),
    .renc(rinc & ~rempty),
    .raddr(raddr_bin),
    .rdata(rdata)
);

reg [ADDR_WIDTH-1:0] waddr_bin;
wire [ADDR_WIDTH-1:0] wptr_gray = waddr_bin ^ (waddr_bin >> 1);

reg [ADDR_WIDTH-1:0] raddr_bin;
wire [ADDR_WIDTH-1:0] rptr_gray = raddr_bin ^ (raddr_bin >> 1);

reg [ADDR_WIDTH-1:0] rptr_buff1, rptr_buff2;
reg [ADDR_WIDTH-1:0] wptr_buff1, wptr_buff2;

function [ADDR_WIDTH-1:0] gray_to_bin;
    input [ADDR_WIDTH-1:0] gray;
    reg [ADDR_WIDTH-1:0] bin;
    integer i;
    begin
        bin[ADDR_WIDTH-1] = gray[ADDR_WIDTH-1];
        for (i = ADDR_WIDTH-2; i >= 0; i = i-1) begin
            bin[i] = bin[i+1] ^ gray[i];
        end
        gray_to_bin = bin;
    end
endfunction

wire [ADDR_WIDTH-1:0] rptr_syn_bin = gray_to_bin(rptr_buff2);
wire [ADDR_WIDTH-1:0] wptr_syn_bin = gray_to_bin(wptr_buff2);

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 0;
    end else if (winc && !wfull) begin
        if (waddr_bin == DEPTH - 1) begin
            waddr_bin <= 0;
        end else begin
            waddr_bin <= waddr_bin + 1;
        end
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 0;
    end else if (rinc && !rempty) begin
        if (raddr_bin == DEPTH - 1) begin
            raddr_bin <= 0;
        end else begin
            raddr_bin <= raddr_bin + 1;
        end
    end
end

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_buff1 <= 0;
        rptr_buff2 <= 0;
    end else begin
        rptr_buff1 <= rptr_gray;
        rptr_buff2 <= rptr_buff1;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_buff1 <= 0;
        wptr_buff2 <= 0;
    end else begin
        wptr_buff1 <= wptr_gray;
        wptr_buff2 <= wptr_buff1;
    end
end

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        wfull <= 1'b0;
    end else begin
        wfull <= (waddr_bin + 1) == rptr_syn_bin;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        rempty <= 1'b1;
    end else begin
        rempty <= (raddr_bin == wptr_syn_bin);
    end
end

endmodule
