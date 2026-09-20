module top(
    input CLK100MHZ,
    input [8:0] SW,
    input BTNC,
    output [7:0] AN,
    output CA,CB,CC,CD,CE,CF,CG,DP
);

    //时基生成模块
    wire tick_1ms, tick_10ms;
    tickgen #(.tick_freq(1000)) u_tick_1ms (//数码管扫描时基
        .clk(CLK100MHZ), .rst(1'b0), .en(1'b1), .tick(tick_1ms)
    );
    tickgen #(.tick_freq(100)) u_tick_10ms (//按键消抖时基
        .clk(CLK100MHZ), .rst(1'b0), .en(1'b1), .tick(tick_10ms)
    );

    //按键消抖模块
    wire BTNC_edge;
    debounce d_btnc(
        .clk(CLK100MHZ),
        .tick_10ms(tick_10ms),
        .btn(BTNC),
        .btn_edge(BTNC_edge)
    );
    
    //核心逻辑-LFSR模块
    wire [7:0] dout;
    lfsr u_lfsr(
        .seed(SW[8:1]),
        .clk(BTNC_edge),
        .load(SW[0]),
        .dout(dout)
    );

    //数码管显示模块
    wire [6:0] h0,h1;
    hex7seg hex7seg0(dout[3:0], h0);
    hex7seg hex7seg1(dout[7:4], h1);
    display2 u_display(
        .clk(CLK100MHZ),
        .tick_1ms(tick_1ms),
        .h0(h0),
        .h1(h1),
        .seg7(AN),
        .h({CG,CF,CE,CD,CC,CB,CA})
    );
    assign DP=1'b1;

endmodule