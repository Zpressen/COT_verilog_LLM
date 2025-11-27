
module TopModule  
(  
  input  logic [31:0] in,  
  output logic [31:0] out  
);  

  // Reverse byte order by extracting and reordering bytes  
  assign out = {in[31:24], in[23:16], in[15:8], in[7:0]};  

endmodule  

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

