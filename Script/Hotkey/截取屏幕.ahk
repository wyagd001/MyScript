#include %A_ScriptDir%\Lib\CaptureScreen.ahk

;截取全屏（PrintScreen）或窗口（Alt+PrintScreen）
;PrintScreen::
全屏截图:
CaptureScreen(0, True, 0)
ssFileName := "Screen_" A_Now

AfterCaptureScreen:
IfExist, %A_ScriptDir%\Sound\shutter.wav
SoundPlay, %A_ScriptDir%\Sound\shutter.wav, wait
if(询问=1)
{
 ;监视截图对话框帮助按钮
 OnMessage(0x53, "WM_HELP")
 Gui +OwnDialogs
 SetTimer, ChangeButtonNames, 50
 msgbox,16387,截图,屏幕已经截取,点击“是”自动保存。`n点击“否”打开画图，编辑图片。
  IfMsgBox Yes
  gosub,SaveCapture
  IfMsgBox No
   {
    Run, mspaint.exe
    WinWaitActive,无标题 - 画图,,3
    if ErrorLevel
    return
    Send,^v
    Return
   }
  Else
  return
}
else
gosub,SaveCapture
Return

;截取窗口带鼠标（Shift+PrintScreen）
;+PrintScreen::
窗口截图:
CaptureScreen(1, True, 0)
ssFileName := "Window_" A_Now
gosub AfterCaptureScreen
return

SaveCapture:
Convert(0,  screenshot_path . "\" ssFileName "." . filetp)
Return

ChangeButtonNames:
IfWinNotExist, 截图
    return  ; Keep waiting.
SetTimer, ChangeButtonNames, off
WinActivate
ControlSetText, Button4, 重命名
return

WM_HELP(){
global  filetp,screenshot_path
IfWinExist,截图
{
WinClose,截图
InputBox,SsFileName,截图,`n输入截图文件名并保存文件,,440,160
if ErrorLevel=0
{
File:= screenshot_path . "\" SsFileName "." . filetp
if(Fileexist(File))
File:= screenshot_path . "\" . Ssfilename . "_" . A_Now . "." . filetp
Convert(0, File)
}
}
}

/*
CaptureScreen(0, False, 0)   截屏不带鼠标
CaptureScreen(0, True, 0)    截屏带鼠标
CaptureScreen(1, False, 0)   截窗口不带鼠标
CaptureScreen(1, True, 0)    截窗口带鼠标
*/