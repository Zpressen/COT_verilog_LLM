module calendar (
    input CLK,
    input RST,
    output reg [5:0] Hours = 6'd0,
    output reg [5:0] Mins = 6'd0,
    output reg [5:0] Secs = 6'd0
);

// Seconds counter
always @(posedge CLK or posedge RST) begin
    if (RST) 
        Secs <= 6'd0;
    else if (Secs == 59)
        Secs <= 6'd0;
    else 
        Secs <= Secs + 1;
end

// Minutes counter
always @(posedge CLK or posedge RST) begin
    if (RST) 
        Mins <= 6'd0;
    else if (Secs == 59) begin
        if (Mins == 59)
            Mins <= 6'd0;
        else 
            Mins <= Mins + 1;
    end
end

// Hours counter
always @(posedge CLK or posedge RST) begin
    if (RST) 
        Hours <= 6'd0;
    else if (Secs == 59 && Mins == 59) begin
        if (Hours == 23)
            Hours <= 6'd0;
        else 
            Hours <= Hours + 1;
    end
end

endmodule
