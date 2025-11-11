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
reg [8:0] tx_data_in_a; 
wire rx_data_in_a;
wire busy_tx_a, busy_rx_a, rx_ready_a, frame_error_a;   // Flags
wire tx_data_out_a;
wire [7:0] rx_data_out_a;

// UART B
reg rst_b, start_b; 
reg [8:0] tx_data_in_b; 
wire rx_data_in_b;
wire busy_tx_b, busy_rx_b, rx_ready_b, frame_error_b;   // Flags
wire tx_data_out_b;
wire [7:0] rx_data_out_b;

// Wire them together 
assign rx_data_in_b = tx_data_out_a;
assign rx_data_in_a = tx_data_out_b;

always #(CLK_PERIOD_NS / 2) clk = ~clk;

endmodule

