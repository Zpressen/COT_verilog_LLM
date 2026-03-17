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
    else if (Secs == 6'd59)
        Secs <= 6'd0;
    else
        Secs <= Secs + 1;
end

always @(posedge CLK or posedge RST) begin
    if (RST) 
        Mins <= 6'd0;
    else if (Secs == 6'd59) begin
        if (Mins == 6'd59)
            Mins <= 6'd0;
        else
            Mins <= Mins + 1;
    end
    else 
        Mins <= Mins;
end

always @(posedge CLK or posedge RST) begin
    if (RST) 
        Hours <= 6'd0;
    else if (Mins == 6'd59 && Secs == 6'd59) begin
        if (Hours == 6'd23)
            Hours <= 6'd0;
        else
            Hours <= Hours + 1;
    end
    else 
        Hours <= Hours;
end

endmodule
