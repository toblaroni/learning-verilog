`timescale 1ns/1ps


module rx_tb;

// CLKS_PER_BIT clock cycles per bit
localparam CLOCK_FREQ = 1_843_200;
localparam BAUD_RATE  = 115_200;
localparam CLK_PERIOD_NS = 1_000_000_000 / CLOCK_FREQ;
localparam CLKS_PER_BIT  = CLOCK_FREQ / BAUD_RATE;

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

    #(CLK_PERIOD_NS * CLKS_PER_BIT * 2);
    rst = 0;
    data = 0;   // Start bit

    #(CLK_PERIOD_NS * CLKS_PER_BIT);  // Hold for a full bit

    // DATA
    for (i = 0; i < 8; i = i + 1) begin
        data = char[i];
        #(CLK_PERIOD_NS * CLKS_PER_BIT);
    end

    // STOP BIT
    #(CLK_PERIOD_NS * CLKS_PER_BIT); 
    data = 1; 

    #(CLK_PERIOD_NS * 32);
    if (rx == char)
        $display("SUCCESS: Data received correctly! rx=%b", rx);
    else
        $display("FAILURE: Received %b, Expected %b", rx, char);
    
    char = 8'b11111111;     // New character
    rst = 1;
    #(CLK_PERIOD_NS * CLKS_PER_BIT * 2);  // Hold reset 
    rst = 0;
    data = 0;
    #(CLK_PERIOD_NS * CLKS_PER_BIT);
    for (i = 0; i < 8; i = i + 1) begin
        data = char[i];
        #(CLK_PERIOD_NS * CLKS_PER_BIT);
    end

    // STOP BIT
    #(CLK_PERIOD_NS * CLKS_PER_BIT); 
    data = 1; 

    #(CLK_PERIOD_NS * CLKS_PER_BIT * 2);
    if (rx == char)
        $display("SUCCESS: Data received correctly! rx=%b", rx);
    else
        $display("FAILURE: Received %b, Expected %b", rx, char);

    $finish;
end

endmodule
