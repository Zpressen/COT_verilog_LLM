

module TopModule (
  input clk,
  input resetn,
  input x,
  input y,
  output f,
  output g
);

typedef enum logic [2:0] {
  A = 3'b000,
  B = 3'b001,
  C = 3'b010,
  D = 3'b011,
  E = 3'b100,
  F = 3'b101,
  H = 3'b110,
  G = 3'b111
} state_t;

state_t current, next;

always_ff @(posedge clk, negedge resetn) begin
  if (!resetn)
    current <= A;
  else
    current <= next;
end

always_comb begin
  next = current; // default
  f = 1'b0;
  g = 1'b0;

  case (current)
    A: begin
      if (resetn) next = B;
      else next = A;
      f = 1'b0;
      g = 1'b0;
    end
    B: begin
      next = C;
      f = 1'b1;
      g = 1'b0;
    end
    C: begin
      if (x) next = D;
      else next = C;
      f = 1'b0;
      g = 1'b0;
    end
    D: begin
      if (x == 1'b0) next = E;
      else next = C;
      f = 1'b0;
      g = 1'b0;
    end
    E: begin
      if (x) next = F;
      else next = C;
      f = 1'b0;
      g = 1'b0;
    end
    F: begin
      if (y) next = F;
      else next = H;
      f = 1'b0;
      g = 1'b1;
    end
    H: begin
      if (y) next = F;
      else next = G;
      f = 1'b0;
      g = 1'b1;
    end
    G: begin
      next = G;
      f = 1'b0;
      g = 1'b0;
    end
    default: begin
      next = current;
      f = 1'b0;
      g = 1'b0;
    end
  endcase
end

endmodule

