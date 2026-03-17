
module TopModule(
  input  logic [15:0] scancode,
  output logic left,
  output logic down,
  output logic right,
  output logic up
);

  always @(*) begin
    case (scancode)
      16'hE06B: {left, down, right, up} = 4'b0001;
      16'hE072: {left, down, right, up} = 4'b0010;
      16'hE074: {left, down, right, up} = 4'b0100;
      16'hE075: {left, down, right, up} = 4'b1000;
      default: {left, down, right, up} = 4'b0000;
    endcase
  end
endmodule

