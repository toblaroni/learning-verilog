// UART Transmitter
// 8 data bits, no parity bit, 1 stop bit (8N1).

module transmitter # 
(
    parameter baud_rate = 9600,
    parameter clock_freq = 50000000,   // 50 MHz
    localparam bit_period = clock_freq / baud_rate
)
(
    input wire clk,
    input wire rst,
    input wire start,
    input wire data_in[7:0],    

    output wire busy,
    output wire tx
);

reg data_register;
reg clk_divider;



endmodule
