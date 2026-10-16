module top(
    input CLK100MHZ,
    input CPU_RESETN,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
);

    // 时基生成模块
    wire tick_25mhz;
    tickgen #(.tick_freq(25000000)) u_tick_25mhz ( // VGA扫描时基
        .clk(CLK100MHZ), .rst(1'b0), .en(1'b1), .tick(tick_25mhz)
    );

    // 显存模块：12bit x 327680(640列 x 512行)，列优先存放
    wire [9:0]  h_addr, v_addr;
    wire [11:0] vga_data;
    blk_mem_gen_0 u_vram (
        .clka (CLK100MHZ),
        .wea  (1'b0),
        .addra({h_addr, v_addr[8:0]}),
        .dina (12'd0),
        .douta(vga_data)
    );

    // 核心逻辑 - vga_ctrl 模块
    vga_ctrl u_vga(
        .clk(CLK100MHZ),
        .tick_25mhz(tick_25mhz),
        .reset(~CPU_RESETN),
        .vga_data(vga_data),
        .h_addr(h_addr),
        .v_addr(v_addr),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .valid(),
        .vga_r(VGA_R),
        .vga_g(VGA_G),
        .vga_b(VGA_B)
    );

endmodule
