
module TopModule(
  input  logic mode,
  input  logic too_cold,
  input  logic too_hot,
  input  logic fan_on,
  output logic heater,
  output logic aircon,
  output logic fan
);

  // Heater control: on in heating mode when too cold
  assign heater = (mode == 1'b1) & too_cold;

  // Air conditioner control: on in cooling mode when too hot
  assign aircon = (mode == 1'b0) & too_hot;

  // Fan control: on if heater or aircon is on, or if fan_on is set
  assign fan = heater | aircon | fan_on;

endmodule

