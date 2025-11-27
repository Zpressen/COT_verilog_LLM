
module TopModule
(
  input  logic [2:0] sel,
  input  logic [3:0] data0,
  input  logic [3:0] data1,
  input  logic [3:0] data2,
  input  logic [3:0] data3,
  input  logic [3:0] data4,
  input  logic [3:0] data5,
  output logic [3:0] out
);

  always_comb
  begin
    case (sel)
      0: out = data0;
      1: out = data1;
      2: out = data2;
      3: out = data3;
      4: out = data4;
      5: out = data5;
      default: out = 0;
    endcase
  end

endmodule

