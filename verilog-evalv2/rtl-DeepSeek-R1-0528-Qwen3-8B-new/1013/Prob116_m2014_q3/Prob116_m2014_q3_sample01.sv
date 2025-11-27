
module TopModule(
  input  logic [3:0] x,
  output logic f
);

  // Combinational logic implementation based on Karnaugh map
  assign f = (x[3:2] == 2'b01 && !x[1]) || 
             (x[3:2] == 2'b11 && x[1]) || 
             (x[3:2] == 2'b10 && x[1]);

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

