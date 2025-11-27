
module TopModule (
  input  logic mode,
  input  logic too_cold,
  input  logic too_hot,
  input  logic fan_on,
  output logic heater,
  output logic aircon,
  output logic fan
);

  // Heating mode: heater on when too_cold, aircon off
  heater = mode && too_cold;
  aircon = 0;

  // Cooling mode: aircon on when too_hot, heater off
  else begin
    heater = 0;
    aircon = mode && too_hot;
  end

  // Fan control: on when heater/aircon active OR fan_on requested
  fan = fan_on || heater || aircon;

endmodule

// VERILOG-EVAL: response did not use <CODE></CODE> correctly

