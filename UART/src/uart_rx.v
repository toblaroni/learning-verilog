
`timescale 1ns/1ps

module uart_rx #
(
    // Defaults
    parameter BAUD_RATE = 9600,
    parameter CLOCK_FREQ = 50000000   // 50 MHz (Base clock)
)
(
    input wire clk,
    input wire data_in,     // Received bits (serial)

    output reg [7:0] rx
);

localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

// We want to sample at around x8 or x16 the baud rate...

// States
localparam IDLE = 2'b00;

wire baud_tick = (bit_count == CLKS_PER_BIT-1);


endmodule
