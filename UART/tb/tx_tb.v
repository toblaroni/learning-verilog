`timescale 1ns/1ps

module tx_tb;
localparam CLOCK_FREQ = 1_843_200;
localparam BAUD_RATE  = 115_200;
localparam CLK_PERIOD_NS = 1_000_000_000 / CLOCK_FREQ;
localparam CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

reg clk;
reg rst;
reg start;
reg [7:0] data;

wire busy;
wire tx;

always #(CLK_PERIOD_NS / 2) clk = ~clk;

uart_tx #( 
    .BAUD_RATE (BAUD_RATE), 
    .CLOCK_FREQ (CLOCK_FREQ)
) transmitter (
    .clk     (clk),
    .rst     (rst),
    .start   (start),
    .data_in (data),
    .busy    (busy),
    .tx      (tx)
);

// Task to send one byte
task send_byte;
    input [7:0] tx_data;
    begin
        @(posedge clk);
        data = tx_data;
        start = 1;
        @(posedge clk);
        start = 0;
        
        // Wait for transmission to complete
        @(negedge busy);
        #(CLK_PERIOD_NS * CLKS_PER_BIT); // Wait one more bit time
    end
endtask

initial begin
    $dumpfile("uart_tx_tb.vcd");
    $dumpvars(0, tx_tb);

    // Initialize
    clk = 0;
    rst = 1;
    start = 0;
    data = 8'h00;
    
    // Release reset
    #(CLK_PERIOD_NS * 10);
    rst = 0;
    #(CLK_PERIOD_NS * 10);

    // Test 1: Simple pattern
    $display("Test 1: 0x55");
    send_byte(8'h55);
    check_idle("Test 1");
    
    // Test 2: Different pattern
    $display("Test 2: 0xCC");
    send_byte(8'hCC);
    check_idle("Test 2");
    
    // Test 3: All zeros
    $display("Test 3: 0x00");
    send_byte(8'h00);
    check_idle("Test 3");
    
    // Test 4: All ones
    $display("Test 4: 0xFF");
    send_byte(8'hFF);
    check_idle("Test 4");
    
    // Test 5: Reset during transmission
    $display("Test 5: Reset during transmission");
    data = 8'hAA;
    start = 1;
    @(posedge clk);
    start = 0;
    #(CLK_PERIOD_NS * CLKS_PER_BIT * 3); // Wait 3 bit times
    rst = 1;
    #(CLK_PERIOD_NS * 10);
    rst = 0;
    check_idle("Test 5");
    
    $display("All tests completed!");
    $finish;
end

task check_idle (input [8*100-1:0] test_name);
    begin
        if (tx === 1'b1 && busy === 1'b0)
            $display("SUCCESS: %s - TX idle", test_name);
        else
            $display("FAILURE: %s - TX not idle (tx=%b, busy=%b)", test_name, tx, busy);
    end
endtask

endmodule
