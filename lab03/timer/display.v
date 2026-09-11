module display(
    input [5:0] Q,
    input select,
    output reg [7:0] seg7,
    output reg [6:0] h
);
    wire [3:0] out_dis0, out_dis1;
    wire [6:0] h0, h1;
    assign out_dis0 = Q%10;
    assign out_dis1 = Q/10;
    bcd7seg(out_dis0, h0);
    bcd7seg(out_dis1, h1);
    always @(select)
        case (select)
            1'b0: begin seg7[7:0] = 8'b11111110; h=h0; end
            1'b1: begin seg7[7:0] = 8'b11111101; h=h1; end
        endcase
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