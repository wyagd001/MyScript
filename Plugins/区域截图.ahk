#NoEnv
#ErrorStdOut
#SingleInstance force
#include %A_ScriptDir%\..\Lib\CaptureScreen.ahk
#include %A_ScriptDir%\..\Lib\Gdip.ahk
#include %A_ScriptDir%\..\Lib\String.ahk
SplitPath,A_ScriptDir,,ParentDir
SetWorkingDir %ParentDir%

run_iniFile = settings\setting.ini
Menu, Tray, Icon,pic\snapshot.ico
IniRead,询问, %run_iniFile%,截图, 询问
IniRead,filetp, %run_iniFile%,截图, filetp
IniRead,区域选择方式, %run_iniFile%,截图, 区域选择方式
IniRead,热键延迟截图, %run_iniFile%,截图, 热键延迟截图
IniRead,截图保存目录, %run_iniFile%,截图, 截图保存目录
IfnotExist,%截图保存目录%
  IniRead, 截图保存目录, %run_iniFile%, 路径设置, 截图保存目录

if(区域选择方式=1)
{
if(热键延迟截图=1)
cstip=
  (
按住鼠标左键拖选截图区域
"Ctrl+S"，直接保存。“回车”，继续。
"Esc/右键"键，退出
 )
else
cstip=
  (
按住鼠标左键拖选截图区域
"Esc/右键"键，退出
 )
}
else if(区域选择方式=2)
{
if(热键延迟截图=1)
cstip=
  (
点击"左键"开始选取，移动鼠标，再次点击"左键"结束
"Ctrl+S"，直接保存。“回车”，继续。
"Esc/右键"键，退出
  )
else
cstip=
  (
点击"左键"开始选取，移动鼠标，再次点击"左键"结束
"Esc/右键"键，退出
  )
}
else if(区域选择方式=3)
{
if(热键延迟截图=1)
cstip=
  (
"Win+左键"拖拽鼠标选取截图范围
"Ctrl+S"，直接保存。“回车”，继续。
"Esc/右键"键，退出
  )
else
cstip=
  (
"Win+左键"拖拽鼠标选取截图范围
"Esc/右键"键，退出
  )
}
gosub,Tip_info
gosub,SelectCaptureArea
Return

^PrintScreen::
SelectCaptureArea:
CoordMode, Mouse ,Screen
;区域截图选取截图区域方法1
if(区域选择方式=1) {
Loop
KeyIsDown := GetKeyState("LButton")
Until KeyIsDown = 1

TrayTip

MouseGetPos, MX, MY
Gui, +AlwaysOnTop -caption +Border +ToolWindow +LastFound
WinSet, Transparent, 80
 Gui,Color, EEAA99


While, (GetKeyState("LButton", "p"))
{
   MouseGetPos, MXend, MYend
   w := abs(MX - MXend),h := abs(MY - MYend)
   X := (MX < MXend) ? MX : MXend
   Y := (MY < MYend) ? MY : MYend
   Gui, Show, x%X% y%Y% w%w% h%h%
   Sleep, 10
}

MouseGetPos, MXend, MYend
If ((w < 10) or ( h < 10))
   {
    TrayTip,警告,拖拽间距过小或者未按提示进行操作，脚本重新启动,3,18
    sleep,3000
    reload
   }
If ( MX > MXend )
Swap(MX, MXend)
If ( MY > MYend )
Swap(MY, MYend)

aRect = %MX%, %MY%, %MXend%, %MYend%
Gui, Color, 0058EE
;~ ;快门声音
IfExist, Sound\shutter.wav
SoundPlay, Sound\shutter.wav, wait

;~ MsgBox %aRect%
sleep,100
if(热键延迟截图=0)
{
Gui, Destroy
CaptureScreen(aRect,0,0) 
gosub,CaptureSave
return
}
            if(热键延迟截图=1){
            hotkey, IfWinActive, ahk_class AutoHotkeyGUI
            hotkey, enter,on
            return
}
}
;区域截图选取截图区域方法2
else if(区域选择方式=2)
{
 Loop
  {
   Sleep,10
   KeyIsDown := GetKeyState("LButton")
   if (KeyIsDown = 1)
    {
     TrayTip
     MouseGetPos, MX, MY
     Gui, +LastFound
     Gui, +AlwaysOnTop -caption +Border +ToolWindow +LastFound
     WinSet, Transparent, 80
     Gui,     Color, EEAA99
     Sleep,500
     Loop
      {
       sleep,10
       KeyIsDown := GetKeyState("LButton")
       MouseGetPos, MXend, MYend
       w := abs(MX - MXend),h := abs(MY - MYend)
       X := (MX < MXend) ? MX : MXend
       Y := (MY < MYend) ? MY : MYend
       Gui, Show, x%X% y%Y% w%w% h%h%

       if (KeyIsDown = 1)
        {
         If ((w < 10) or (h < 10))
         {
          TrayTip,警告,两次点击间距过小或者未按提示进行操作，脚本重新启动,3,18
          sleep,3000
          reload
         }
         If ( MX > MXend )
         Swap(MX, MXend)
         If ( MY > MYend )
         Swap(MY, MYend)

         aRect = %MX%, %MY%, %MXend%, %MYend%
            ;~ ;快门声音
         IfExist, Sound\shutter.wav
         SoundPlay, Sound\shutter.wav, wait
         Gui,     Color, 0058EE
         Gui,     Font, s10
         Gui,     Add, Text, , >>>>选定的区域已经截图，回车继续

         if(热键延迟截图=0)
           {
            Gui, Destroy
            CaptureScreen(aRect,0,0) 
            gosub,CaptureSave
            return
           }
         else if(热键延迟截图=1)
            {
            hotkey, IfWinActive, ahk_class AutoHotkeyGUI
            hotkey, enter,on
            return
            }
         }
      }
   }
}
}
else if(区域选择方式=3)
hotkey,#Lbutton,jietu3
Return

jietu3:
TrayTip
MouseGetPos, MX, MY
  Gui, Destroy
   Gui , +AlwaysOnTop -caption +Border +ToolWindow +LastFound
   WinSet, Transparent, 80
   Gui, Color, EEAA99
   Hotkey := RegExReplace(A_ThisHotkey,"^(\w* & |\W*)")
   While, (GetKeyState(Hotkey, "p"))
   {
      Sleep, 10
      MouseGetPos, MXend, MYend
      w := abs(MX - MXend), h := abs(MY - MYend)
      X := (MX < MXend) ? MX : MXend
      Y := (MY < MYend) ? MY : MYend
      Gui, Show, x%X% y%Y% w%w% h%h% NA
   }

   MouseGetPos, MXend, MYend
   If ((w < 10) or ( h < 10))
   {
    TrayTip,警告,拖拽间距过小或者未按提示进行操作，脚本将重新启动,3,18
    sleep,3000
    reload
   }
   If ( MX > MXend )
   Swap(MX, MXend)
   If ( MY > MYend )
   Swap(MY, MYend)
   aRect = %MX%, %MY%, %MXend%, %MYend%
   Gui, Color, 0058EE
   IfExist, Sound\shutter.wav
   SoundPlay, Sound\shutter.wav, wait
if(热键延迟截图=0)
   {
   Gui, Destroy
   CaptureScreen(aRect,0,0)
   gosub,CaptureSave
   }
if(热键延迟截图=1)
{
   hotkey, IfWinActive, ahk_class AutoHotkeyGUI
   hotkey,enter,on
}
Return

Esc::ExitApp

#IfWinActive,  ahk_class AutoHotkeyGUI
^s::
CaptureScreen(aRect,0,0)
gosub,ButtonCapture
return

Rbutton:: ExitApp

enter::
hotkey, IfWinActive, ahk_class AutoHotkeyGUI
hotkey, enter, off
Gui, Destroy
sleep,800
CaptureScreen(aRect,0,0)

CaptureSave:
if(询问=1){
  Gui +OwnDialogs
  SetTimer, ChangeButtonNames, 50
  OnMessage(0x53, "WM_HELP")
  msgbox,16387,截图,选定的区域已经截取,点击“是”自动保存。`n点击“否”打开画图，编辑图片。
     IfMsgBox Yes
     {
gosub,ButtonCapture
}
 IfMsgBox No
 {
  Run, mspaint.exe
  WinWaitActive,无标题 - 画图,,3
  if ErrorLevel
ExitApp
  Send,^v
}
Else
ExitApp
}
else{
gosub,ButtonCapture
}
ExitApp
#IfWinActive

Tip_info:
  TrayTip,截图进行中...,%cstip%,,17
Return

ButtonCapture:
FileName := "Regional_" A_Now
Convert(0,  截图保存目录 . "\" FileName "." . filetp)
ExitApp

WM_HELP(){
global filetp
WinClose,截图
InputBox,FileName,截图,`n输入截图文件名并保存文件,,440,160
if ErrorLevel=0
{
File:= 截图保存目录 . "\" FileName "." . filetp
if(Fileexist(File))
File:= 截图保存目录 . "\" . filename . "_" . A_Now . "." . filetp
Convert(0, File)
}
ExitApp
}

ChangeButtonNames:
IfWinNotExist, 截图
    return  ; Keep waiting.
SetTimer, ChangeButtonNames, off
WinActivate
ControlSetText, Button4, 重命名
return

Swap(ByRef Left, ByRef Right)
{
   temp := Left
   Left := Right
   Right := temp
}