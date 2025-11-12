// === Simple Echo Test Program ===

`timescale 1ns/1ps

module uart_tb;

localparam CLOCK_FREQ = 50_000_000;
localparam BAUD_RATE = 115200;
localparam CLK_PERIOD_NS = 1_000_000_000 / CLOCK_FREQ;
localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

reg clk; 

// UART A
reg rst_a, start_a; 
reg [7:0] tx_data_in_a; 
wire rx_data_in_a;
wire busy_tx_a, busy_rx_a, rx_ready_a, frame_error_a;   // Flags
wire tx_data_out_a;
wire [7:0] rx_data_out_a;

// UART B
reg rst_b, start_b; 
reg [7:0] tx_data_in_b; 
wire rx_data_in_b;
wire busy_tx_b, busy_rx_b, rx_ready_b, frame_error_b;   // Flags
wire tx_data_out_b;
wire [7:0] rx_data_out_b;

// Wire them together 
assign rx_data_in_b = tx_data_out_a;
assign rx_data_in_a = tx_data_out_b;

// Data to send
reg [7:0] character;

always #(CLK_PERIOD_NS / 2) clk = ~clk;

uart # (
    .BAUD_RATE  (BAUD_RATE),
    .CLOCK_FREQ (CLOCK_FREQ)
) uart_a (
    .clk   (clk),
    .rst   (rst_a),
    .start (start_a),
    .tx_data_in (tx_data_in_a),
    .rx_data_in (rx_data_in_a),
    .busy_tx (busy_tx_a),
    .busy_rx (busy_rx_a),
    .rx_ready (rx_ready_a),
    .frame_error (frame_error_a),
    .tx_data_out (tx_data_out_a),
    .rx_data_out (rx_data_out_a)
);

uart # (
    .BAUD_RATE  (BAUD_RATE),
    .CLOCK_FREQ (CLOCK_FREQ)
) uart_b (
    .clk   (clk),
    .rst   (rst_b),
    .start (start_b),
    .tx_data_in (tx_data_in_b),
    .rx_data_in (rx_data_in_b),
    .busy_tx (busy_tx_b),
    .busy_rx (busy_rx_b),
    .rx_ready (rx_ready_b),
    .frame_error (frame_error_b),
    .tx_data_out (tx_data_out_b),
    .rx_data_out (rx_data_out_b)
);

initial begin
    $dumpfile("uart_echo_tb.vcd");
    $dumpvars(0, uart_tb);

    // Initialize everything
    clk = 0;
    rst_a = 1;
    rst_b = 1;
    start_a = 0;
    start_b = 0;
    tx_data_in_a = 8'h0;
    tx_data_in_b = 8'h0;
    character = 8'h41;          // 'A'

    $display("\n=== UART Echo Test Started ===");
    $display("Clock Frequency: %0d Hz", CLOCK_FREQ);
    $display("Baud Rate: %0d", BAUD_RATE);
    $display("Clocks per bit: %0d\n", CLKS_PER_BIT);

    // Release reset after some time
    #(CLK_PERIOD_NS * 10);
    rst_a = 0;
    rst_b = 0;
    #(CLK_PERIOD_NS * 10);

    // UART-A Sends a byte to UART-B
    @(posedge clk);
    tx_data_in_a = character;
    start_a = 1;
    @(posedge clk);
    start_a = 0;
    $display("TIME %0t: UART A sent 0x%h '%c'", $time, tx_data_in_a, tx_data_in_a);

    wait(rx_ready_b);   // Wait for UART-B to receive the data

    // UART-B Sends the byte back to UART-A
    @(posedge clk);
    tx_data_in_b = rx_data_out_b;   // Send the received data
    start_b = 1;
    @(posedge clk);
    start_b = 0;
    $display("TIME %0t: UART B sent 0x%h '%c'", $time, tx_data_in_b, tx_data_in_b);

    wait(rx_ready_a);   // Wait for UART-A to receive the data

    if (rx_data_out_a === character) begin
        $display("\nSUCCESS! Echo test passed: Original data (0x%h) matches received data (0x%h).", character, rx_data_out_a);
    end else begin
        $display("\nFAILURE! Echo test failed: Expected 0x%h, Received 0x%h.", character, rx_data_out_a);
    end

    $display("\n=== Echo Test Completed ===\n");
    $finish;
end


// === Monitoring ===
always @(posedge frame_error_a) begin
    $display("ERROR: UART A frame error detected!");
end

always @(posedge frame_error_b) begin
    $display("ERROR: UART B frame error detected!");
end
// Continuous echo monitoring
always @(posedge rx_ready_a) begin
    $display("TIME %0t: UART A received 0x%h '%c'", $time, rx_data_out_a, rx_data_out_a);
end

always @(posedge rx_ready_b) begin
    $display("TIME %0t: UART B received 0x%h '%c'", $time, rx_data_out_b, rx_data_out_b);
end


endmodule

