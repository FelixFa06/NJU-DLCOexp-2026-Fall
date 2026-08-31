module exp1(
    input [1:0] X0,
	input [1:0] X1,
	input [1:0] X2,
	input [1:0] X3,
	input [1:0] Y,
	output reg [1:0] F
	);
    always @(*)
        case(Y)
            0: F=X0;
            1: F=X1;
            2: F=X2;
            3: F=X3;
        endcase
endmodule