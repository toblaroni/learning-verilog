
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
localparam SAMPLES_PER_BIT = CLKS_PER_BIT / 8;

reg [31:0] bit_count;
reg [2:0] bit_index;
reg [31:0] sample_count;    // We need some way of keeping track of which bit we're receiving

wire baud_tick   = (bit_count == CLKS_PER_BIT-1);
wire sample_tick = (sample_count == SAMPLES_PER_BIT-1);

// States
localparam IDLE  = 3'b00;
localparam START = 3'b01;
localparam DATA  = 3'b10;
localparam STOP  = 3'b11;

always @(posedge clk) begin
    case (state) 
        IDLE: begin
            bit_index <= 3'b0;
            bit_count <= 32'b0;
            sample_count <= 32'b0;

            if (data_in == 1'b0) begin
                state <= START; 
            end
        end

        START: begin
            // Read in the start bit
            if (baud_tick) begin
                
            end
        end

        DATA: begin
        end

        STOP: begin
        end
    endcase

    bit_count <= (baud_tick) ? 0 : bit_count + 1;
    sample_count <= (sample_tick) ? 0 : bit_count + 1;
end

endmodule
