`timescale 1ns / 1ps
module tb_top;
    reg  [7:0] X;
    reg        en;
    wire       valid;
    wire [2:0] Z;
    wire [6:0] F;
    wire [7:0] AN;
    wire       DP;

    exp2 uut (
        .X(X), .en(en), .valid(valid), .Z(Z),
        .F(F), .AN(AN), .DP(DP)
    );

    initial begin
        $dumpfile("build/top.vcd");
        $dumpvars(0, tb_top);
    end

    initial begin
        en = 1'b1;
        X = 8'b10000000; #100;   // 最高优先级 -> Y=111
        X = 8'b01000000; #100;   // -> 110
        X = 8'b00100000; #100;   // -> 101
        X = 8'b00010000; #100;   // -> 100
        X = 8'b00001000; #100;   // -> 011
        X = 8'b00000100; #100;   // -> 010
        X = 8'b00000010; #100;   // -> 001
        X = 8'b00000001; #100;   // -> 000
        X = 8'b00100100; #100;   // 多个 1，最高优先 -> 101
        X = 8'b00000000; #100;   // 全 0 -> valid=0
        en = 1'b0; X = 8'b10000000; #100;  // 未使能 -> valid=0
        #100; $finish;
    end
endmodule
