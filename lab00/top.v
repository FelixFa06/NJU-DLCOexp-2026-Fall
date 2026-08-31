module top (
    input  wire [1:0] SW,
    output wire [0:0] LED
);

    lab00 u_lab00 (
        .A(SW[0]),
        .B(SW[1]),
        .F(LED[0])
    );

endmodule
