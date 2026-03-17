
module TopModule(
  input clk,
  input reset,
  input ena,
  output pm,
  output [7:0] hh,
  output [7:0] mm,
  output [7:0] ss
);

  // PM flag: 0=AM, 1=PM
  reg pm_reg;
  always @(posedge clk) begin
    if (reset) begin
      pm_reg <= 0;
    end else if (ena && hh == 12) begin
      pm_reg <= ~pm_reg;
    end
  end
  assign pm = pm_reg;

  // Hours counter (1-12 in BCD)
  reg [3:0] hh_reg;
  always @(posedge clk) begin
    if (reset) begin
      hh_reg <= 4'b0001; // 1
    end else if (ena && hh_reg == 4'b1100) begin // 12
      hh_reg <= 4'b0001;
    end else if (ena) begin
      hh_reg <= hh_reg + 1;
    end
  end
  // BCD conversion for hours: subtract 1 from binary value
  assign hh = {2'b00, hh_reg - 1};

  // Minutes counter (0-59 in BCD)
  reg [5:0] mm_reg;
  always @(posedge clk) begin
    if (reset) begin
      mm_reg <= 6'b000000; // 0
    end else if (ena && mm_reg == 6'b110111) begin // 59
      mm_reg <= 6'b000000;
    end else if (ena) begin
      mm_reg <= mm_reg + 1;
    end
  end
  // BCD conversion for minutes
  assign mm = {2'b00, mm_reg[3:2], mm_reg[1:0]};

  // Seconds counter (0-59 in BCD)
  reg [5:0] ss_reg;
  always @(posedge clk) begin
    if (reset) begin
      ss_reg <= 6'b000000; // 0
    end else if (ena && ss_reg == 6'b110111) begin // 59
      ss_reg <= 6'b000000;
    end else if (ena) begin
      ss_reg <= ss_reg + 1;
    end
  end
  // BCD conversion for seconds
  assign ss = {2'b00, ss_reg[3:2], ss_reg[1:0]};

endmodule

