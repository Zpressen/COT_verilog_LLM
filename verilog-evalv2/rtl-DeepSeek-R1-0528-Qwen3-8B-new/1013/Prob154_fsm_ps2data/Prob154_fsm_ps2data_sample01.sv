
module TopModule (
  input  logic clk,
  input  logic reset,
  input  logic [7:0] in,
  output logic [23:0] out_bytes,
  output logic done
);

  // State definitions
  typedef enum logic [1:0] {
    IDLE,      // Waiting for first byte
    BYTE1,     // Received first byte
    BYTE2,     // Received second byte
    BYTE3      // Received third byte
  } state_t;

  // FSM states
  state_t state, next_state;

  // Shift register to store the three bytes
  logic [23:0] shift_reg;

  // FSM logic
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      shift_reg <= 0;
    end else begin
      state <= next_state;
    end
  end

  // Next state logic
  always_comb begin
    next_state = state;
    case (state)
      IDLE: begin
        if (in[3]) begin  // Check for start byte
          next_state = BYTE1;
        end else begin
          next_state = IDLE;
        end
      end
      BYTE1: begin
        next_state = BYTE2;
      end
      BYTE2: begin
        next_state = BYTE3;
      end
      BYTE3: begin
        next_state = IDLE;
      end
    endcase
  end

  // Data path logic
  always_ff @(posedge clk) begin
    if (reset) begin
      shift_reg <= 0;
    end else if (state == BYTE1) begin
      shift_reg <= {in, shift_reg[8:16]};
    end else if (state == BYTE2) begin
      shift_reg <= {in, shift_reg[8:16]};
    end else if (state == BYTE3) begin
      shift_reg <= {in, shift_reg[8:16]};
    end
  end

  // Done signal generation
  assign done = (state == BYTE3);

  // Output bytes
  assign out_bytes = shift_reg;

endmodule

