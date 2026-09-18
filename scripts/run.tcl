# 非工程（batch）模式：综合 + 实现 + 生成 bit
# 用法：在某个 lab 目录下执行  vivado -mode batch -source <本文件绝对路径>
set PART      xc7a100tcsg324-1
set BUILD_DIR ./build

# lab 自带的 IP 生成脚本（如 lab04/mem/ip.tcl）；没有则跳过，不影响其他 lab
if {[file exists ./ip.tcl]} { source ./ip.tcl }

read_verilog [glob ./*.v]
read_xdc    [glob ./*.xdc]

synth_design -top top -part $PART
opt_design
place_design
route_design

file mkdir $BUILD_DIR
write_checkpoint   -force $BUILD_DIR/post_route.dcp
report_utilization -file  $BUILD_DIR/util.rpt
write_bitstream -force $BUILD_DIR/top.bit
