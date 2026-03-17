
module TopModule
(
  input  logic clk,
  input  logic areset,
  input  logic load,
  input  logic ena,
  input  logic [3:0] data,
  output logic [3:0] q
);

  always @(posedge clk or posedge areset) begin
    if (areset) begin
      q <= 4'b0000;
    end else begin
      case ({load, ena})
        2'b11: q <= data;  // Load has priority
        2'b01: q <= {1'b0, q[2:0]};  // Shift right with zero fill
        2'b00: q <= q;  // No change
      endcase
    end
  end

endmodule

