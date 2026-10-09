module encryption(
	input [63:0] seed,
	input clk,
	input load,
	input [7:0] datain,
	output reg ready,
	output [7:0] dataout
);

    reg [2:0] counter;
    always @(posedge clk) begin
        if (load) begin
            ready <= 1'b0;
            counter <= 3'd0;
        end
        else begin
            if (counter == 3'd5) begin
                ready <= 1'b1;
                counter <= 3'd0;
            end
            else begin
                ready <= 1'b0;
                counter <= counter + 3'd1;
            end
        end
    end

    reg [63:0] lfsr;
    always @(posedge clk) begin
        if (load)
            lfsr <= seed;
        else
            lfsr <= {lfsr[4]^lfsr[3]^lfsr[1]^lfsr[0],lfsr[63:1]};
    end

    assign dataout = datain ^ lfsr[63:58];

endmodule