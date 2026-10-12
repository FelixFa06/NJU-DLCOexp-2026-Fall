module top(
    input CLK100MHZ,
    input CPU_RESETN,
    input PS2_CLK,
    input PS2_DATA,
    output [7:0] AN,
    output CA,CB,CC,CD,CE,CF,CG,DP
);

    //时基生成模块
    wire tick_1ms;
    tickgen #(.tick_freq(1000)) u_tick_1ms (//数码管扫描时基
        .clk(CLK100MHZ), .rst(1'b0), .en(1'b1), .tick(tick_1ms)
    );

    //核心逻辑-keyboard模块
    wire [7:0] key_count;
    wire [7:0] cur_key;
    wire [7:0] ascii_key;
    keyboard u_keyboard(
        .clk(CLK100MHZ),
        .clrn(CPU_RESETN),
        .ps2_clk(PS2_CLK),
        .ps2_data(PS2_DATA),
        .key_count(key_count),
        .cur_key(cur_key),
        .ascii_key(ascii_key)
    );

    //数码管显示模块
    wire [6:0] h0,h1,h2,h3,h4,h5;
    hex7seg hex7seg0(cur_key[3:0], h0);
    hex7seg hex7seg1(cur_key[7:4], h1);
    hex7seg hex7seg2(ascii_key[3:0], h2);
    hex7seg hex7seg3(ascii_key[7:4], h3);
    hex7seg hex7seg4(key_count[3:0], h4);
    hex7seg hex7seg5(key_count[7:4], h5);

    wire dis4;
    assign dis4 = (cur_key != 8'd0);

    display6_4 u_display(
        .clk(CLK100MHZ),
        .tick_1ms(tick_1ms),
        .dis4(dis4),
        .h0(h0), .h1(h1),
        .h2(h2), .h3(h3),
        .h4(h4), .h5(h5),
        .seg7(AN),
        .h({CG,CF,CE,CD,CC,CB,CA})
    );
    assign DP=1'b1;

endmodule