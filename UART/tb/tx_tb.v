`timescale 1ns/1ps


module tx_tb;
    // These values help with simulation
    // 16 clock cycles per bit
    localparam CLOCK_FREQ = 1_843_200;
    localparam BAUD_RATE  = 115_200;
    localparam CLK_PERIOD_NS = 1_000_000_000 / CLOCK_FREQ;

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
    ) transmitter (   // Default params
        .clk     (clk),
        .rst     (rst),
        .start   (start),
        .data_in (data),
        .busy    (busy),
        .tx      (tx)
    );

    initial begin
        $dumpfile("uart_tx_tb.vcd");
        $dumpvars(0, tx_tb);

        clk = 0;
        rst = 0;
        start = 0;
        data = 8'b01010101;
        
        // After 5 clock cycles we send the data
        #(CLK_PERIOD_NS * 5) begin
            start = 1;
        end

        #(CLK_PERIOD_NS * 1) begin
            start = 0;
        end

        /* 
        * Over the next 10 bit periods the data will be sent. 
        * Each bit takes 16 base clock cycles. 
        * Therefore we need to wait clk_period_ns * 16 * 10 for the full data frame.
        */

        // wait(busy == 0);

        // Test reset
        #(CLK_PERIOD_NS * 16 * 11);
        // Reset 
        rst = 1;
        start = 0;

        #(CLK_PERIOD_NS * 2)
        rst = 0;
        start = 1;      // Send the data again

        #(CLK_PERIOD_NS * 16 * 11);
        $finish;
    end

endmodule
