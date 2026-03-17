
module TopModule(
  input clk,
  input reset,
  input [2:0] s,
  output fr2,
  output fr1,
  output fr0,
  output dfr
);

  reg [2:0] prev_s; // Store previous sensor state for dfr calculation

  // Reset logic: initialize to low level state
  always @(posedge clk) begin
    if (reset) begin
      prev_s <= 3'b111; // All sensors asserted (low level)
      fr0 <= 1'b1;
      fr1 <= 1'b1;
      fr2 <= 1'b1;
      dfr <= 1'b0;
    end else begin
      prev_s <= s; // Update previous sensor state
    end
  end

  // Flow rate control based on current sensor level
  always @(*) begin
    case (s)
      3'b111: begin // Above s[2]
        fr0 <= 1'b0;
        fr1 <= 1'b0;
        fr2 <= 1'b0;
        dfr <= 1'b0;
      end
      3'b110: begin // Between s[2] and s[1]
        fr0 <= 1'b1;
        fr1 <= 1'b0;
        fr2 <= 1'b0;
        dfr <= 1'b0;
      end
      3'b100: begin // Between s[1] and s[0]
        fr0 <= 1'b1;
        fr1 <= 1'b1;
        fr2 <= 1'b0;
        dfr <= 1'b0;
      end
      3'b000: begin // Below s[0]
        fr0 <= 1'b1;
        fr1 <= 1'b1;
        fr2 <= 1'b1;
        dfr <= 1'b0;
      end
      default: begin // Default case for safety
        fr0 <= 1'b0;
        fr1 <= 1'b0;
        fr2 <= 1'b0;
        dfr <= 1'b0;
      end
    endcase
  end

endmodule

