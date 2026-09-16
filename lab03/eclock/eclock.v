module eclock(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire rst_sw,
    input  wire en_sw,
    input  wire tick_1s,
    input  wire tick_10ms,
    input  wire mode,
    output wire [3:0] bcd0,
    output wire [3:0] bcd1,
    output wire [3:0] bcd2,
    output wire [3:0] bcd3,
    output wire [3:0] bcd4,
    output wire [3:0] bcd5
);

    // ================= 时钟计数链：秒 → 分 → 时 =================
    wire [3:0] clk_s0, clk_s1, clk_m0, clk_m1, clk_h0, clk_h1;
    wire carry_s2m, carry_m2h;

    bcd_count2 #(.max1(5), .max0(9)) u_clk_sec (      // 00..59
        .clk(clk), .rst(rst), .en(tick_1s && en),
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
        .clk(clk), .rst(rst_sw), .en(tick_10ms && en_sw),
        .bcd0(sw_f0), .bcd1(sw_f1), .carry(carry_f2s)
    );

    bcd_count2 #(.max1(5), .max0(9)) u_sw_sec (       // 00..59
        .clk(clk), .rst(rst_sw), .en(carry_f2s),
        .bcd0(sw_s0), .bcd1(sw_s1), .carry(carry_s2m_sw)
    );

    bcd_count2 #(.max1(5), .max0(9)) u_sw_min (       // 00..59
        .clk(clk), .rst(rst_sw), .en(carry_s2m_sw),
        .bcd0(sw_m0), .bcd1(sw_m1), .carry()
    );

    // ================= 显示源选择 =================
    assign bcd0 = !rst ? (mode ? sw_f0 : clk_s0) : 4'd10;
    assign bcd1 = !rst ? (mode ? sw_f1 : clk_s1) : 4'd10;
    assign bcd2 = !rst ? (mode ? sw_s0 : clk_m0) : 4'd10;
    assign bcd3 = !rst ? (mode ? sw_s1 : clk_m1) : 4'd10;
    assign bcd4 = !rst ? (mode ? sw_m0 : clk_h0) : 4'd10;
    assign bcd5 = !rst ? (mode ? sw_m1 : clk_h1) : 4'd10;

endmodule


module sw_signal(
    input clk,
    input rst,
    input tick_10ms,
    input rst_edge,
    input en_edge,
    output rst_sw,
    output en_sw
);
    reg en0_sw;
    assign rst_sw = rst | rst_edge;
    always @(posedge clk) begin
        if (rst_sw)
            en0_sw <= 1'b0;
        else if (en_edge)
            en0_sw <= ~en0_sw;
    end
    assign en_sw = en0_sw;
endmodule