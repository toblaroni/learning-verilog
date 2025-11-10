`timescale 1ns/1ps


module rx_tb;

// CLKS_PER_BIT clock cycles per bit
localparam CLOCK_FREQ = 1_843_200;
localparam BAUD_RATE  = 115_200;
localparam CLK_PERIOD_NS = 1_000_000_000 / CLOCK_FREQ;
localparam CLKS_PER_BIT  = CLOCK_FREQ / BAUD_RATE;

reg clk;
reg data;
reg rst;

wire [7:0] rx;
wire frame_error;

integer i;

always #(CLK_PERIOD_NS / 2) clk = ~clk;

uart_rx #(
    .BAUD_RATE (BAUD_RATE),
    .CLOCK_FREQ (CLOCK_FREQ)
) receiver (
    .clk (clk),
    .rst (rst),
    .data_in (data),
    .rx (rx),
    .frame_error (frame_error)
);

task send_byte;
    input [7:0] tx_data;
    input good_stop_bit;
    begin
        // Start bit
        data = 1'b0;
        #(CLK_PERIOD_NS * CLKS_PER_BIT);
        
        // Data bits (LSB first)
        for (i = 0; i < 8; i = i + 1) begin
            data = tx_data[i];
            #(CLK_PERIOD_NS * CLKS_PER_BIT);
        end
        
        // Stop bit
        data = good_stop_bit ? 1'b1 : 1'b0;
        #(CLK_PERIOD_NS * CLKS_PER_BIT);
    end
endtask

task check_sent_data;
    input [7:0] tx_data;
    begin
        if (rx == tx_data)
            $display("SUCCESS: Data received correctly! rx=%b", rx);
        else
            $display("FAILURE: Received %b, Expected %b", rx, tx_data);
    end
endtask

initial begin
    $dumpfile("uart_rx_tb.vcd");
    $dumpvars(0, rx_tb);

    clk = 0;
    rst = 1;    // Reset everything
    data = 1;   // IDLE

    $display("=== Starting UART Receiver Test Bench ===\n");

    #(CLK_PERIOD_NS * CLKS_PER_BIT * 2);
    rst = 0;

    $display("--- Test 1: Normal Transmission (0xAA) ---");
    send_byte(8'hAA, 1);
    #(CLK_PERIOD_NS * 10);
    check_sent_data(8'hAA);

    $display("\n--- Test 2: Normal Transmission (0x55) ---");
    send_byte(8'h55, 1);
    #(CLK_PERIOD_NS * 10);
    check_sent_data(8'h55);
    
    $display("\n--- Test 3: Normal Transmission (0x00) ---");
    send_byte(8'h00, 1);
    #(CLK_PERIOD_NS * 10);
    check_sent_data(8'h00);

    $display("\n=== All Tests Completed ===");
    $finish;
end

endmodule
