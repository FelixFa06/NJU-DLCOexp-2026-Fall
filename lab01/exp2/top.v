module top (
    input  wire [8:0] SW,
    output wire [4:0] LED,
    output wire       CA, CB, CC, CD, CE, CF, CG,
    output wire       DP,
    output wire [7:0] AN
);

    exp2 u_exp2 (
        .X     (SW[7:0]),
        .en    (SW[8]),
        .valid (LED[4]),
        .Z     (LED[2:0]),
        .F     ({CG, CF, CE, CD, CC, CB, CA}),
        .AN    (AN),
        .DP    (DP)
    );

    assign LED[3] = 1'b0;

endmodule
