module calendar (
    input CLK,
    input RST,
    output reg [5:0] Hours,
    output reg [5:0] Mins,
    output reg [5:0] Secs
);

// Seconds counter
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Secs <= 6'd0;
    end else begin
        if (Secs == 6'd59) begin
            Secs <= 6'd0;
        end else begin
            Secs <= Secs + 1;
        end
    end
end

// Minutes counter
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Mins <= 6'd0;
    end else begin
        if (Secs == 6'd59) begin
            if (Mins == 6'd59) begin
                Mins <= 6'd0;
            end else begin
                Mins <= Mins + 1;
            end
        end else begin
            Mins <= Mins;
        end
    end
end

// Hours counter
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Hours <= 6'd0;
    end else begin
        if (Mins == 6'd59 && Secs == 6'd59) begin
            if (Hours == 6'd23) begin
                Hours <= 6'd0;
            end else begin
                Hours <= Hours + 1;
            end
        end else begin
            Hours <= Hours;
        end
    end
end

endmodule
