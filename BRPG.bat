::BRPG游戏引擎
::By Byaidu&tmxk0411
::调用方法：
::call BRPG FunctionName Parameters
::函数列表：
::InitWindow Width Height
::LoadMap Map/Bitmap Accessiblemap
::Draw
::Unload
::ChangeTileNumber x y Number
::ChangeTileAccessible x y Number
::AddCharacter Name x y Number
::RemoveCharacter Name
::WalkCharacter Name direction
::MoveCharacter Name x y
::ChangeCharacterNumber Name Number
::SetCharacterEvent Name Script(数字且不为零)
::UnSetCharacterEvent Name
shift /0
goto %0

:InitWindow
set BRPG.Window.Width=%1
set BRPG.Window.Height=%2
set /a BRPG.temp1=%1*4
set /a BRPG.temp2=%2*2
mode con: cols=!BRPG.temp1! lines=!BRPG.temp2! >nul
exit /b 0

:LoadMap
rem 读取大小
set BRPG.Map.Height=0
for /f %%a in (%2) do (
  set /a BRPG.Map.Height+=1
  set BRPG.Map.Width=0
  for %%b in (%%a) do set /a BRPG.Map.Width+=1
)
if "%~x1"==".bmp" (
  set BRPG.Map.Full=%1
) else (
  rem 读取map
  set BRPG.temp=0
  for /f %%a in (%1) do (
    set /a BRPG.temp+=1
    for /l %%b in (1,1,!BRPG.Map.Width!) do (
      call:LoadMap. %%b "%%a"
    )
  )
)
rem 读取Accessiblemap
set BRPG.temp=0
for /f %%a in (%2) do (
  set /a BRPG.temp+=1
  for /l %%b in (1,1,!BRPG.Map.Width!) do (
    call:LoadMap.. %%b "%%a"
  )
)
exit /b 0
:LoadMap.
for /f "tokens=%1 delims=," %%a in (%2) do set BRPG.Map.%1_!BRPG.temp!.Number=%%a
exit /b 0
:LoadMap..
for /f "tokens=%1 delims=," %%a in (%2) do set BRPG.Map.%1_!BRPG.temp!.Accessible=%%a
exit /b 0

:Draw
rem 左右上下
set /a BRPG.temp1=BRPG.Character.Hero.x-BRPG.Window.Width/2
set /a BRPG.temp2=BRPG.Character.Hero.x+BRPG.Window.Width/2
set /a BRPG.temp3=BRPG.Character.Hero.y-BRPG.Window.Height/2
set /a BRPG.temp4=BRPG.Character.Hero.y+BRPG.Window.Height/2
rem 主角初始绘图坐标
set /a BRPG.temp5=BRPG.Window.Width/2*32
set /a BRPG.temp6=BRPG.Window.Height/2*32
rem BRPG.Map.Full初始绘图坐标
set /a "BRPG.temp10=(1-BRPG.Character.Hero.x+BRPG.Window.Width/2)*32"
set /a "BRPG.temp11=(1-BRPG.Character.Hero.y+BRPG.Window.Height/2)*32"
rem 左边越界
if %BRPG.temp1% lss 1 (
  rem 地图坐标1对应绘图坐标0，所以参与绘图坐标计算时-1
  set /a "BRPG.temp5=(BRPG.Character.Hero.x-1)*32"
  set /a BRPG.temp10=0
  set /a BRPG.temp1=1
  set /a BRPG.temp2=BRPG.Window.Width
)
rem 右边越界
if %BRPG.temp2% gtr %BRPG.Map.Width% (
  set /a "BRPG.temp5=(BRPG.Character.Hero.x-1+BRPG.Window.Width-BRPG.Map.Width)*32"
  set /a "BRPG.temp10=(BRPG.Window.Width-BRPG.Map.Width)*32"
  set /a BRPG.temp1=BRPG.Map.Width-BRPG.Window.Width+1
  set /a BRPG.temp2=BRPG.Map.Width
)
rem 上边越界
if %BRPG.temp3% lss 1 (
  set /a "BRPG.temp6=(BRPG.Character.Hero.y-1)*32"
  set /a BRPG.temp11=0
  set /a BRPG.temp3=1
  set /a BRPG.temp4=BRPG.Window.Height
)
rem 下边越界
if %BRPG.temp4% gtr %BRPG.Map.Height% (
  set /a "BRPG.temp6=(BRPG.Character.Hero.y-1+BRPG.Window.Height-BRPG.Map.Height)*32"
  set /a "BRPG.temp11=(BRPG.Window.Height-BRPG.Map.Height)*32"
  set /a BRPG.temp3=BRPG.Map.Height-BRPG.Window.Height+1
  set /a BRPG.temp4=BRPG.Map.Height
)
rem 渲染窗口内的所有方块，从左到右，从上到下
(if "!BRPG.Map.Full!"=="" (
  rem 渲染窗口内的所有方块，从左到右，从上到下
  for /l %%a in (!BRPG.temp1!,1,!BRPG.temp2!) do (
    rem 目标绘图横坐标
    set /a "BRPG.temp7=(%%a-BRPG.temp1)*32"
    for /l %%b in (!BRPG.temp3!,1,!BRPG.temp4!) do (
      rem 目标绘图纵坐标
      set /a "BRPG.temp8=(%%b-!BRPG.temp3!)*32"
      rem 渲染方块
      echo Graphics\Tilesets\!BRPG.Map.%%a_%%b.Number!.bmp !BRPG.temp7! !BRPG.temp8!
      rem 渲染Character
      if not "!BRPG.Map.%%a_%%b.Character!"=="" call echo Graphics\Characters\%%BRPG.Character.!BRPG.Map.%%a_%%b.Character!.Number%%.bmp !BRPG.temp7! !BRPG.temp8! /TRANSPARENTBLT
    )
  )
) else (
  echo !BRPG.Map.Full! !BRPG.temp10! !BRPG.temp11!
  for /l %%a in (!BRPG.temp1!,1,!BRPG.temp2!) do (
    rem 目标绘图横坐标
    set /a "BRPG.temp7=(%%a-BRPG.temp1)*32"
    for /l %%b in (!BRPG.temp3!,1,!BRPG.temp4!) do (
      rem 目标绘图纵坐标
      set /a "BRPG.temp8=(%%b-!BRPG.temp3!)*32"
      rem 渲染Character
      if not "!BRPG.Map.%%a_%%b.Character!"=="" call echo Graphics\Characters\%%BRPG.Character.!BRPG.Map.%%a_%%b.Character!.Number%%.bmp !BRPG.temp7! !BRPG.temp8! /TRANSPARENTBLT
    )
  )
))>Temp\image.txt
image /l Temp\image.txt
exit /b 0

:ChangeTileNumber
set BRPG.Map.%1_%2.Number=%3
exit /b 0

:ChangeTileAccessible
set BRPG.Map.%1_%2.Accessible=%3
exit /b 0

:Unload
image /d
for /f "tokens=1 delims==" %%a in ('set BRPG.') do for /f "tokens=2 delims=." %%b in ("%%a") do if not "%%b"=="Window" set %%a=
exit /b 0

:WalkCharacter
rem 左右上下
set /a BRPG.temp1=BRPG.Character.%1.x-1
set /a BRPG.temp2=BRPG.Character.%1.x+1
set /a BRPG.temp3=BRPG.Character.%1.y-1
set /a BRPG.temp4=BRPG.Character.%1.y+1
set /a BRPG.temp5=BRPG.Character.%1.x
set /a BRPG.temp6=BRPG.Character.%1.y
if "%2"=="left" if "!BRPG.Map.%BRPG.temp1%_%BRPG.temp6%.Character!"=="" (if not "!BRPG.temp5!"=="1" if "!BRPG.Map.%BRPG.temp1%_%BRPG.temp6%.Accessible!"=="1" call:MoveCharacter %1 %BRPG.temp1% %BRPG.temp6%) else (call:WalkCharacter. %%BRPG.Character.!BRPG.Map.%BRPG.temp1%_%BRPG.temp6%.Character!.Script%%&if not "!BRPG.temp7!"=="" exit /b !BRPG.temp7!)
if "%2"=="right" if "!BRPG.Map.%BRPG.temp2%_%BRPG.temp6%.Character!"=="" (if not "!BRPG.temp5!"=="!BRPG.Map.Width!" if "!BRPG.Map.%BRPG.temp2%_%BRPG.temp6%.Accessible!"=="1" call:MoveCharacter %1 %BRPG.temp2% %BRPG.temp6%) else (call:WalkCharacter. %%BRPG.Character.!BRPG.Map.%BRPG.temp2%_%BRPG.temp6%.Character!.Script%%&if not "!BRPG.temp7!"=="" exit /b !BRPG.temp7!)
if "%2"=="up" if "!BRPG.Map.%BRPG.temp5%_%BRPG.temp3%.Character!"=="" (if not "!BRPG.temp6!"=="1" if "!BRPG.Map.%BRPG.temp5%_%BRPG.temp3%.Accessible!"=="1" call:MoveCharacter %1 %BRPG.temp5% %BRPG.temp3%) else (call:WalkCharacter. %%BRPG.Character.!BRPG.Map.%BRPG.temp5%_%BRPG.temp3%.Character!.Script%%&if not "!BRPG.temp7!"=="" exit /b !BRPG.temp7!)
if "%2"=="down" if "!BRPG.Map.%BRPG.temp5%_%BRPG.temp4%.Character!"=="" (if not "!BRPG.temp6!"=="!BRPG.Map.Height!" if "!BRPG.Map.%BRPG.temp5%_%BRPG.temp4%.Accessible!"=="1" call:MoveCharacter %1 %BRPG.temp5% %BRPG.temp4%) else (call:WalkCharacter. %%BRPG.Character.!BRPG.Map.%BRPG.temp5%_%BRPG.temp4%.Character!.Script%%&if not "!BRPG.temp7!"=="" exit /b !BRPG.temp7!)
exit /b 0
:WalkCharacter.
set BRPG.temp7=%1
exit /b 0

:AddCharacter
set BRPG.Character.%1.x=%2
set BRPG.Character.%1.y=%3
set BRPG.Character.%1.Number=%4
set BRPG.Character.%1.ReplaceAccessible=!BRPG.Map.%2_%3.Accessible!
set BRPG.Map.%2_%3.Character=%1
set BRPG.Map.%2_%3.Accessible=0
exit /b 0

:RemoveCharacter
set BRPG.Map.!BRPG.Character.%1.x!_!BRPG.Character.%1.y!.Character=
set BRPG.Map.!BRPG.Character.%1.x!_!BRPG.Character.%1.y!.Accessible=!BRPG.Character.%1.ReplaceAccessible!
set BRPG.Character.%1.x=
set BRPG.Character.%1.y=
set BRPG.Character.%1.Number=
set BRPG.Character.%1.ReplaceAccessible=
set BRPG.Character.%1.Script=
exit /b 0

:MoveCharacter
set BRPG.Map.!BRPG.Character.%1.x!_!BRPG.Character.%1.y!.Character=
set BRPG.Map.!BRPG.Character.%1.x!_!BRPG.Character.%1.y!.Accessible=!BRPG.Character.%1.ReplaceAccessible!
set BRPG.Character.%1.x=%2
set BRPG.Character.%1.y=%3
set BRPG.Map.%2_%3.Character=%1
set BRPG.Character.%1.ReplaceAccessible=!BRPG.Map.%2_%3.Accessible!
set BRPG.Map.%2_%3.Accessible=0
exit /b 0

:ChangeCharacterNumber
set BRPG.Character.%1.Number=%2
exit /b 0

:SetCharacterEvent
set BRPG.Character.%1.Script=%2
exit /b 0

:UnSetCharacterEvent
set BRPG.Character.%1.Script=
exit /b 0