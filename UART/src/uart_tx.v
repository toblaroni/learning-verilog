// UART Transmitter
// 8 data bits, no parity bit, 1 stop bit (8N1).
// Assuming a 50MHz system clock

`timescale 1ns/1ps

module transmitter # 
(
    parameter BAUD_RATE = 9600,
    parameter CLOCK_FREQ = 50000000,   // 50 MHz
    localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE
)
(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] data_in,    

    output wire busy,
    output wire tx
);

reg [1:0] state;        // 4 States
reg [7:0] data_reg;
reg [31:0] bit_count;

wire baud_tick = (bit_count == CLKS_PER_BIT);

// UART transmission states 
localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam DATA = 2'b10;
localparam STOP = 2'b11;

always @(posedge clk) begin
    // --- State machine logic ---
    //
end

endmodule
