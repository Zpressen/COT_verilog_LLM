
module TopModule (
    input cpu_overheated,
    output reg shut_off_computer,
    input arrived,
    input gas_tank_empty,
    output reg keep_driving
);

    always @(*) begin
        case (1'b1)
            cpu_overheated: shut_off_computer = 1;
            ~arrived: keep_driving = ~gas_tank_empty;
            default: keep_driving = 1'b0;
        endcase
    end
endmodule

