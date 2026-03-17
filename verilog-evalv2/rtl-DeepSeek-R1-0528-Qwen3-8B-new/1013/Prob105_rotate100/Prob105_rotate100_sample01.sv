
module TopModule (
  input  clk,
  input  load,
  input  ena[1:0],
  input  data[99:0],
  output q[99:0]
);

  logic [99:0] reg_array;

  always_ff @(posedge clk) begin
    if (load) begin
      reg_array <= data;
    end else if (ena == 2'b01) begin // Right rotate
      reg_array <= {reg_array[98:0], reg_array[99]};
    end else if (ena == 2'b10) begin // Left rotate
      reg_array <= {reg_array[0], reg_array[98:0]};
    end
  end

  assign q = reg_array;

endmodule

