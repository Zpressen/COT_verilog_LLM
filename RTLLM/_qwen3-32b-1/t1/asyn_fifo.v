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
localparam GRAY_WIDTH = ADDR_WIDTH;

reg [ADDR_WIDTH-1:0] waddr_bin, raddr_bin;
reg [GRAY_WIDTH-1:0] wptr, rptr;

// RAM declaration
reg [WIDTH-1:0] ram [0:DEPTH-1];

// Write pointer logic and full detection
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 0;
        wptr <= 0;
        wfull <= 1'b0;
    end else begin
        if (winc && !wfull) begin
            waddr_bin <= waddr_bin + 1;
            wptr <= waddr_bin ^ (waddr_bin >> 1);
        end
        
        // Convert write Gray to binary
        reg [GRAY_WIDTH-1:0] wptr_bin_tmp;
        wptr_bin_tmp[GRAY_WIDTH-1] = wptr[GRAY_WIDTH-1];
        wptr_bin_tmp[GRAY_WIDTH-2] = wptr_bin_tmp[GRAY_WIDTH-1] ^ wptr[GRAY_WIDTH-2];
        wptr_bin_tmp[GRAY_WIDTH-3] = wptr_bin_tmp[GRAY_WIDTH-2] ^ wptr[GRAY_WIDTH-3];
        wptr_bin_tmp[GRAY_WIDTH-4] = wptr_bin_tmp[GRAY_WIDTH-3] ^ wptr[GRAY_WIDTH-4];
        
        // Convert synchronized read Gray to binary
        reg [GRAY_WIDTH-1:0] rptr_sync2_bin_tmp;
        rptr_sync2_bin_tmp[GRAY_WIDTH-1] = rptr_sync2[GRAY_WIDTH-1];
        rptr_sync2_bin_tmp[GRAY_WIDTH-2] = rptr_sync2_bin_tmp[GRAY_WIDTH-1] ^ rptr_sync2[GRAY_WIDTH-2];
        rptr_sync2_bin_tmp[GRAY_WIDTH-3] = rptr_sync2_bin_tmp[GRAY_WIDTH-2] ^ rptr_sync2[GRAY_WIDTH-3];
        rptr_sync2_bin_tmp[GRAY_WIDTH-4] = rptr_sync2_bin_tmp[GRAY_WIDTH-3] ^ rptr_sync2[GRAY_WIDTH-4];
        
        if ((wptr_bin_tmp + 1) == rptr_sync2_bin_tmp) begin
            wfull <= 1'b1;
        end else begin
            wfull <= 1'b0;
        end
    end
end

// Write data to RAM
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        // No action
    end else if (winc && !wfull) begin
        ram[waddr_bin] <= wdata;
    end
end

// Read pointer logic and empty detection
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 0;
        rptr <= 0;
        rempty <= 1'b1;
    end else begin
        if (rinc && !rempty) begin
            raddr_bin <= raddr_bin + 1;
            rptr <= raddr_bin ^ (raddr_bin >> 1);
        end
        
        // Convert read Gray to binary
        reg [GRAY_WIDTH-1:0] rptr_bin_tmp;
        rptr_bin_tmp[GRAY_WIDTH-1] = rptr[GRAY_WIDTH-1];
        rptr_bin_tmp[GRAY_WIDTH-2] = rptr_bin_tmp[GRAY_WIDTH-1] ^ rptr[GRAY_WIDTH-2];
        rptr_bin_tmp[GRAY_WIDTH-3] = rptr_bin_tmp[GRAY_WIDTH-2] ^ rptr[GRAY_WIDTH-3];
        rptr_bin_tmp[GRAY_WIDTH-4] = rptr_bin_tmp[GRAY_WIDTH-3] ^ rptr[GRAY_WIDTH-4];
        
        // Convert synchronized write Gray to binary
        reg [GRAY_WIDTH-1:0] wptr_sync2_bin_tmp;
        wptr_sync2_bin_tmp[GRAY_WIDTH-1] = wptr_sync2[GRAY_WIDTH-1];
        wptr_sync2_bin_tmp[GRAY_WIDTH-2] = wptr_sync2_bin_tmp[GRAY_WIDTH-1] ^ wptr_sync2[GRAY_WIDTH-2];
        wptr_sync2_bin_tmp[GRAY_WIDTH-3] = wptr_sync2_bin_tmp[GRAY_WIDTH-2] ^ wptr_sync2[GRAY_WIDTH-3];
        wptr_sync2_bin_tmp[GRAY_WIDTH-4] = wptr_sync2_bin_tmp[GRAY_WIDTH-3] ^ wptr_sync2[GRAY_WIDTH-4];
        
        if ((rptr_bin_tmp + 1) == wptr_sync2_bin_tmp) begin
            rempty <= 1'b1;
        end else begin
            rempty <= 1'b0;
        end
    end
end

// Read data from RAM
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        rdata <= 0;
    end else if (rinc && !rempty) begin
        rdata <= ram[raddr_bin];
    end
end

// Synchronize read pointer to write clock domain
reg [GRAY_WIDTH-1:0] rptr_sync1, rptr_sync2;
wire [GRAY_WIDTH-1:0] rptr_out = rptr;

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_sync1 <= 0;
        rptr_sync2 <= 0;
    end else begin
        rptr_sync1 <= rptr_out;
        rptr_sync2 <= rptr_sync1;
    end
end

// Synchronize write pointer to read clock domain
reg [GRAY_WIDTH-1:0] wptr_sync1, wptr_sync2;
wire [GRAY_WIDTH-1:0] wptr_out = wptr;

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_sync1 <= 0;
        wptr_sync2 <= 0;
    end else begin
        wptr_sync1 <= wptr_out;
        wptr_sync2 <= wptr_sync1;
    end
end

endmodule
