module hamming(
	input  [6:0] code,
	output reg [6:0] correct,
	output [2:0] parity
	);

assign parity = {code[3]^code[4]^code[5]^code[6],code[1]^code[2]^code[5]^code[6],code[0]^code[2]^code[4]^code[6]};
always @(*) begin
    correct = code;
    if (|parity)
        correct[parity-1]= correct[parity-1]^1;
end

endmodule