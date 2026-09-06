`timescale 1ns / 1ps
module tb_top;
    reg  [3:0] A, B;
    reg  [2:0] ALUctr;
    wire [3:0] F;
    wire       cf, zero, of;

    integer checks = 0;
    integer errors = 0;

    alu_s uut (
        .A(A), .B(B), .ALUctr(ALUctr),
        .F(F), .cf(cf), .zero(zero), .of(of)
    );

    initial begin
        $dumpfile("build/top.vcd");
        $dumpvars(0, tb_top);
    end

    // 扫描用的操作数集合，覆盖边界情况：
    //   0   = 0           全零（触发 zero）
    //   1   = +1          触发进位/借位
    //   7   = +7          最大正数
    //   8   = -8          最小负数 / 无符号进位边界
    //   15  = -1          全 1（借位、符号比较边界）
    reg [3:0] sv [0:4];
    integer i, j, k;

    // 施加一个向量并自动比对（参考模型独立重算，不只依赖 DUT）
    task vec;
        input [3:0] a;
        input [3:0] b;
        input [2:0] op;
        reg  [4:0] t5;          // 5 位宽运算中间量，反映进位/借位
        reg  [3:0] eF;
        reg        ecf, ezero, eof;
        begin
            A = a; B = b; ALUctr = op; #20;   // 等组合逻辑稳定

            casez (op)
                3'b000: begin                 // A + B：5 位相加取进位
                    t5 = {1'b0, a} + {1'b0, b};
                    eF = t5[3:0]; ecf = t5[4];
                    eof   = (a[3]==b[3]) && (eF[3]!=a[3]);
                    ezero = ~|eF;
                end
                3'b001: begin                 // A - B：5 位相减，bit4 即借位
                    t5 = {1'b0, a} - {1'b0, b};
                    eF = t5[3:0]; ecf = t5[4];
                    eof   = (a[3]!=b[3]) && (eF[3]!=a[3]);
                    ezero = ~|eF;
                end
                3'b010: begin eF = ~a;                      ecf=0; ezero=0; eof=0; end
                3'b011: begin eF = a & b;                   ecf=0; ezero=0; eof=0; end
                3'b100: begin eF = a | b;                   ecf=0; ezero=0; eof=0; end
                3'b101: begin eF = a ^ b;                   ecf=0; ezero=0; eof=0; end
                3'b110: begin eF = ($signed(a) < $signed(b)) ? 4'd1 : 4'd0; ecf=0; ezero=0; eof=0; end
                3'b111: begin eF = (a == b) ? 4'd1 : 4'd0;  ecf=0; ezero=0; eof=0; end
            endcase

            checks = checks + 1;
            if (F !== eF || cf !== ecf || zero !== ezero || of !== eof) begin
                errors = errors + 1;
                $display("MISMATCH A=%h B=%h op=%b | got F=%h cf=%b z=%b of=%b | exp F=%h cf=%b z=%b of=%b",
                         a, b, op, F, cf, zero, of, eF, ecf, ezero, eof);
            end
        end
    endtask

    initial begin
        $display("=== alu_s self-check simulation ===");
        sv[0] = 4'd0;   // 0
        sv[1] = 4'd1;   // +1
        sv[2] = 4'd7;   // +7
        sv[3] = 4'd8;   // -8
        sv[4] = 4'd15;  // -1

        // 遍历操作数集合上的全部 8 种运算
        for (i = 0; i <= 4; i = i + 1)
            for (j = 0; j <= 4; j = j + 1) begin
                for (k = 0; k <= 7; k = k + 1)
                    vec(sv[i], sv[j], k[2:0]);
                #40;   // 每组 (A,B) 之间留空隙，便于查看波形
            end

        if (errors == 0)
            $display("\n[PASS] all %0d vectors OK.", checks);
        else
            $display("\n[FAIL] %0d / %0d vectors mismatched.", errors, checks);
        $finish;
    end
endmodule
