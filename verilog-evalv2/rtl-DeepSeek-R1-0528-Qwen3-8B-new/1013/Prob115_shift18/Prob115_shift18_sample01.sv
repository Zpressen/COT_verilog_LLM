
module TopModule (
  input  clk,
  input  load,
  input  ena,
  input  amount,
  input  data,
  output q
);

  reg signed [63:0] reg_q;
  wire [63:0] shifted;

  always @(posedge clk) begin
    if (load) begin
      reg_q <= data;
    end else if (ena) begin
      reg_q <= shifted;
    end else begin
      reg_q <= reg_q;
    end
  end

  assign shifted = case (amount)
    2'b00: $unsigned(reg_q) << 1;
    2'b01: $unsigned(reg_q) << 8;
    2'b10: reg_q >> 1;
    2'b11: reg_q >> 8;
    default: reg_q;
  endcase

  assign q = reg_q;

endmodule

