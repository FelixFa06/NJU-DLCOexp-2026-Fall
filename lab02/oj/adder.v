module adder(
	input  [3:0] A,
	input  [3:0] B,
	input  addsub,
	output [3:0] F,
	output cf,
	output zero,
	output of
	);

wire cout;
wire [3:0] B_;

assign B_ = B^{4{addsub}};
assign {cout,F} = A+B_+addsub;
assign cf = cout^addsub;
assign of = (F[3]!=A[3]) && (A[3]==B_[3]);
assign zero = (F==4'b0000);

endmodule