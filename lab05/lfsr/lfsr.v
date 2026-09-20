module lfsr(
    input  [7:0]  seed,
	input  clk,
	input  load,
	output reg [7:0] dout
);
    
    wire [7:0] init = seed | {7'b0, ~|seed};

    always @(posedge clk) begin
        dout <= load ? init : {dout[4]^dout[3]^dout[2]^dout[0], dout[7:1]};
    end

endmodule