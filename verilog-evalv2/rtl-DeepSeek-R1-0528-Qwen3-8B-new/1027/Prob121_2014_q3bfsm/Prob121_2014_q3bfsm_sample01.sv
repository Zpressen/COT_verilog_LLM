
module TopModule(
  input clk,
  input reset,
  input x,
  output z
);

  // State encoding: 3 bits for 5 states
  reg [2:0] y;  // current state
  reg [2:0] y_next;  // next state

  // Output logic
  assign z = (y == 3'b000 && x == 1'b0) || 
             (y == 3'b001 && x == 1'b1) ||
             (y == 3'b010 && x == 1'b1) ||
             (y == 3'b011 && x == 1'b1) ||
             (y == 3'b100 && x == 1'b1);

  // FSM state transition logic
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      y <= 3'b000;
    end else begin
      case (y)
        3'b000: begin
          if (x == 1'b0) y_next <= 3'b000;
          else y_next <= 3'b001;
        end
        3'b001: begin
          if (x == 1'b0) y_next <= 3'b001;
          else y_next <= 3'b100;
        end
        3'b010: begin
          if (x == 1'b0) y_next <= 3'b010;
          else y_next <= 3'b001;
        end
        3'b011: begin
          if (x == 1'b0) y_next <= 3'b001;
          else y_next <= 3'b010;
        end
        3'b100: begin
          if (x == 1'b0) y_next <= 3'b011;
          else y_next <= 3'b100;
        end
        default: y_next <= 3'b000;
      endcase
      y <= y_next;
    end
  end
endmodule

