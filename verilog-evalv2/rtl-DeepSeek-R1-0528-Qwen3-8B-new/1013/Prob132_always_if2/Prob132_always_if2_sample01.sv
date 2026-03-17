
module TopModule (
    input      cpu_overheated,
    output reg shut_off_computer,
    input      arrived,
    input      gas_tank_empty,
    output reg keep_driving
);

    // Fixed: Using continuous assignment for keep_driving to avoid blocking assignment issues
    assign keep_driving = ~arrived ? ~gas_tank_empty : 1'b0;

    // Overheating logic remains unchanged
    always @(*) begin
        if (cpu_overheated)
            shut_off_computer = 1;
    end

endmodule

