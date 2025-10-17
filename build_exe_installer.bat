@echo off
chcp 65001 >nul
echo ========================================
echo   超星学习通助手 - EXE 安装程序生成工具
echo ========================================
echo.

REM 检查 Inno Setup 是否已安装
set INNO_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe
if not exist "%INNO_PATH%" (
    echo [错误] 未找到 Inno Setup！
    echo.
    echo 请先安装 Inno Setup 6.0+
    echo 下载地址: https://jrsoftware.org/isdl.php
    echo.
    echo 安装完成后重新运行此脚本。
    pause
    exit /b 1
)

echo [1/4] 清理旧构建...
call fvm flutter clean
if errorlevel 1 goto error

echo.
echo [2/4] 获取依赖...
call fvm flutter pub get
if errorlevel 1 goto error

echo.
echo [3/4] 构建 Windows Release 版本...
call fvm flutter build windows --release
if errorlevel 1 goto error

echo.
echo [4/4] 生成 EXE 安装程序...
"%INNO_PATH%" windows_installer.iss
if errorlevel 1 goto error

echo.
echo ========================================
echo   ✅ 安装程序生成成功！
echo ========================================
echo.
echo 安装程序位置: build\windows\installer\ChaoxingHelper_Setup_v1.0.0.exe
echo.
echo 你现在可以将这个 EXE 文件分发给朋友使用！
echo 他们只需要双击安装即可，无需任何额外配置。
echo.
pause
exit /b 0

:error
echo.
echo ========================================
echo   ❌ 生成失败！
echo ========================================
echo.
echo 请检查错误信息并修复后重试。
echo.
pause
exit /b 1
