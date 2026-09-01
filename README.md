# DLCO-exp（数字逻辑与计算机组成实验）

Nexys A7-100T 开发板上的数字逻辑与计算机组成实验课程作业仓库。所有构建均走 **Vivado 非工程（batch）模式**，用脚本驱动，不依赖 GUI 工程（`.xpr`）。

## 环境

- 开发板：Nexys A7-100T（FPGA `xc7a100tcsg324-1`）
- Vivado 2020.2（`D:\Xilinx\Vivado\2020.2`，不在 PATH，脚本内部先 `source settings64.bat`）
- 报告：LaTeX（`ctexart`），在线编译（tex.nju.edu.cn）

## 目录结构

```
.
├── labNN/expN/          # 每个实验的自包含目录
│   ├── top.v            #   顶层模块：逻辑端口 ↔ 板级引脚（SW / LED / 数码管）
│   ├── <module>.v       #   功能模块（保持引脚无关）
│   ├── <module>.xdc     #   约束（从根目录 nexysa7.xdc 复制，只取消用到的引脚注释）
│   └── sim/tb.v         #   testbench（模块名统一 tb_top，放 sim/ 子目录）
├── labNN/report/        # 实验报告（main.tex + figures/）
├── nexysa7.xdc          # Digilent master 约束（全注释，约束派生来源）
├── scripts/             # run.tcl（综合实现）/ download.tcl（烧录）/ sim.tcl（仿真）
└── *.bat                # 顶层入口脚本
```

## 每次实验的工作流

1. **写代码**：实现功能模块 `<module>.v`，再写 `top.v` 把逻辑端口连到板级引脚。
2. **写约束**：从根目录 `nexysa7.xdc` 复制，只取消本次用到引脚的注释（注意 `SW[8]`/`SW[9]` 为 LVCMOS18）。
3. **构建**：`build.bat labNN\expN` → 综合 + 实现 + 生成 `build/top.bit`。
4. **仿真**：写 `sim/tb.v`，`sim.bat labNN\expN` → 生成 `build/top.vcd`，用 GTKWave 打开看波形、截图。
5. **上板**：`prog.bat labNN\expN` 把 `build/top.bit` 烧进开发板，拨动开关验证现象。
6. **写报告**：复制 `labNN/report/` 模板，改 `\expname`、`\expdate`，补 `figures/` 截图；整个 lab 目录上传 tex.nju.edu.cn 编译，下载 `main.pdf` 放回 `report/`。
7. **提交**：工程文件 + 报告电子版打包上传。

## 命令

```bat
build.bat <lab>    :: 综合 + 实现 + 生成比特流
prog.bat  <lab>    :: 烧录到开发板
sim.bat   <lab>    :: 仿真（xvlog/xelab/xsim），生成 .vcd
clean.bat <lab>    :: 清理 build/、.Xil/ 及 Vivado/xsim 日志
```

## 约定与注意

- **每个顶层端口都要有对应 `.xdc` 约束**；未使用的总线位也要约束并置 0（如 `assign LED[3] = 1'b0;`）。
- `sim/tb.v` 放在 `sim/` 子目录，避免被 `run.tcl` 的 `glob ./*.v` 误收进综合；testbench 模块名统一 `tb_top`。
- `build/top.bit` 与 `build/top.vcd` 作为交付物纳入版本控制（`.gitignore` 已放行）。
