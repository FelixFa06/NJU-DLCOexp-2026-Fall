# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 交流语言

在本项目中与用户交流时，**始终使用中文**（包括解释、说明、总结、提问、建议等所有面向用户的文字）。代码、标识符、命令、文件名等技术性内容保持英文原样。

## What this is

Coursework for **数字逻辑与计算机组成实验 (DLCO-exp)** on the **Nexys A7-100T** FPGA board (part `xc7a100tcsg324-1`). Builds use Vivado 2020.2, installed at `D:\Xilinx\Vivado\2020.2` and **not on PATH** — every script sources `settings64.bat` first.

The workflow is **script-based (non-project mode)**, not the Vivado GUI `.xpr` flow. There is no `make`; drive Vivado through the parameterized `.bat` wrappers below.

## Commands

Run from anywhere; the `<lab>` argument is a path relative to the repo root:

- `build.bat <lab>` — synthesize + implement + write the bitstream (`build/top.bit`). e.g. `build.bat lab00`, `build.bat lab01\exp1`.
- `prog.bat <lab>` — program the connected board with `build/top.bit`.
- `clean.bat <lab>` — delete `build/`, `.Xil/`, and Vivado log/webtalk junk.

The `.bat` scripts use `%~dp0` to self-locate, then `cd` into the lab dir and run `vivado -mode batch -source scripts\run.tcl` (or `download.tcl`).

## Architecture

**`top.v` wrapper pattern.** `top` is always the synthesis target (`synth_design -top top`). It maps physical board ports (`SW`, `LED`, seven-segment `CA..CG`/`DP`/`AN`) to the functional module's logical ports. The logic module itself is kept free of board-pin names. Each lab folder is self-contained: `top.v` + `<module>.v` + `<module>.xdc`.

**Constraint derivation.** `nexysa7.xdc` at the root is the pristine Digilent master (all lines commented). Each lab's `.xdc` is a copy with only the used pins uncommented — do **not** hand-write minimal `.xdc` files. `scripts/run.tcl` reads sources via `glob ./*.v` / `glob ./*.xdc`, which resolve relative to the **current directory**, so Vivado must run from inside the lab folder (the `.bat` handles this).

## Conventions and gotchas

- **Every top-level port must have a matching `.xdc` constraint.** An unconstrained output triggers place/route warnings or errors (hit with `LED[3]` in exp2). Unused bus bits must still be constrained and tied off (`assign LED[3] = 1'b0;`).
- **`SW[8]` and `SW[9]` use `IOSTANDARD LVCMOS18`** (bank 34), not `LVCMOS33` like the other switches — keep the master's value when uncommenting.
- `.bit` files are committed deliverables: `.gitignore` keeps `build/*.bit` but ignores the rest of `build/`.
- `archive/` holds the old GUI `.xpr` projects and is gitignored — it is backup only, never build there.
- `lab01/graycode.v` is a logic module only (no `top.v` / `.xdc`); it isn't a buildable lab folder.

## Report

Each lab has a LaTeX report at `labNN/report/main.tex`, compiled online at tex.nju.edu.cn (no local TeX); the compiled `main.pdf` goes back into `report/`. 代码只贴关键逻辑片段（inline `lstlisting`）；整段代码用 `\lstinputlisting` 可选，但不要引用 `../` 源码路径，以免云端编译不便。

Course-specified sections (课件; the user trims the non-essential ones):
实验目的 · 实验原理 · 实验环境/器材 · 程序代码或流程图（优先画框图/代码流程图，不建议大段贴码）· 实验步骤/过程（截图关键步骤）· 测试方法（如何验证、如何选测试信号）· 实验结果（仿真截图 + 下载运行结果，可照片/视频）· 问题及解决办法（写明原因+办法）· 启示 · 意见和建议

Cover (per experiment): 实验名称 / 姓名 / 学号 / 邮箱 / 实验时间（日期用固定 `\expdate` 字段，不用 `\today`）.

Submission: zip 工程文件 + 报告电子版, upload. 波形图截图建议保留，但提交非强制。

## Academic integrity

The reference repo `nju-dlco-exp-2026-spring` (NJU) is for learning the *workflow and structure* only — never copy its solution code.

## Git 提交

不要给 git commit 添加 Claude 署名/尾注（如 `Co-Authored-By: Claude` 或 "Copiloted by Claude Code"）。此项已通过全局设置 `includeCoAuthoredBy: false` 生效（见 `~/.claude/settings.json`），不要改动为 `true`。
