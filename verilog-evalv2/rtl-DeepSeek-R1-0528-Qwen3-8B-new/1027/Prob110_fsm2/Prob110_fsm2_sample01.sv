
module TopModule(
  input clk,
  input areset,
  input j,
  input k,
  output out
);

  reg state;
  assign out = state;

  always @(posedge clk or posedge areset) begin
    if (areset) begin
      state <= 1'b0;
    end else begin
      case (state)
        1'b0: begin
          if (j) state <= 1'b1;
          else state <= 1'b0;
        end
        1'b1: begin
          if (k) state <= 1'b0;
          else state <= 1'b1;
        end
      endcase
    end
  end
endmodule

