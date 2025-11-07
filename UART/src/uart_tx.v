// UART Transmitter
// 8 data bits, no parity bit, 1 stop bit (8N1).
// Assuming a 50MHz system clock

`timescale 1ns/1ps

module uart_tx # 
(
    // Defaults
    parameter BAUD_RATE = 9600,
    parameter CLOCK_FREQ = 50000000   // 50 MHz (Base clock)
)
(
    input wire clk,             // BCLK
    input wire rst,
    input wire start,           // Start transmitting data in the data reg
    input wire [7:0] data_in,    

    output reg busy,            // Flag
    output reg tx               // 1 bit (serial)
);

localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

reg [2:0] state;        // 4 States
reg [7:0] data_reg;
reg [31:0] bit_count;
reg [2:0] bit_index;

wire baud_tick = (bit_count == CLKS_PER_BIT-1);

// UART transmission states. 3-bits incase u want to add parity bit later on...
localparam IDLE  = 3'b00;
localparam START = 3'b01;
localparam DATA  = 3'b10;
localparam STOP  = 3'b11;

always @(posedge clk) begin
    // === RESET ===
    if (rst) begin
        bit_count <= 32'b0;     // Restart counter
        state <= IDLE;
        busy <= 1'b0;
        tx <= 1'b1;             // Send out 1 for IDLE
        bit_index <= 3'b0;
        data_reg <= 0;
    end else begin
        // FSM
        case (state)
            IDLE: begin
                tx <= 1'b1;            
                busy <= 1'b0;           
                bit_index <= 3'b0;
                bit_count <= 32'b0;     // Not strictly necessary but i think it's cleaner this way...

                if (start) begin
                    // Load the parallel data_in port into the data_reg
                    data_reg <= data_in;
                    state <= START;
                    busy <= 1'b1;
                end
            end

            START: begin
                tx <= 1'b0;
                if (baud_tick) begin
                    // Send the start bit
                    state <= DATA;
                    bit_count <= 0;
                end else
                    bit_count <= bit_count + 1;
            end

            DATA: begin
                tx <= data_reg[bit_index];

                if (baud_tick) begin
                    if (bit_index == 3'b111) begin
                        state <= STOP;
                     end else
                        bit_index <= bit_index + 1;
                    bit_count <= 0;
                end else
                    bit_count <= bit_count + 1;
            end

            STOP: begin
                // logical-high for 1 bit
                tx <= 1'b1;
                if (baud_tick) begin
                    state <= IDLE;      // Return to IDLE
                    busy <= 1'b0;
                    bit_count <= 0;
                end else
                    bit_count <= bit_count + 1;
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule
