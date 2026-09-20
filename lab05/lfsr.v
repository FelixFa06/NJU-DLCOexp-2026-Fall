module lfsr(
    input  [63:0]  seed,
	input  clk,
	input  load,
	output reg [63:0] dout
);
    
    always @(posedge clk) begin
        dout <= load ? seed : {dout[4]^dout[3]^dout[1]^dout[0], dout[63:1]};
    end

endmodule