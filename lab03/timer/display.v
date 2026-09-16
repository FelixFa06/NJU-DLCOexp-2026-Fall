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