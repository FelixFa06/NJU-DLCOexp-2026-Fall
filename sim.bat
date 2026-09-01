@echo off
rem Usage: sim.bat <lab dir>    e.g. sim.bat lab01\exp1
if "%~1"=="" (
    echo Usage: sim.bat ^<lab dir^>
    echo    e.g. sim.bat lab01\exp1
    exit /b 1
)
call D:\Xilinx\Vivado\2020.2\settings64.bat
cd /d "%~dp0%~1"
vivado -mode batch -source "%~dp0scripts\sim.tcl"
