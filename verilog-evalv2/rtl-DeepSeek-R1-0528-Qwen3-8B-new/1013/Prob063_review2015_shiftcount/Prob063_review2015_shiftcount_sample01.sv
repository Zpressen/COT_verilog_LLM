
module TopModule
(
  input  logic clk,
  input  logic shift_ena,
  input  logic count_ena,
  input  logic data,
  output logic [3:0] q
);

  always @(posedge clk) begin
    case (1)
      shift_ena & count_ena: q <= {data, q[3:1]}; // both high, prioritize shift
      shift_ena & ~count_ena: q <= {data, q[3:1]}; // shift only
      ~shift_ena & count_ena: q <= q - 1; // decrement only
      default: q <= q; // no operation
    endcase
  end

endmodule

