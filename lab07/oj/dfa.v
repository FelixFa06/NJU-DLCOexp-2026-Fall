module dfa(
    input  clk,
	input  [7:0] data,
	input  reset,
	output reg result
);

    reg odd_tot, odd_n;
    always @(posedge clk) begin
        if (reset) begin
            result <= 1'b0;
            odd_tot <= 1'b0;
            odd_n <= 1'b0;
        end
        else if (data == 8'h0) //null
            result <= odd_n && odd_tot;
        else if (data == 8'h6E || data == 8'h4E) begin// n or N
            odd_tot <= ~odd_tot;
            odd_n <= ~odd_n;
        end
        else
            odd_tot <= ~odd_tot;
    end

endmodule