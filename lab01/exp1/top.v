module top (
    input  wire [9:0] SW,
    output wire [1:0] LED
);

    exp1 u_exp1 (
        .X0(SW[3:2]),
        .X1(SW[5:4]),
        .X2(SW[7:6]),
        .X3(SW[9:8]),
        .Y (SW[1:0]),
        .F (LED[1:0])
    );

endmodule
