
module TopModule (
  input  logic clk,
  input  logic reset,
  output logic [2:0] ena,
  output logic [15:0] q
);

  reg [3:0] digit0, digit1, digit2, digit3;
  reg carry_out0, carry_out1, carry_out2;

  // Digit 0 (ones) always increments on every clock cycle when not reset
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      digit0 <= 4'b0000;
      carry_out0 <= 1'b0;
    end
    else begin
      if (digit0 == 4'b1001) begin
        digit0 <= 4'b0000;
        carry_out0 <= 1'b1;
      end
      else begin
        digit0 <= digit0 + 1;
        carry_out0 <= 1'b0;
      end
    end
  end

  // Digit 1 (tens) increments when ena[0] (carry_out0) is high and not reset
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      digit1 <= 4'b0000;
      carry_out1 <= 1'b0;
    end
    else begin
      if (ena[0]) begin // ena[0] is carry_out0
        if (digit1 == 4'b1001) begin
          digit1 <= 4'b0000;
          carry_out1 <= 1'b1;
        end
        else begin
          digit1 <= digit1 + 1;
          carry_out1 <= 1'b0;
        end
      end
      else begin
        digit1 <= digit1;
        carry_out1 <= 1'b0;
      end
    end
  end

  // Digit 2 (hundreds) increments when ena[1] (carry_out1) is high and not reset
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      digit2 <= 4'b0000;
      carry_out2 <= 1'b0;
    end
    else begin
      if (ena[1]) begin // ena[1] is carry_out1
        if (digit2 == 4'b1001) begin
          digit2 <= 4'b0000;
          carry_out2 <= 1'b1;
        end
        else begin
          digit2 <= digit2 + 1;
          carry_out2 <= 1'b0;
        end
      end
      else begin
        digit2 <= digit2;
        carry_out2 <= 1'b0;
      end
    end
  end

  // Digit 3 (thousands) increments when ena[2] (carry_out2) is high and not reset
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      digit3 <= 4'b0000;
      carry_out2 <= 1'b0; // carry_out2 is used for ena[2]
    end
    else begin
      if (ena[2]) begin // ena[2] is carry_out2
        if (digit3 == 4'b1001) begin
          digit3 <= 4'b0000;
          carry_out2 <= 1'b1;
        end
        else begin
          digit3 <= digit3 + 1;
          carry_out2 <= 1'b0;
        end
      end
      else begin
        digit3 <= digit3;
        carry_out2 <= 1'b0;
      end
    end
  end

  // Assign enable signals and output
  assign ena[0] = carry_out0;
  assign ena[1] = carry_out1;
  assign ena[2] = carry_out2;
  assign q = {digit3, digit2, digit1, digit0};

endmodule

