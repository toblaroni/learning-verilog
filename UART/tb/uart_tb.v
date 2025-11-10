`timescale 1ns/1ps

module uart_tb;

localparam CLOCK_FREQ = 50_000_000;
localparam BAUD_RATE = 115200;
localparam CLK_PERIOD_NS = 20; // 50MHz = 20ns period

reg clk, rst, start;
reg [7:0] tx_data_in;
reg rx_data_in;

wire busy_tx, busy_rx, rx_ready, frame_error, tx_data_out;
wire [7:0] rx_data_out;

// Clock generation
always #(CLK_PERIOD_NS / 2) clk = ~clk;

uart #(
    .BAUD_RATE(BAUD_RATE),
    .CLOCK_FREQ(CLOCK_FREQ)
) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .tx_data_in(tx_data_in),
    .rx_data_in(rx_data_in),
    .busy_tx(busy_tx),
    .busy_rx(busy_rx),
    .rx_ready(rx_ready),
    .frame_error(frame_error),
    .tx_data_out(tx_data_out),
    .rx_data_out(rx_data_out)
);

task send_byte;
    input [7:0] data;
    begin
        @(posedge clk);
        start = 1;
        tx_data_in = data;
        @(posedge clk);
        start = 0;
        
        // Wait for transmission to complete
        wait(!busy_tx);
        #100; // Small delay
    end
endtask

initial begin
    $dumpfile("uart_tb.vcd");
    $dumpvars(0, uart_tb);
    
    // Initialize
    clk = 0;
    rst = 1;
    start = 0;
    tx_data_in = 0;
    rx_data_in = 1; // IDLE state
    
    // Release reset
    #100;
    rst = 0;
    #100;
    
    $display("Testing UART...");
    
    // Test 1: Normal transmission
    $display("Test 1: TX 0x55");
    send_byte(8'h55);
    
    // Test 2: Another transmission
    $display("Test 2: TX 0xAA");
    send_byte(8'hAA);
    
    // Test 3: Verify RX is idle and ready
    if (!busy_rx) 
        $display("PASS: RX idle when no data");
    else
        $display("FAIL: RX busy when should be idle");
    
    $display("UART test completed");
    $finish;
end

endmodule

