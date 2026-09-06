module top(
    input wire [10:0] SW,
    output wire [10:0] LED,
	output wire CA, CB, CC, CD, CE, CF, CG, DP,
	output wire [7:0] AN
);

wire [3:0] F;

alu_s alu1(
    .A(SW[10:7]),
    .B(SW[6:3]),
    .ALUctr(SW[2:0]),
    .F(F),
    .cf(LED[0]),
    .zero(LED[1]),
    .of(LED[2])
);

bcd7seg bcd7seg1(
    .b((F^{4{F[3]}})+F[3]),
    .h({CG,CF,CE,CD,CC,CB,CA})
);

assign LED[10:7] = F;
assign LED[6:3] = 4'b0000;
assign DP=1'b1;
assign AN=8'b11111110;

endmodule