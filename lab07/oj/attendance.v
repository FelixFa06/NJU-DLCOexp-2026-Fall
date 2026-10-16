module attendance(
	input [127:0] name,
	input clk,
	input rst,
	input [1:0] cmd,
	output reg [127:0] dataout
);
    // dataout 取所有输入字符串的异或值
    // 未到的人一定出现奇数次，其余人一定出现偶数次
    
    always @(posedge clk) begin
        if (rst)
            dataout <= 127'd0;
        else if (cmd != 2'd0)
            dataout <= dataout ^ name;
    end

endmodule
