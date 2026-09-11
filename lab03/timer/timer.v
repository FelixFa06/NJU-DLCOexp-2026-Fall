module timer(
    input clk,
    input en,
    input rst,
    output reg [5:0] Q,
    output reg rco
);

    always @(posedge clk)
        if (en) begin
            if (rst) begin
                Q <= 0;
                rco <= 1'b0;
            end
            else begin
                if (Q==59) begin
                    Q <= 0;
                    rco <= 1'b1;
                end
                else begin
                    Q <= Q+1;
                    rco <= 1'b0;
                end
            end
        end

endmodule