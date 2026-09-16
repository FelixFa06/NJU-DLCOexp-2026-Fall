module bcd_display6(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire [3:0] bcd0, bcd1, bcd2, bcd3, bcd4, bcd5,
    output reg  [7:0] seg7,
    output reg  [6:0] h
);
    // ---------- 位选计数器 0..5 ----------
    reg [2:0] select;

    always @(posedge clk) begin
        if (rst)
            select <= 3'd0;
        else if (en)
            select <= (select == 3'd5) ? 3'd0 : select + 3'd1;
    end

    // ---------- 6 路 BCD → 7 段译码 ----------
    wire [6:0] h0, h1, h2, h3, h4, h5;
    bcd7seg u_seg0 (.b(bcd0), .h(h0));
    bcd7seg u_seg1 (.b(bcd1), .h(h1));
    bcd7seg u_seg2 (.b(bcd2), .h(h2));
    bcd7seg u_seg3 (.b(bcd3), .h(h3));
    bcd7seg u_seg4 (.b(bcd4), .h(h4));
    bcd7seg u_seg5 (.b(bcd5), .h(h5));

    // ---------- 位选 + 段码复用 ----------
    always @(*) begin
        case (select)
            3'd0: begin seg7 = 8'b11111110; h = h0; end
            3'd1: begin seg7 = 8'b11111101; h = h1; end
            3'd2: begin seg7 = 8'b11111011; h = h2; end
            3'd3: begin seg7 = 8'b11110111; h = h3; end
            3'd4: begin seg7 = 8'b11101111; h = h4; end
            3'd5: begin seg7 = 8'b11011111; h = h5; end
            default: begin seg7 = 8'b11111111; h = 7'b1111111; end
        endcase
    end
endmodule
