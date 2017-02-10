@echo off
title 正在初始化窗口...
if "%1"=="" goto i
cd. >Temp\done.txt
setlocal enabledelayedexpansion
set "path=%path%;Tools\"
CurS /crv 0
call BRPG InitWindow 9 9
title 正在打开场景...
call BRPG LoadMap Graphics\Tilesets\0.bmp Data\Maps\1-a.txt
call BRPG AddCharacter Hero 23 4 Hero
call BRPG AddCharacter Win 1 16 NPC0
call BRPG SetCharacterEvent Win 1
title 迷宫
:loop
call BRPG Draw
choice /c wasd >nul
if "%errorlevel%"=="1" call BRPG WalkCharacter Hero up
if "%errorlevel%"=="2" call BRPG WalkCharacter Hero left
if "%errorlevel%"=="3" call BRPG WalkCharacter Hero down
if "%errorlevel%"=="4" call BRPG WalkCharacter Hero right
if not "%errorlevel%"=="0" call:Event_%errorlevel%
goto loop

:Event_1
image /d
echo Win!!!
pause
exit

:i
for /f "tokens=2*" %%i in ('reg query HKEY_CURRENT_USER\Console^|findstr FontSize') do set fontsize=%%j
echo.yes|reg add HKEY_CURRENT_USER\Console /v FontSize /t REG_DWORD /d 0x00100008 >nul 2>nul
for /f "tokens=4 delims=. " %%a in ('ver') do (
  if "%%a"=="10" (
    for /f "tokens=2*" %%i in ('reg query HKEY_CURRENT_USER\Console^|findstr ForceV2') do set forcev2=%%j
    echo.yes|reg add HKEY_CURRENT_USER\Console /v ForceV2 /t REG_DWORD /d 0x00000000 >nul 2>nul
  )
)
start "正在初始化窗口..." %0 done
:i.
if not exist Temp\done.txt goto i.
del Temp\done.txt
echo.yes|reg add HKEY_CURRENT_USER\Console /v FontSize /t REG_DWORD /d %fontsize% >nul 2>nul
for /f "tokens=4 delims=. " %%a in ('ver') do if "%%a"=="10" echo.yes|reg add HKEY_CURRENT_USER\Console /v ForceV2 /t REG_DWORD /d %forcev2% >nul 2>nul
exit