module calendar (
    input CLK,
    input RST,
    output reg [5:0] Hours,
    output reg [5:0] Mins,
    output reg [5:0] Secs
);

always @(posedge CLK or posedge RST) begin
    if (RST) 
        Secs <= 6'd0;
    else if (Secs == 59)
        Secs <= 6'd0;
    else 
        Secs <= Secs + 1;
end

always @(posedge CLK or posedge RST) begin
    if (RST) 
        Mins <= 6'd0;
    else if (Mins == 59 && Secs == 59)
        Mins <= 6'd0;
    else if (Secs == 59)
        Mins <= Mins + 1;
    else 
        Mins <= Mins;
end

always @(posedge CLK or posedge RST) begin
    if (RST) 
        Hours <= 6'd0;
    else if (Hours == 23 && Mins == 59 && Secs == 59)
        Hours <= 6'd0;
    else if (Mins == 59 && Secs == 59)
        Hours <= Hours + 1;
    else 
        Hours <= Hours;
end

endmodule
