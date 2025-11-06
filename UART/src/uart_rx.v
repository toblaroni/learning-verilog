
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
    input wire rst,

    output reg [7:0] rx
);

localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

reg [31:0] bit_count;
reg [2:0] bit_index;
reg [2:0] state;
reg [7:0] rx_shift;     // Hold partial data

wire baud_tick = (bit_count == CLKS_PER_BIT-1);
wire sample_tick = (bit_count == (CLKS_PER_BIT-1)/2);

// States
localparam IDLE  = 3'b00;
localparam START = 3'b01;
localparam DATA  = 3'b10;
localparam STOP  = 3'b11;

always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        bit_count <= 0;
        bit_index <= 0;

    end else begin
        case (state) 
            IDLE: begin
                bit_index <= 3'b0;
                bit_count <= 32'b0;

                if (data_in == 1'b0) begin
                    state <= START; 
                end
            end

            START: begin
                // Make sure it's not noise
                if (sample_tick && data_in == 1'b1) begin
                    state <= IDLE;  // Noise
                end else if (baud_tick && state == START) begin
                    state <= DATA;
                    bit_count <= 0;
                end else
                    bit_count <= bit_count + 1;
            end

            DATA: begin
                if (sample_tick)
                    rx_shift[bit_index] <= data_in;
                if (baud_tick) begin
                    if (bit_index == 3'b111)
                        state <= STOP;
                    else
                        bit_index <= bit_index + 1;
                    bit_count <= 0;
                end else
                    bit_count <= bit_count + 1;
            end

            STOP: begin
                if (sample_tick && data_in == 1'b1) begin
                    rx <= rx_shift;     
                end

                if (baud_tick) begin
                    // Enter IDLE regardless...? What to do if no stop bit?
                    state <= IDLE;
                    bit_count <= 0;
                end else
                    bit_count <= bit_count + 1;

            end

            default: state <= IDLE;
        endcase
    end
end

endmodule
