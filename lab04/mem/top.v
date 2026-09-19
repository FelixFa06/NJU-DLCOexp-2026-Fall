module top(
    input wire CLK100MHZ,
    input wire [12:0] SW,
    input wire BTNC,
    output wire CA,CB,CC,CD,CE,CF,CG,DP,
    output wire [7:0] AN
);

    //时基模块
    wire tick_1ms, tick_10ms;
    tickgen #(.tick_freq(1000)) u_tick_1ms(//数码管扫描时基
        .clk(CLK100MHZ), .rst(1'b0), .en(1'b1), .tick(tick_1ms)
    );
    tickgen #(.tick_freq(100)) u_tick_10ms(//按键消抖时基
        .clk(CLK100MHZ), .rst(1'b0), .en(1'b1), .tick(tick_10ms)
    );

    //按键消抖, 手动时钟信号
    wire clk;
    debounce btnc(
        .clk(CLK100MHZ),
        .tick_10ms(tick_10ms),
        .btn(BTNC),
        .btn_edge(clk)
    );

    //reg+ram 模块
    wire [7:0] dout1,dout2;
    mem mymem(
        .clk(clk),
        .we(SW[0]),
        .addr(SW[4:1]),
        .din(SW[12:5]),
        .dout1(dout1),
        .dout2(dout2)
    );

    //显示模块
    wire [6:0] h0,h1,h2,h3;
    hex7seg hex7seg0(dout1[3:0],h0);
    hex7seg hex7seg1(dout1[7:4],h1);
    hex7seg hex7seg2(dout2[3:0],h2);
    hex7seg hex7seg3(dout2[7:4],h3);
    display4 u_display(
        .clk(CLK100MHZ),
        .tick(tick_1ms),
        .h0(h0), .h1(h1), .h2(h2), .h3(h3),
        .seg7(AN),
        .h({CG,CF,CE,CD,CC,CB,CA})
    );
    assign DP=1'b1;

endmodule