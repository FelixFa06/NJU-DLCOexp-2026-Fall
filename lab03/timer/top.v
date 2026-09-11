module top(
    input CLK100MHZ,
    input [1:0] SW,
    output [0:0] LED,
    output [7:0] AN,
    output CA,CB,CC,CD,CE,CF,CG,DP
);

    wire clk_1,clk_1000;
    clkgen #(.clk_freq(1)) clkgen1(
        .clkin(CLK100MHZ),
        .rst(0),
        .clken(1),
        .clkout(clk_1)
    );
    clkgen #(.clk_freq(1000)) clkgen2(
        .clkin(CLK100MHZ),
        .rst(0),
        .clken(1),
        .clkout(clk_1000)
    );

    wire [5:0] Q;
    timer timer1(
        .clk(clk_1),
        .en(SW[0]),
        .rst(SW[1]),
        .Q(Q),
        .rco(LED[0])
    );

    display display1(
        .Q(Q),
        .select(clk_1000),
        .seg7(AN),
        .h({CG,CF,CE,CD,CC,CB,CA})
    );
    assign DP = 1'b1;

endmodule