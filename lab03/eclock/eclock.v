module eclock(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire rst_sw,
    input  wire en_sw,
    input  wire tick_1s,
    input  wire tick_10ms,
    input  wire tick_100ms,
    input  wire set_edge,
    input  wire up_edge,
    input  wire down_edge,
    input  wire mode,
    input  wire en_alarm,
    input  wire [3:0] alarm_bcd0,
    input  wire [3:0] alarm_bcd1,
    output wire [3:0] bcd0,
    output wire [3:0] bcd1,
    output wire [3:0] bcd2,
    output wire [3:0] bcd3,
    output wire [3:0] bcd4,
    output wire [3:0] bcd5,
    output reg alarm
);

    // 调时模块
    wire up_s, down_s, up_m, down_m, up_h, down_h;
    set_signal set1(
        clk, set_edge, up_edge, down_edge, mode, 
        up_s, down_s, up_m, down_m, up_h, down_h
    );

    // ================= 时钟计数链：秒 → 分 → 时 =================
    wire [3:0] clk_s0, clk_s1, clk_m0, clk_m1, clk_h0, clk_h1;
    wire carry_s2m, carry_m2h;
    wire borrow_s2m, borrow_m2h;

    bcd_count2 #(.max1(5), .max0(9)) u_clk_sec (      // 00..59
        .clk(clk), .rst(rst), .en_up(tick_1s && en || up_s), .en_down(down_s), 
        .bcd0(clk_s0), .bcd1(clk_s1), .carry(carry_s2m), .borrow(borrow_s2m)
    );

    bcd_count2 #(.max1(5), .max0(9)) u_clk_min (      // 00..59
        .clk(clk), .rst(rst), .en_up(carry_s2m || up_m), .en_down(borrow_s2m || down_m), 
        .bcd0(clk_m0), .bcd1(clk_m1), .carry(carry_m2h), .borrow(borrow_m2h)
    );

    bcd_count2 #(.max1(2), .max0(3)) u_clk_hour (     // 00..23
        .clk(clk), .rst(rst), .en_up(carry_m2h || up_h), .en_down(borrow_m2h || down_h), 
        .bcd0(clk_h0), .bcd1(clk_h1), .carry(), .borrow()
    );

    // 闹钟模块
    reg blink;
    always @(posedge clk) begin
        if (tick_100ms)
            blink <= ~blink;
    end
    always @(posedge clk) begin
        if (mode==0 && en_alarm && alarm_bcd0==clk_h0 && 
        alarm_bcd1==clk_h1 && clk_m0 == 0 && clk_m1 == 0)
            alarm <= blink;
        else
            alarm <= 0;
    end

    // ================= 秒表计数链：百分秒 → 秒 → 分 =================
    wire [3:0] sw_f0, sw_f1, sw_s0, sw_s1, sw_m0, sw_m1;
    wire carry_f2s, carry_s2m_sw;

    bcd_count2 #(.max1(9), .max0(9)) u_sw_frac (      // 00..99 百分秒
        .clk(clk), .rst(rst_sw), .en_up(tick_10ms && en_sw), .en_down(1'b0), 
        .bcd0(sw_f0), .bcd1(sw_f1), .carry(carry_f2s), .borrow()
    );

    bcd_count2 #(.max1(5), .max0(9)) u_sw_sec (       // 00..59
        .clk(clk), .rst(rst_sw), .en_up(carry_f2s), .en_down(1'b0), 
        .bcd0(sw_s0), .bcd1(sw_s1), .carry(carry_s2m_sw), .borrow()
    );

    bcd_count2 #(.max1(5), .max0(9)) u_sw_min (       // 00..59
        .clk(clk), .rst(rst_sw), .en_up(carry_s2m_sw), .en_down(1'b0), 
        .bcd0(sw_m0), .bcd1(sw_m1), .carry(), .borrow()
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

module set_signal(
    input clk,
    input set_edge,
    input up_edge,
    input down_edge,
    input mode,
    output up_s,
    output down_s,
    output up_m,
    output down_m,
    output up_h,
    output down_h
);
    reg [1:0] set;
    always @(posedge clk)
        if (set_edge)
            set <= set==2'd2 ? 2'd0 : set+2'd1;
    
    assign up_s = mode==1'b0 && set==2'd0 && up_edge;
    assign down_s = mode==1'b0 && set==2'd0 && down_edge;
    assign up_m = mode==1'b0 && set==2'd1 && up_edge;
    assign down_m = mode==1'b0 && set==2'd1 && down_edge;
    assign up_h = mode==1'b0 && set==2'd2 && up_edge;
    assign down_h = mode==1'b0 && set==2'd2 && down_edge;
endmodule