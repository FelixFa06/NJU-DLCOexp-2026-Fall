@echo off
rem 用法: prog.bat <lab目录>    例: prog.bat lab00   或   prog.bat lab01\exp1
if "%~1"=="" (
    echo 用法: prog.bat ^<lab目录^>
    echo   例: prog.bat lab00
    exit /b 1
)
if not exist "%~dp0%~1" (
    echo 错误: 目录不存在 "%~dp0%~1"
    exit /b 1
)
call D:\Xilinx\Vivado\2020.2\settings64.bat
if errorlevel 1 exit /b 1
cd /d "%~dp0%~1"
vivado -mode batch -source "%~dp0scripts\download.tcl"
exit /b %errorlevel%
