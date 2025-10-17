@echo off
chcp 65001 >nul
echo ========================================
echo   超星学习通助手 - Windows 打包工具
echo ========================================
echo.

:menu
echo 请选择打包方式：
echo.
echo [1] MSIX 安装包（推荐，适用于 Windows 10/11）
echo [2] 仅构建 Release 版本（不生成安装包）
echo [3] 清理构建缓存
echo [0] 退出
echo.
set /p choice="请输入选项 (0-3): "

if "%choice%"=="1" goto build_msix
if "%choice%"=="2" goto build_release
if "%choice%"=="3" goto clean
if "%choice%"=="0" goto end
echo 无效选项，请重新选择！
echo.
goto menu

:build_msix
echo.
echo ========================================
echo   开始构建 MSIX 安装包
echo ========================================
echo.

echo [1/4] 清理旧构建...
call flutter clean
if errorlevel 1 goto error

echo.
echo [2/4] 获取依赖...
call flutter pub get
if errorlevel 1 goto error

echo.
echo [3/4] 构建 Release 版本...
call flutter build windows --release
if errorlevel 1 goto error

echo.
echo [4/4] 生成 MSIX 安装包...
call flutter pub run msix:create
if errorlevel 1 goto error

echo.
echo ========================================
echo   ✅ 构建成功！
echo ========================================
echo.
echo 安装包位置: build\windows\runner\Release\chaoxing_ft.msix
echo.
echo 安装方法：
echo 1. 双击 .msix 文件直接安装
echo 2. 或使用 PowerShell: Add-AppxPackage -Path "路径\chaoxing_ft.msix"
echo.
pause
goto menu

:build_release
echo.
echo ========================================
echo   开始构建 Release 版本
echo ========================================
echo.

echo [1/3] 清理旧构建...
call flutter clean
if errorlevel 1 goto error

echo.
echo [2/3] 获取依赖...
call flutter pub get
if errorlevel 1 goto error

echo.
echo [3/3] 构建 Release 版本...
call flutter build windows --release
if errorlevel 1 goto error

echo.
echo ========================================
echo   ✅ 构建成功！
echo ========================================
echo.
echo 可执行文件位置: build\windows\x64\runner\Release\chaoxing_ft.exe
echo 完整应用目录: build\windows\x64\runner\Release\
echo.
echo 注意：直接运行需要所有 DLL 文件在同一目录
echo.
pause
goto menu

:clean
echo.
echo ========================================
echo   清理构建缓存
echo ========================================
echo.
call flutter clean
echo.
echo ✅ 清理完成！
echo.
pause
goto menu

:error
echo.
echo ========================================
echo   ❌ 构建失败！
echo ========================================
echo.
echo 请检查错误信息并修复后重试。
echo.
pause
goto menu

:end
echo.
echo 感谢使用！再见~
timeout /t 2 >nul
exit
