module bcd_count2(
    input  wire clk,
    input  wire rst,
    input  wire en_up,
    input  wire en_down,
    output reg  [3:0] bcd0,
    output reg  [3:0] bcd1,
    output reg  carry,
    output reg  borrow
);
    parameter [3:0] max0 = 9;
    parameter [3:0] max1 = 9;

    always @(posedge clk) begin
        if (rst) begin
            bcd0  <= 4'd0;
            bcd1  <= 4'd0;
            carry <= 1'b0;
            borrow <= 1'b0;
        end
        else if (en_up) begin
            borrow <= 1'b0;
            if (bcd0 == max0 && bcd1 == max1) begin
                bcd0  <= 4'd0;
                bcd1  <= 4'd0;
                carry <= 1'b1;
            end
            else if (bcd0 == 4'd9) begin
                bcd0  <= 4'd0;
                bcd1  <= bcd1 + 4'd1;
                carry <= 1'b0;
            end
            else begin
                bcd0  <= bcd0 + 4'd1;
                carry <= 1'b0;
            end
        end
        else if (en_down) begin
            carry <= 1'b0;
            if (bcd0 == 4'd0 && bcd1 == 4'd0) begin
                bcd0  <= max0;
                bcd1  <= max1;
                borrow <= 1'b1;
            end
            else if (bcd0 == 4'd0) begin
                bcd0  <= 4'd9;
                bcd1  <= bcd1 - 4'd1;
                borrow <= 1'b0;
            end
            else begin
                bcd0  <= bcd0 - 4'd1;
                borrow <= 1'b0;
            end
        end
        else begin
            carry <= 1'b0;
            borrow <= 1'b0;
        end
    end
endmodule
