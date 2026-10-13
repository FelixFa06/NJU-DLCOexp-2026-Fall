`timescale 1ns/1ps
// PS/2 键盘模块自测：模拟键盘按参考激励码流发帧，检查 key_count / cur_key / ascii_key / 修饰键状态
module tb_top;
    reg clk = 1'b0;
    reg clrn;
    wire ps2_clk, ps2_data;
    wire [7:0] key_count, cur_key, ascii_key;
    wire l_shift, ctrl, l_alt, caps;
    reg kbd_clk = 1'b1, kbd_data = 1'b1;
    integer errors = 0;

    assign ps2_clk  = kbd_clk;
    assign ps2_data = kbd_data;

    keyboard dut(
        .clk(clk), .clrn(clrn),
        .ps2_clk(ps2_clk), .ps2_data(ps2_data),
        .l_shift(l_shift), .ctrl(ctrl), .l_alt(l_alt), .caps(caps),
        .key_count(key_count), .cur_key(cur_key), .ascii_key(ascii_key)
    );

    always #5 clk = ~clk;               // 100 MHz

    localparam NOMOD = 4'b0000;         // {l_shift, ctrl, l_alt, caps}

    task tx_bit(input b);
        begin
            kbd_data = b;
            #1000 kbd_clk = 1'b0;       // 下降沿，DUT 采样
            #1000 kbd_clk = 1'b1;
        end
    endtask

    task send(input [7:0] d);
        integer i;
        begin
            tx_bit(1'b0);               // 起始位
            for (i = 0; i < 8; i = i + 1)
                tx_bit(d[i]);           // 8 位数据，LSB 先出
            tx_bit(~^d);                // 奇校验
            tx_bit(1'b1);               // 停止位
            #20000;                     // 帧间隔
        end
    endtask

    task chk(input [7:0] ec, input [7:0] ek, input [7:0] ea, input [3:0] em);
        begin
            #2000;                      // 等 ascii_key 的两级寄存器延迟稳定
            if (key_count !== ec || cur_key !== ek || ascii_key !== ea ||
                {l_shift, ctrl, l_alt, caps} !== em) begin
                errors = errors + 1;
                $display("  FAIL: cnt=%0d(exp %0d) key=%02h(exp %02h) asc=%02h(exp %02h) mod=%b(exp %b)",
                         key_count, ec, cur_key, ek, ascii_key, ea,
                         {l_shift, ctrl, l_alt, caps}, em);
            end
            else
                $display("  pass: cnt=%0d key=%02h asc=%02h mod=%b",
                         key_count, cur_key, ascii_key, {l_shift, ctrl, l_alt, caps});
        end
    endtask

    initial begin
        clrn = 1'b0; #200;
        clrn = 1'b1; #200;

        // ---- 基本要求回归：无修饰键 ----
        $display("press A (1C)");         send(8'h1C); chk(8'd1, 8'h1C, 8'h61, NOMOD);
        $display("hold A (1C) #2");       send(8'h1C); chk(8'd1, 8'h1C, 8'h61, NOMOD);
        $display("break F0");             send(8'hF0); chk(8'd1, 8'h00, 8'h00, NOMOD);
        $display("release A (1C)");       send(8'h1C); chk(8'd1, 8'h00, 8'h00, NOMOD);
        $display("press A (1C) again");   send(8'h1C); chk(8'd2, 8'h1C, 8'h61, NOMOD);
        $display("break F0");             send(8'hF0); chk(8'd2, 8'h00, 8'h00, NOMOD);
        $display("release A (1C)");       send(8'h1C); chk(8'd2, 8'h00, 8'h00, NOMOD);

        // ---- Shift + 字母：不移出 IDLE，按住期间字符键照常计数 ----
        $display("press LShift (12)");    send(8'h12); chk(8'd2, 8'h00, 8'h00, 4'b1000);
        $display("press A (1C)");         send(8'h1C); chk(8'd3, 8'h1C, 8'h41, 4'b1000);
        $display("hold A (1C)");          send(8'h1C); chk(8'd3, 8'h1C, 8'h41, 4'b1000);
        $display("break F0");             send(8'hF0); chk(8'd3, 8'h00, 8'h00, 4'b1000);
        $display("release A (1C)");       send(8'h1C); chk(8'd3, 8'h00, 8'h00, 4'b1000);
        $display("break F0");             send(8'hF0); chk(8'd3, 8'h00, 8'h00, 4'b1000);
        $display("release LShift (12)");  send(8'h12); chk(8'd3, 8'h00, 8'h00, NOMOD);

        // ---- Shift + 数字：上档符号 ----
        $display("press LShift (12)");    send(8'h12); chk(8'd3, 8'h00, 8'h00, 4'b1000);
        $display("press 1 (16)");         send(8'h16); chk(8'd4, 8'h16, 8'h21, 4'b1000);
        $display("break F0");             send(8'hF0); chk(8'd4, 8'h00, 8'h00, 4'b1000);
        $display("release 1 (16)");       send(8'h16); chk(8'd4, 8'h00, 8'h00, 4'b1000);
        $display("break F0");             send(8'hF0); chk(8'd4, 8'h00, 8'h00, 4'b1000);
        $display("release LShift (12)");  send(8'h12); chk(8'd4, 8'h00, 8'h00, NOMOD);

        // ---- Caps Lock：翻转一次，按住不放不重复翻转 ----
        $display("press Caps (58)");      send(8'h58); chk(8'd4, 8'h00, 8'h00, 4'b0001);
        $display("break F0");             send(8'hF0); chk(8'd4, 8'h00, 8'h00, 4'b0001);
        $display("release Caps (58)");    send(8'h58); chk(8'd4, 8'h00, 8'h00, 4'b0001);
        $display("press A (1C)");         send(8'h1C); chk(8'd5, 8'h1C, 8'h41, 4'b0001);
        $display("break F0");             send(8'hF0); chk(8'd5, 8'h00, 8'h00, 4'b0001);
        $display("release A (1C)");       send(8'h1C); chk(8'd5, 8'h00, 8'h00, 4'b0001);

        // ---- Caps + Shift 同时：抵消回小写 ----
        $display("press LShift (12)");    send(8'h12); chk(8'd5, 8'h00, 8'h00, 4'b1001);
        $display("press A (1C)");         send(8'h1C); chk(8'd6, 8'h1C, 8'h61, 4'b1001);
        $display("break F0");             send(8'hF0); chk(8'd6, 8'h00, 8'h00, 4'b1001);
        $display("release A (1C)");       send(8'h1C); chk(8'd6, 8'h00, 8'h00, 4'b1001);
        $display("break F0");             send(8'hF0); chk(8'd6, 8'h00, 8'h00, 4'b1001);
        $display("release LShift (12)");  send(8'h12); chk(8'd6, 8'h00, 8'h00, 4'b0001);
        $display("press Caps (58)");      send(8'h58); chk(8'd6, 8'h00, 8'h00, NOMOD);
        $display("break F0");             send(8'hF0); chk(8'd6, 8'h00, 8'h00, NOMOD);
        $display("release Caps (58)");    send(8'h58); chk(8'd6, 8'h00, 8'h00, NOMOD);
        $display("press A (1C)");         send(8'h1C); chk(8'd7, 8'h1C, 8'h61, NOMOD);
        $display("break F0");             send(8'hF0); chk(8'd7, 8'h00, 8'h00, NOMOD);
        $display("release A (1C)");       send(8'h1C); chk(8'd7, 8'h00, 8'h00, NOMOD);

        // ---- Ctrl / Alt：只置 LED，不计入 key_count ----
        $display("press LCtrl (14)");     send(8'h14); chk(8'd7, 8'h00, 8'h00, 4'b0100);
        $display("break F0");             send(8'hF0); chk(8'd7, 8'h00, 8'h00, 4'b0100);
        $display("release LCtrl (14)");   send(8'h14); chk(8'd7, 8'h00, 8'h00, NOMOD);
        $display("press LAlt (11)");      send(8'h11); chk(8'd7, 8'h00, 8'h00, 4'b0010);
        $display("break F0");             send(8'hF0); chk(8'd7, 8'h00, 8'h00, 4'b0010);
        $display("release LAlt (11)");    send(8'h11); chk(8'd7, 8'h00, 8'h00, NOMOD);

        // ---- Caps 不影响数字：caps 置位时按数字 1 仍是 31 ----
        // （本段置于最末，走完 caps 保持置位，测试即结束）
        $display("press Caps (58)");      send(8'h58); chk(8'd7, 8'h00, 8'h00, 4'b0001);
        $display("break F0");             send(8'hF0); chk(8'd7, 8'h00, 8'h00, 4'b0001);
        $display("release Caps (58)");    send(8'h58); chk(8'd7, 8'h00, 8'h00, 4'b0001);
        $display("press 1 (16) caps on"); send(8'h16); chk(8'd8, 8'h16, 8'h31, 4'b0001);
        $display("break F0");             send(8'hF0); chk(8'd8, 8'h00, 8'h00, 4'b0001);
        $display("release 1 (16)");       send(8'h16); chk(8'd8, 8'h00, 8'h00, 4'b0001);

        if (errors == 0) $display("==== ALL PASS ====");
        else             $display("==== %0d FAILED ====", errors);
        $finish;
    end
endmodule
