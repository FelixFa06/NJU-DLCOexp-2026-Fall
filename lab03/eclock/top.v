module top(
    input  wire CLK100MHZ,
    input  wire CPU_RESETN,                 // 低有效复位
    input  wire BTNR,
    input  wire BTNC,
    input  wire BTNL,
    input  wire BTNU,
    input  wire BTND,
    input  wire [10:0] SW,
    output wire [0:0] LED,
    output wire CA, CB, CC, CD, CE, CF, CG, DP,
    output wire [7:0] AN
);
    wire rst  = ~CPU_RESETN;                // 低有效按钮转成高有效复位
    wire en   = SW[1];
    wire mode = SW[0];

    // ================= 时基：统一在此产生，向下分发 =================
    wire tick_1ms, tick_1s, tick_10ms, tick_100ms;
    tickgen #(.tick_freq(1000)) u_tick_1ms (   // 扫描节拍
        .clk(CLK100MHZ), .rst(rst), .en(1'b1), .tick(tick_1ms)
    );
    tickgen #(.tick_freq(1)) u_tick_1s (       // 走时节拍
        .clk(CLK100MHZ), .rst(rst), .en(1'b1),   .tick(tick_1s)
    );
    tickgen #(.tick_freq(100)) u_tick_10ms (   // 秒表百分秒节拍
        .clk(CLK100MHZ), .rst(rst), .en(1'b1),   .tick(tick_10ms)
    );
    tickgen #(.tick_freq(10)) u_tick_100ms (   // 闹钟闪烁节拍
        .clk(CLK100MHZ), .rst(rst), .en(1'b1),   .tick(tick_100ms)
    );

    // 按键消抖
    wire BTNC_edge, BTNR_edge, BTNL_edge, BTNU_edge, BTND_edge;
    debounce btnc(
        .clk(CLK100MHZ),
        .tick_10ms(tick_10ms),
        .btn(BTNC),
        .btn_edge(BTNC_edge)
    );
    debounce btnr(
        .clk(CLK100MHZ),
        .tick_10ms(tick_10ms),
        .btn(BTNR),
        .btn_edge(BTNR_edge)
    );
    debounce btnl(
        .clk(CLK100MHZ),
        .tick_10ms(tick_10ms),
        .btn(BTNL),
        .btn_edge(BTNL_edge)
    );
    debounce btnu(
        .clk(CLK100MHZ),
        .tick_10ms(tick_10ms),
        .btn(BTNU),
        .btn_edge(BTNU_edge)
    );
    debounce btnd(
        .clk(CLK100MHZ),
        .tick_10ms(tick_10ms),
        .btn(BTND),
        .btn_edge(BTND_edge)
    );

    // 秒表控制信号
    sw_signal sw1(
        .clk(CLK100MHZ),
        .rst(rst),
        .tick_10ms(tick_10ms),
        .rst_edge(BTNR_edge),
        .en_edge(BTNC_edge),
        .rst_sw(rst_sw),
        .en_sw(en_sw)
    );

    wire [3:0] bcd0, bcd1, bcd2, bcd3, bcd4, bcd5;

    eclock u_eclock(
        .clk      (CLK100MHZ),
        .rst      (rst),
        .en       (en),
        .rst_sw   (rst_sw),
        .en_sw    (en_sw),
        .tick_1s  (tick_1s),
        .tick_10ms(tick_10ms),
        .tick_100ms(tick_100ms),
        .set_edge (BTNL_edge),
        .up_edge  (BTNU_edge),
        .down_edge(BTND_edge), 
        .mode     (mode),
        .en_alarm (SW[2]),
        .alarm_bcd0(SW[6:3]),
        .alarm_bcd1(SW[10:7]),
        .bcd0     (bcd0),
        .bcd1     (bcd1),
        .bcd2     (bcd2),
        .bcd3     (bcd3),
        .bcd4     (bcd4),
        .bcd5     (bcd5),
        .alarm    (LED[0])
    );

    bcd_display6 u_dis6(
        .clk     (CLK100MHZ),
        .rst     (rst),
        .en      (tick_1ms),
        .bcd0    (bcd0),
        .bcd1    (bcd1),
        .bcd2    (bcd2),
        .bcd3    (bcd3),
        .bcd4    (bcd4),
        .bcd5    (bcd5),
        .seg7    (AN),
        .h       ({CG, CF, CE, CD, CC, CB, CA})
    );

    assign DP=1'b1;

endmodule