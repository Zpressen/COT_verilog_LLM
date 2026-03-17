
module TopModule(
    input clk,
    input reset,
    input in,
    output done
);

    // State definitions
    localparam IDLE = 0,
              DATA_0 = 1,
              DATA_1 = 2,
              DATA_2 = 3,
              DATA_3 = 4,
              DATA_4 = 5,
              DATA_5 = 6,
              DATA_6 = 7,
              DATA_7 = 8,
              STOP = 9,
              ERROR = 10;

    reg [3:0] state;
    reg done_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (in == 0) state <= DATA_0;
                    else state <= IDLE;
                end
                DATA_0: state <= DATA_1;
                DATA_1: state <= DATA_2;
                DATA_2: state <= DATA_3;
                DATA_3: state <= DATA_4;
                DATA_4: state <= DATA_5;
                DATA_5: state <= DATA_6;
                DATA_6: state <= DATA_7;
                DATA_7: begin
                    if (in == 1) state <= STOP;
                    else state <= ERROR;
                end
                STOP: begin
                    if (in == 1) begin
                        state <= IDLE;
                        done_reg <= 1;
                    end else state <= STOP;
                end
                ERROR: begin
                    if (in == 0) state <= IDLE;
                    else state <= ERROR;
                end
            endcase
        end
    end

    assign done = done_reg;

endmodule

