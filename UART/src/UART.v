// 8 data bits, no parity bit, 1 stop bit (8N1).

`timescale 1ns/1ps

module uart #
(
    // Defaults
    parameter BAUD_RATE = 9600,
    parameter CLOCK_FREQ = 50000000   // 50 MHz (Base clock)
)
(
    input wire clk,
    input wire rst,
    // TX
    input wire start,   // Pulsed for 1 clock signal to start transmission
    input wire [7:0] tx_data_in,    
    // RX
    input wire rx_data_in,  

    // Flags
    output wire busy_tx, 
    output wire busy_rx,
    output wire rx_ready,
    output wire frame_error,

    output wire tx_data_out, 
    output wire [7:0] rx_data_out
);

uart_rx #(
    .BAUD_RATE (BAUD_RATE),
    .CLOCK_FREQ (CLOCK_FREQ)
) receiver (
    .clk         (clk),
    .rst         (rst),
    .data_in     (rx_data_in),
    .rx          (rx_data_out),
    .frame_error (frame_error),
    .rx_ready    (rx_ready),
    .busy        (busy_rx)
);

uart_tx #( 
    .BAUD_RATE (BAUD_RATE), 
    .CLOCK_FREQ (CLOCK_FREQ)
) transmitter (
    .clk     (clk),
    .rst     (rst),
    .start   (start),
    .data_in (tx_data_in),
    .busy    (busy_tx),
    .tx      (tx_data_out)
);

endmodule
