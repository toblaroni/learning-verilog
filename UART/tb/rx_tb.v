`timescale 1ns/1ps


module rx_tb;

// 16 clock cycles per bit
localparam CLOCK_FREQ = 1_843_200;
localparam BAUD_RATE  = 115_200;
localparam CLK_PERIOD_NS = 1_000_000_000 / CLOCK_FREQ;

reg clk;
reg data;
reg rst;

wire [7:0] rx;

integer i;

always #(CLK_PERIOD_NS / 2) clk = ~clk;

uart_rx #(
    .BAUD_RATE (BAUD_RATE),
    .CLOCK_FREQ (CLOCK_FREQ)
) receiver (
    .clk (clk),
    .rst (rst),
    .data_in (data),
    .rx (rx)
);

reg [7:0] char;

initial begin
    $dumpfile("uart_rx_tb.vcd");
    $dumpvars(0, rx_tb);

    clk = 0;
    char = 8'b10101010;
    rst = 1;    // Reset everything
    data = 1;   // IDLE

    #(CLK_PERIOD_NS * 5);
    rst = 0;

    #(CLK_PERIOD_NS * 10);
    data = 0;   // Start bit
    #(CLK_PERIOD_NS * 16);  // Hold for a full bit

    // DATA
    for (i = 0; i < 8; i = i + 1) begin
        data = char[i];
        #(CLK_PERIOD_NS * 16);
    end

    // STOP BIT
    #(CLK_PERIOD_NS * 16); 
    data = 1; 

    #(CLK_PERIOD_NS * 32);
    if (rx == char)
        $display("SUCCESS: Data received correctly! rx=0x%h", rx);
    else
        $display("FAILURE: Received 0x%h, Expected 0x%h", rx, char);
    $finish;
end

endmodule
