module exp2(
	input  [7:0] X,
	input  en,
	output reg valid,
	output [2:0] Z, 
	output [6:0] F,
	output [7:0] AN,
	output DP
	);

	reg [3:0] Y;
    always @(*)
		if (en) begin
			casez(X)
				8'b1???????: begin Y=4'b0111; valid=1'b1; end
				8'b01??????: begin Y=4'b0110; valid=1'b1; end
				8'b001?????: begin Y=4'b0101; valid=1'b1; end
				8'b0001????: begin Y=4'b0100; valid=1'b1; end
				8'b00001???: begin Y=4'b0011; valid=1'b1; end
				8'b000001??: begin Y=4'b0010; valid=1'b1; end
				8'b0000001?: begin Y=4'b0001; valid=1'b1; end
				8'b00000001: begin Y=4'b0000; valid=1'b1; end
				default: begin Y=4'b1111; valid=1'b0; end
			endcase
		end
		else begin
			Y=4'b1111; valid=1'b0;
		end
	bcd7seg b1(Y,F);
	assign Z[2]=Y[2]&valid;
	assign Z[1]=Y[1]&valid;
	assign Z[0]=Y[0]&valid;
	assign AN=8'b11111110;
	assign DP=1'b1;

endmodule

module bcd7seg(
    input  [3:0] b,
    output reg [6:0] h
);

    always @(*) begin
        case (b)
            4'd0:    h = 7'b1000000;
            4'd1:    h = 7'b1111001;
            4'd2:    h = 7'b0100100;
            4'd3:    h = 7'b0110000;
            4'd4:    h = 7'b0011001;
            4'd5:    h = 7'b0010010;
            4'd6:    h = 7'b0000010;
            4'd7:    h = 7'b1111000;
			4'd8:    h = 7'b0000000;
			4'd9:	 h = 7'b0000100;
            default: h = 7'b1111111;
        endcase
    end

endmodule
