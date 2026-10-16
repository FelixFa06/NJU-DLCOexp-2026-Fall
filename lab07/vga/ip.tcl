# lab07/vga 专用：生成 12bit x 327680 单口 Block RAM 作为 VGA 显存
# 由 scripts/run.tcl 通过  source ./ip.tcl  调用（其他 lab 无此文件，自动跳过）
# 所有产物落在 ./build/ 下，不进版本控制
set IP_DIR ./build/ip
file delete -force $IP_DIR
file mkdir $IP_DIR

create_project -in_memory -part xc7a100tcsg324-1

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 \
    -module_name blk_mem_gen_0 -dir $IP_DIR

# 12bit 像素 x 327680(640列x512行)，列优先存放，由 picture_1.coe 初始化
set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_RAM} \
    CONFIG.Write_Width_A {12} \
    CONFIG.Write_Depth_A {327680} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Coe_File [file normalize ./picture_1.coe] \
] [get_ips blk_mem_gen_0]

generate_target all [get_ips blk_mem_gen_0]
synth_ip [get_ips blk_mem_gen_0]
