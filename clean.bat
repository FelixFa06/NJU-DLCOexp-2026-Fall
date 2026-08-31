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
