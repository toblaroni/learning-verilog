
module blinker #(
    parameter SPEED = 100
)
(
    input clk,
    output reg signal
);

    reg [$clog2(SPEED+1):0] counter;    // Counter will have minimum width for SPEED

    always @(posedge clk) begin
        if (counter == SPEED) begin
            counter <= 0;
            signal <= ~signal;
        end else begin 
            counter <= counter + 1;
        end
    end

endmodule


