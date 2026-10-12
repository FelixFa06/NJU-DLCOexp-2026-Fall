`timescale 1ns/1ps
// PS/2 键盘模块自测：模拟键盘按参考激励码流发帧，检查 key_count / cur_key / ascii_key
module tb_top;
    reg clk = 1'b0;
    reg clrn;
    wire ps2_clk, ps2_data;
    wire [7:0] key_count, cur_key, ascii_key;
    reg kbd_clk = 1'b1, kbd_data = 1'b1;
    integer errors = 0;

    assign ps2_clk  = kbd_clk;
    assign ps2_data = kbd_data;

    keyboard dut(
        .clk(clk), .clrn(clrn),
        .ps2_clk(ps2_clk), .ps2_data(ps2_data),
        .key_count(key_count), .cur_key(cur_key), .ascii_key(ascii_key)
    );

    always #5 clk = ~clk;               // 100 MHz

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

    task check(input [7:0] ec, input [7:0] ek, input [7:0] ea);
        begin
            #2000;                      // 等 ascii_key 的寄存器延迟稳定
            if (key_count !== ec || cur_key !== ek || ascii_key !== ea) begin
                errors = errors + 1;
                $display("  FAIL: count=%0d(exp %0d) key=%02h(exp %02h) ascii=%02h(exp %02h)",
                         key_count, ec, cur_key, ek, ascii_key, ea);
            end
            else
                $display("  pass: count=%0d key=%02h ascii=%02h", key_count, cur_key, ascii_key);
        end
    endtask

    initial begin
        clrn = 1'b0; #200;
        clrn = 1'b1; #200;

        $display("press A (1C)");        send(8'h1C); check(8'd1, 8'h1C, 8'h61);
        $display("break F0");            send(8'hF0); check(8'd1, 8'h00, 8'h00);
        $display("release A (1C)");      send(8'h1C); check(8'd1, 8'h00, 8'h00);
        $display("press S (1B)");        send(8'h1B); check(8'd2, 8'h1B, 8'h73);
        $display("hold S (1B) #2");      send(8'h1B); check(8'd2, 8'h1B, 8'h73);
        $display("hold S (1B) #3");      send(8'h1B); check(8'd2, 8'h1B, 8'h73);
        $display("break F0");            send(8'hF0); check(8'd2, 8'h00, 8'h00);
        $display("release S (1B)");      send(8'h1B); check(8'd2, 8'h00, 8'h00);

        // 放开后重按同一个键，应再次计数
        $display("press A (1C) again");  send(8'h1C); check(8'd3, 8'h1C, 8'h61);
        $display("hold A (1C)");         send(8'h1C); check(8'd3, 8'h1C, 8'h61);
        $display("break F0");            send(8'hF0); check(8'd3, 8'h00, 8'h00);
        $display("release A (1C)");      send(8'h1C); check(8'd3, 8'h00, 8'h00);

        if (errors == 0) $display("==== ALL PASS ====");
        else             $display("==== %0d FAILED ====", errors);
        $finish;
    end
endmodule
