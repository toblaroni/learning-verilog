// Blinker Test-Bench
// This is not synthesizeable

`timescale 1ns/1ps

module blinker_tb;

    reg clk;
    wire signal;

    blinker #(.SPEED(5)) led_blink (
        .clk(clk),
        .signal(signal)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("blinker.vcd");
        $dumpvars(0, blinker_tb);
        #10000000 $finish;
    end
endmodule
