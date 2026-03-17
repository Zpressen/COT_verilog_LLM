
module TopModule
(
  input  logic clk,
  input  logic reset,
  input  logic ena,
  output logic pm,
  output logic [7:0] hh,
  output logic [7:0] mm,
  output logic [7:0] ss
);

  // Seconds counter (BCD, 00-59)
  logic [3:0] ss_bcd;
  logic ss_carry;
  BCDCounter #(.WIDTH(4)) ss_counter (
    .clk(clk),
    .reset(reset),
    .ena(ena),
    .bcd_out(ss_bcd),
    .carry_out(ss_carry)
  );

  // Minutes counter (BCD, 00-59)
  logic [3:0] mm_bcd;
  logic mm_carry;
  BCDCounter #(.WIDTH(4)) mm_counter (
    .clk(clk),
    .reset(reset),
    .ena(mm_carry),
    .bcd_out(mm_bcd),
    .carry_out(mm_carry)
  );

  // Hours counter (BCD, 01-12)
  logic [3:0] hh_bcd;
  logic hh_carry;
  BCDCounter #(.WIDTH(4)) hh_counter (
    .clk(clk),
    .reset(reset),
    .ena(hh_carry),
    .bcd_out(hh_bcd),
    .carry_out(hh_carry)
  );

  // PM flag logic
  always_ff @(posedge clk) begin
    if (reset) begin
      pm <= 0;
    end else begin
      // Toggle PM when hours cross from 11 to 12 (AM to PM) or 12 to 1 (PM to AM)
      if (hh_bcd == 4'b1011 && hh_carry) begin // 11 to 12
        pm <= 1;
      end else if (hh_bcd == 4'b1100 && hh_carry) begin // 12 to 1
        pm <= 0;
      end else begin
        pm <= pm;
      end
    end
  end

  // Output assignments
  assign ss = {ss_bcd[3], ss_bcd[2], ss_bcd[1], ss_bcd[0]};
  assign mm = {mm_bcd[3], mm_bcd[2], mm_bcd[1], mm_bcd[0]};
  assign hh = {hh_bcd[3], hh_bcd[2], hh_bcd[1], hh_bcd[0]};

endmodule

// BCD counter module (4-bit)
module BCDCounter #(
  parameter WIDTH = 4
)(
  input  logic clk,
  input  logic reset,
  input  logic ena,
  output logic [WIDTH-1:0] bcd_out,
  output logic carry_out
);

  logic [WIDTH-1:0] count;

  always_ff @(posedge clk) begin
    if (reset) begin
      count <= 0;
      carry_out <= 0;
    end else if (ena) begin
      if (count == 9) begin
        count <= 0;
        carry_out <= 1;
      end else begin
        count <= count + 1;
        carry_out <= 0;
      end
    end else begin
      count <= count;
      carry_out <= 0;
    end
  end

  assign bcd_out = count;

endmodule

