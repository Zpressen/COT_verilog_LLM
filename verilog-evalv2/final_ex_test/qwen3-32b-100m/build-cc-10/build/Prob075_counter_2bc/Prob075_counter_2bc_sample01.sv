

module TopModule (
  input clk,
  input areset,
  input train_valid,
  input train_taken,
  output logic [1:0] state
);

always_ff @(posedge clk, posedge areset) begin
  if (areset) begin
    state <= 2'b01;
  end else if (train_valid) begin
    if (train_taken) begin
      if (state < 3) begin
        state <= state + 1;
      end else begin
        state <= state;
      end
    end else begin
      if (state > 0) begin
        state <= state - 1;
      end else begin
        state <= state;
      end
    end
  end
end

endmodule

