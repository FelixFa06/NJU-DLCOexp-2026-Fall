`timescale 1ns / 1ps
// lfsr 自检：手册示例序列 / 255 周期遍历 / 全零种子 / 换种子复测
module tb_top;
    reg  [7:0]  seed = 8'h01;
    reg         clk  = 1'b0;
    reg         load = 1'b0;
    wire [7:0]  dout;

    lfsr uut(.seed(seed), .clk(clk), .load(load), .dout(dout));

    always #5 clk = ~clk;

    integer     errors = 0, i, distinct = 0;
    reg [7:0]   seq [0:255];        // 遍历记录
    reg [255:0] seen;               // 出现过的状态位图
    reg [7:0]   exp1 [0:4];         // 手册示例：01 之后的 5 个状态
    reg [7:0]   ref;                // 测试台自己重算的参考序列

    initial begin
        $dumpfile("build/top.vcd");
        $dumpvars(0, tb_top);
    end

    // 装载种子：load 拉高一拍，之后转入移位；同时校验装载结果
    task load_seed(input [7:0] s, input [7:0] expect);
        begin
            @(negedge clk); seed = s; load = 1'b1;
            @(negedge clk); load = 1'b0;
            if (dout !== expect) begin
                errors = errors + 1;
                $display("  load %h: dout = %h, expect %h", s, dout, expect);
            end
        end
    endtask

    // 走一个时钟，取回新状态
    task step(output [7:0] v);
        begin
            @(posedge clk); #1; v = dout;
        end
    endtask

    initial begin
        exp1[0] = 8'h80; exp1[1] = 8'h40; exp1[2] = 8'h20;
        exp1[3] = 8'h10; exp1[4] = 8'h88;

        // 1. 手册给出的示例序列
        $display("--- case 1: manual example from 01 ---");
        load_seed(8'h01, 8'h01);
        for (i = 0; i < 5; i = i + 1) begin
            step(seq[0]);
            if (seq[0] !== exp1[i]) begin
                errors = errors + 1;
                $display("  step %0d: got %h, expect %h", i + 1, seq[0], exp1[i]);
            end
        end
        $display("  01 -> 80 -> 40 -> 20 -> 10 -> 88");
        repeat (4) @(negedge clk);

        // 2. 从 01 出发遍历整周期，逐拍与参考模型比对，并检查状态不重复
        $display("--- case 2: full period from 01 ---");
        load_seed(8'h01, 8'h01);
        ref  = 8'h01;
        seen = 256'd0;
        seen[8'h01] = 1'b1;
        distinct = 1;
        for (i = 1; i < 255; i = i + 1) begin
            step(seq[i]);
            ref = {ref[4] ^ ref[3] ^ ref[2] ^ ref[0], ref[7:1]};
            if (seq[i] !== ref) begin
                errors = errors + 1;
                $display("  step %0d: got %h, reference %h", i, seq[i], ref);
            end
            if (seq[i] === 8'h00) begin
                errors = errors + 1;
                $display("  zero state reached at step %0d", i);
            end
            if (seen[seq[i]]) begin
                errors = errors + 1;
                $display("  state %h repeated at step %0d", seq[i], i);
            end
            else
                distinct = distinct + 1;
            seen[seq[i]] = 1'b1;
        end
        step(seq[255]);
        if (seq[255] !== 8'h01) begin
            errors = errors + 1;
            $display("  step 255: got %h, expect return to 01", seq[255]);
        end
        $display("  covered %0d distinct nonzero states, back to 01 at step 255",
                 distinct);
        repeat (4) @(negedge clk);

        // 3. 全零种子：被替换成 01，不会锁死
        $display("--- case 3: all-zero seed ---");
        load_seed(8'h00, 8'h01);
        ref = 8'h01;
        for (i = 1; i < 5; i = i + 1) begin
            step(seq[0]);
            ref = {ref[4] ^ ref[3] ^ ref[2] ^ ref[0], ref[7:1]};
            if (seq[0] !== ref) begin
                errors = errors + 1;
                $display("  step %0d: got %h, reference %h", i, seq[0], ref);
            end
        end
        $display("  all-zero seed starts from 01 and shifts normally");
        repeat (4) @(negedge clk);

        // 4. 换一个非零种子，周期仍应为 255
        $display("--- case 4: another nonzero seed A5 ---");
        load_seed(8'hA5, 8'hA5);
        seen = 256'd0;
        seen[8'hA5] = 1'b1;
        distinct = 1;
        for (i = 1; i <= 255; i = i + 1) begin
            step(seq[0]);
            if (seq[0] === 8'h00) begin
                errors = errors + 1;
                $display("  zero state reached at step %0d", i);
            end
            if (!seen[seq[0]])
                distinct = distinct + 1;
            seen[seq[0]] = 1'b1;
        end
        if (seq[0] !== 8'hA5) begin
            errors = errors + 1;
            $display("  step 255: got %h, expect return to A5", seq[0]);
        end
        $display("  covered %0d distinct nonzero states, back to A5 at step 255",
                 distinct);
        repeat (4) @(negedge clk);

        if (errors == 0)
            $display("\n[PASS] all checks OK.");
        else
            $display("\n[FAIL] %0d checks failed.", errors);
        $finish;
    end
endmodule
