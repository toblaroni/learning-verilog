`timescale 1ns/1ps


module tx_tb;
// These values help with simulation
// 16 clock cycles per bit
localparam CLOCK_FREQ = 1_843_200;
localparam BAUD_RATE  = 115_200;
localparam CLK_PERIOD_NS = 1_000_000_000 / CLOCK_FREQ;
localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

reg clk;
reg rst;
reg start;
reg [7:0] data;

wire busy;
wire tx;

always #(CLK_PERIOD_NS / 2) clk = ~clk;

uart_tx #( 
    .BAUD_RATE (BAUD_RATE), 
    .CLOCK_FREQ (CLOCK_FREQ)
) transmitter (   // Default params
    .clk     (clk),
    .rst     (rst),
    .start   (start),
    .data_in (data),
    .busy    (busy),
    .tx      (tx)
);

initial begin
    $dumpfile("uart_tx_tb.vcd");
    $dumpvars(0, tx_tb);

    clk = 0;
    rst = 1;
    start = 0;
    data = 8'b01010101;
    
    #(CLK_PERIOD_NS * CLKS_PER_BIT * 2);
    rst = 0;
    start = 1;

    #(CLK_PERIOD_NS);    // Hold start for 1 period
    start = 0;

    // Wait for transmission to finish
    @(negedge busy);
    $display("Transmission finished at time %t", $time);

    if (tx == 1'b1)
        $display("SUCCESS 1: TX line returned to IDLE high.");
    else
        $display("FAILURE 1: TX line did not return to IDLE high.");

    rst = 1;
    data = 8'b11001100;
    #(CLK_PERIOD_NS * CLKS_PER_BIT * 2);    // Hold reset

    rst = 0;
    start = 1;

    #(CLK_PERIOD_NS);    // Hold start for 1 period
    start = 0;

    // Wait for transmission to finish
    @(negedge busy);
    $display("Transmission 2 finished at time %t", $time);

    if (tx == 1'b1)
        $display("SUCCESS 2: TX line returned to IDLE high.");
    else
        $display("FAILURE 2: TX line did not return to IDLE high.");
    
    $finish;
end
endmodule
