module top(
    input  wire CLK100MHZ,
    input  wire CPU_RESETN,                 // 低有效复位
    input  wire [1:0] SW,
    output wire CA, CB, CC, CD, CE, CF, CG, DP,
    output wire [7:0] AN
);
    wire rst  = ~CPU_RESETN;                // 低有效按钮转成高有效复位
    wire en   = SW[1];
    wire mode = SW[0];

    // ================= 时基：统一在此产生，向下分发 =================
    wire tick_1ms, tick_1s, tick_10ms;
    tickgen #(.tick_freq(1000)) u_tick_1ms (   // 扫描节拍
        .clk(CLK100MHZ), .rst(rst), .en(1'b1), .tick(tick_1ms)
    );
    tickgen #(.tick_freq(1)) u_tick_1s (       // 走时节拍
        .clk(CLK100MHZ), .rst(rst), .en(en),   .tick(tick_1s)
    );
    tickgen #(.tick_freq(100)) u_tick_10ms (   // 秒表百分秒节拍
        .clk(CLK100MHZ), .rst(rst), .en(en),   .tick(tick_10ms)
    );

    wire [3:0] bcd0, bcd1, bcd2, bcd3, bcd4, bcd5;
    wire blink;

    eclock u_eclock(
        .clk      (CLK100MHZ),
        .rst      (rst),
        .tick_1s  (tick_1s),
        .tick_10ms(tick_10ms),
        .mode     (mode),
        .bcd0     (bcd0),
        .bcd1     (bcd1),
        .bcd2     (bcd2),
        .bcd3     (bcd3),
        .bcd4     (bcd4),
        .bcd5     (bcd5),
        .blink    (blink)
    );

    bcd_display6 u_dis6(
        .clk     (CLK100MHZ),
        .rst     (rst),
        .en (tick_1ms),
        .bcd0    (bcd0),
        .bcd1    (bcd1),
        .bcd2    (bcd2),
        .bcd3    (bcd3),
        .bcd4    (bcd4),
        .bcd5    (bcd5),
        .seg7    (AN),
        .h       ({CG, CF, CE, CD, CC, CB, CA})
    );

    assign DP = blink;                      // 1Hz 冒号闪烁，兼作时基准确性指示

endmodule
