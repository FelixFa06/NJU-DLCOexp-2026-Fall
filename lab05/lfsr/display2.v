module display2(
    input  wire clk,
    input  wire tick_1ms,
    input  wire [6:0] h0,h1,
    output reg  [7:0] seg7,
    output reg  [6:0] h
);
    reg select;
    always @(posedge clk) begin
        if (tick_1ms)
            select <= ~select;
    end

    always @(*) begin
        case (select)
            1'b0: begin seg7 = 8'b11111110; h = h0; end
            1'b1: begin seg7 = 8'b11111101; h = h1; end
            default: begin seg7 = 8'b11111111; h = 7'b1111111; end
        endcase
    end
endmodule
