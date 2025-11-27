
module TopModule
(
  input  logic c,
  input  logic d,
  output logic [3:0] mux_in
);

  // Assign mux_in based on Karnaugh map values
  assign mux_in = {0, 0, 1, 1};

endmodule

