module eclock(
    input  wire clk,
    input  wire rst,
    input  wire tick_1s,
    input  wire tick_10ms,
    input  wire mode,
    output wire [3:0] bcd0,
    output wire [3:0] bcd1,
    output wire [3:0] bcd2,
    output wire [3:0] bcd3,
    output wire [3:0] bcd4,
    output wire [3:0] bcd5,
    output wire blink           // 1Hz 方波（时基心跳 / 冒号）
);

    // 1Hz 方波：每秒翻转一次，上板可用来目视确认时基是否准确
    reg blink_r;
    always @(posedge clk)
        if (rst)          blink_r <= 1'b0;
        else if (tick_1s) blink_r <= ~blink_r;

    assign blink = blink_r;

    // ================= 时钟计数链：秒 → 分 → 时 =================
    wire [3:0] clk_s0, clk_s1, clk_m0, clk_m1, clk_h0, clk_h1;
    wire carry_s2m, carry_m2h;

    bcd_count2 #(.max1(5), .max0(9)) u_clk_sec (      // 00..59
        .clk(clk), .rst(rst), .en(tick_1s),
        .bcd0(clk_s0), .bcd1(clk_s1), .carry(carry_s2m)
    );

    bcd_count2 #(.max1(5), .max0(9)) u_clk_min (      // 00..59
        .clk(clk), .rst(rst), .en(carry_s2m),
        .bcd0(clk_m0), .bcd1(clk_m1), .carry(carry_m2h)
    );

    bcd_count2 #(.max1(2), .max0(3)) u_clk_hour (     // 00..23
        .clk(clk), .rst(rst), .en(carry_m2h),
        .bcd0(clk_h0), .bcd1(clk_h1), .carry()
    );

    // ================= 秒表计数链：百分秒 → 秒 → 分 =================
    wire [3:0] sw_f0, sw_f1, sw_s0, sw_s1, sw_m0, sw_m1;
    wire carry_f2s, carry_s2m_sw;

    bcd_count2 #(.max1(9), .max0(9)) u_sw_frac (      // 00..99 百分秒
        .clk(clk), .rst(rst), .en(tick_10ms),
        .bcd0(sw_f0), .bcd1(sw_f1), .carry(carry_f2s)
    );

    bcd_count2 #(.max1(5), .max0(9)) u_sw_sec (       // 00..59
        .clk(clk), .rst(rst), .en(carry_f2s),
        .bcd0(sw_s0), .bcd1(sw_s1), .carry(carry_s2m_sw)
    );

    bcd_count2 #(.max1(5), .max0(9)) u_sw_min (       // 00..59
        .clk(clk), .rst(rst), .en(carry_s2m_sw),
        .bcd0(sw_m0), .bcd1(sw_m1), .carry()
    );

    // ================= 显示源选择 =================
    assign bcd0 = mode ? sw_f0 : clk_s0;
    assign bcd1 = mode ? sw_f1 : clk_s1;
    assign bcd2 = mode ? sw_s0 : clk_m0;
    assign bcd3 = mode ? sw_s1 : clk_m1;
    assign bcd4 = mode ? sw_m0 : clk_h0;
    assign bcd5 = mode ? sw_m1 : clk_h1;

endmodule
