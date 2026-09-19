module display4(
    input  wire clk,
    input  wire tick,
    input  wire [6:0] h0,h1,h2,h3,
    output reg  [7:0] seg7,
    output reg  [6:0] h
);
    reg [1:0] select;
    always @(posedge clk) begin
        if (tick)
            select <= (select == 2'd3) ? 2'd0 : select + 2'd1;
    end

    always @(*) begin
        case (select)
            2'd0: begin seg7 = 8'b11111110; h = h0; end
            2'd1: begin seg7 = 8'b11111101; h = h1; end
            2'd2: begin seg7 = 8'b11111011; h = h2; end
            2'd3: begin seg7 = 8'b11110111; h = h3; end
            default: begin seg7 = 8'b11111111; h = 7'b1111111; end
        endcase
    end
endmodule
