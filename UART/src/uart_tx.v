// UART Transmitter
// 8 data bits, no parity bit, 1 stop bit (8N1).
// Assuming a 50MHz system clock

`timescale 1ns/1ps

module transmitter # 
(
    parameter BAUD_RATE = 9600,
    parameter CLOCK_FREQ = 50000000,   // 50 MHz (Base clock)
    localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE
)
(
    input wire clk,             // BCLK
    input wire rst,
    input wire start,           // Start transmitting data in the data reg
    input wire [7:0] data_in,    

    output reg busy,            // Flag
    output reg tx               // 1 bit (serial)
);

reg [2:0] state;        // 4 States
reg [7:0] data_reg;
reg [31:0] bit_count;
reg [2:0] bit_index;

wire baud_tick = (bit_count == CLKS_PER_BIT - 1);

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
        busy <= 1'b1;
        tx <= 1'b1;             // Send out 1 for IDLE
        bit_index <= 3'b0;
    end

    case (state)
        IDLE: begin
            tx <= 1'b1;            
            busy <= 1'b0;           
            bit_index <= 3'b0;

            if (start) begin
                state <= START;
            end
        end

        START: begin
            // Load the parallel data_in port into the data_reg
            data_reg <= data_in;
            // Send the start bit
            tx <= 1'b0;
        end


        DATA: begin
        end

        STOP: begin
        end

        default: begin
        end
    endcase

    bit_count <= (baud_tick) ? 0 : bit_count + 1;
end

endmodule
