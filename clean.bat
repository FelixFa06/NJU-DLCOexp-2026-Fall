@echo off
rem 用法: clean.bat <lab目录>    例: clean.bat lab00   或   clean.bat lab01\exp1
if "%~1"=="" (
    echo 用法: clean.bat ^<lab目录^>
    echo   例: clean.bat lab00
    exit /b 1
)
cd /d "%~dp0%~1"
if exist build rmdir /s /q build
if exist .Xil rmdir /s /q .Xil
if exist vivado.jou del /q vivado.jou
if exist vivado.log del /q vivado.log
if exist usage_statistics_webtalk.html del /q usage_statistics_webtalk.html
if exist usage_statistics_webtalk.xml del /q usage_statistics_webtalk.xml
if exist xsim.dir rmdir /s /q xsim.dir
if exist xvlog.log del /q xvlog.log
if exist xelab.log del /q xelab.log
if exist xelab.pb del /q xelab.pb
if exist xsim.jou del /q xsim.jou
if exist xsim.log del /q xsim.log
if exist webtalk.jou del /q webtalk.jou
if exist webtalk.log del /q webtalk.log
del /q *.wdb 2>nul
del /q *.vcd 2>nul
del /q xsim_*.backup.jou 2>nul
del /q xsim_*.backup.log 2>nul
del /q webtalk_*.backup.jou 2>nul
del /q webtalk_*.backup.log 2>nul
