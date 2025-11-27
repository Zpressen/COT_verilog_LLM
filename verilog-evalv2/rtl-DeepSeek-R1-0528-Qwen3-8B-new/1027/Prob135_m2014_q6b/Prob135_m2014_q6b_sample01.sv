
module TopModule(
    input  [2:0] y,
    input  w,
    output Y1
);

    reg [2:0] y_next;

    always @(y, w) begin
        case (y)
            3'b000: y_next = w ? 3'b000 : 3'b001;
            3'b001: y_next = w ? 3'b011 : 3'b000;
            3'b010: y_next = w ? 3'b011 : 3'b010;
            3'b011: y_next = w ? 3'b000 : 3'b101;
            3'b100: y_next = w ? 3'b101 : 3'b100;
            3'b101: y_next = w ? 3'b010 : 3'b011;
        endcase
    end

    assign Y1 = y[1];
endmodule

