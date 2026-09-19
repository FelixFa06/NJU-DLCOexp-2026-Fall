module mem(
    input clk,
    input we,
    input [3:0] addr,
    input [7:0] din,
    output [7:0] dout1,
    output [7:0] dout2
);
    regs u_reg(
        .clk (clk),
        .we  (we),
        .addr(addr),
        .din (din),
        .dout(dout1)
    );
    blk_mem_gen_0 u_ram (
        .clka (clk),
        .wea  (we),
        .addra(addr),
        .dina (din),
        .douta(dout2)
    );
endmodule