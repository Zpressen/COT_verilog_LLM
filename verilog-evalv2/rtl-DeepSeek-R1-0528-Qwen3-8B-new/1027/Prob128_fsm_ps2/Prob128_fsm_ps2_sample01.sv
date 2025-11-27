
module TopModule(
    input clk,
    input reset,
    input [7:0] in,
    output done
);

    // FSM states
    typedef enum {IDLE, BYTE1, BYTE2, BYTE3} state_t;
    state_t state, next_state;

    // FSM counter for byte position
    reg [1:0] byte_count;

    // FSM logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            byte_count <= 2'b00;
            done <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (in[3]) begin
                        next_state = BYTE1;
                        byte_count <= 2'b01;
                    end else
                        next_state = IDLE;
                end
                BYTE1: begin
                    if (byte_count < 2'b01) begin
                        next_state = BYTE2;
                        byte_count <= byte_count + 1;
                    end else
                        next_state = IDLE;
                end
                BYTE2: begin
                    if (byte_count < 2'b10) begin
                        next_state = BYTE3;
                        byte_count <= byte_count + 1;
                    end else
                        next_state = IDLE;
                end
                BYTE3: begin
                    if (byte_count < 2'b11) begin
                        next_state = IDLE;
                        byte_count <= byte_count + 1;
                    end else
                        next_state = IDLE;
                end
            endcase
            state <= next_state;
        end
    end

    // Done signal
    always @(posedge clk) begin
        if (state == BYTE3 && byte_count == 2'b11) begin
            done <= 1'b1;
        end else begin
            done <= 1'b0;
        end
    end

endmodule

