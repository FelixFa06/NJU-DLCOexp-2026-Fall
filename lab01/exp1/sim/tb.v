`timescale 1ns / 1ps
module tb_top;
    reg  [1:0] X0, X1, X2, X3, Y;
    wire [1:0] F;

    exp1 uut (
        .X0(X0), .X1(X1), .X2(X2), .X3(X3),
        .Y(Y), .F(F)
    );

    initial begin
        $dumpfile("build/top.vcd");
        $dumpvars(0, tb_top);
    end

    initial begin
        X0 = 2'b00; X1 = 2'b01; X2 = 2'b10; X3 = 2'b11;
        Y = 2'b00; #100;   // 选 X0 -> F=00
        Y = 2'b01; #100;   // 选 X1 -> F=01
        Y = 2'b10; #100;   // 选 X2 -> F=10
        Y = 2'b11; #100;   // 选 X3 -> F=11
        Y = 2'b00; #100;   // 恢复 Y，让 Y=11 这一段有明确边界
        $finish;
    end
endmodule
