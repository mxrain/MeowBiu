@echo off
setlocal enabledelayedexpansion

REM 读取当前版本号
for /f "tokens=1,* delims=:" %%a in ('findstr /r "^version:" pubspec.yaml') do (
    set VERSION_LINE=%%b
    set VERSION_LINE=!VERSION_LINE:~1!
    for /f "tokens=1 delims=+" %%c in ("!VERSION_LINE!") do set VERSION=%%c
    set VERSION=!VERSION:~0,-1!
)

echo 当前版本号: !VERSION!
echo.

set /p CONFIRM=确认发布版本 v!VERSION! 吗? (y/n): 
if /i "%CONFIRM%" neq "y" (
    echo 已取消发布
    exit /b
)

echo 正在创建标签 v!VERSION!...
git tag -a "v!VERSION!" -m "Release v!VERSION!"

echo 正在推送标签到远程仓库...
git push github "v!VERSION!"

echo 发布过程已启动，请查看GitHub Actions页面查看构建进度。
echo GitHub Actions页面: https://github.com/mxrain/MeowBiu/actions

endlocal 