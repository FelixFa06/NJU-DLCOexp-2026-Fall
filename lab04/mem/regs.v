module regs(
    input clk,
    input we,
    input [3:0] addr,
    input [7:0] din,
    output [7:0] dout
);
    reg [7:0] regs[15:0];
    initial $readmemh("mem.txt", regs, 0, 15);

    assign dout = regs[addr];
    
    always @(posedge clk)
        if (we) begin
            regs[addr] <= din;
        end

endmodule