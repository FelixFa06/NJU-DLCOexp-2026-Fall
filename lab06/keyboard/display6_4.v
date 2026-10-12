module display6_4(
    input  wire clk,
    input  wire tick_1ms,
    input  wire dis4,
    input  wire [6:0] h0,h1,h2,h3,h4,h5,
    output reg  [7:0] seg7,
    output reg  [6:0] h
);
    reg [2:0] select;
    always @(posedge clk) begin
        if (tick_1ms) begin
            if (select == 3'd5)
                select <= 3'd0;
            else
                select <= select + 3'd1;
        end
    end

    wire [7:0] mask;
    assign mask = dis4 ? 8'b00000000 : 8'b00001111;

    always @(*) begin
        case (select)
            3'd0: begin seg7 = 8'b11111110 | mask; h = h0; end
            3'd1: begin seg7 = 8'b11111101 | mask; h = h1; end
            3'd2: begin seg7 = 8'b11111011 | mask; h = h2; end
            3'd3: begin seg7 = 8'b11110111 | mask; h = h3; end
            3'd4: begin seg7 = 8'b11101111 | mask; h = h4; end
            3'd5: begin seg7 = 8'b11011111 | mask; h = h5; end
            default: begin seg7 = 8'b11111111; h = 7'b1111111; end
        endcase
    end
endmodule
