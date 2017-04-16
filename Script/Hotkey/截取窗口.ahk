#include %A_ScriptDir%\Lib\Gdip.ahk

/*
PrintScreen::
Gdip_Startup()
FileName := SaveScreen(1.00,"%filetype%","Screen")
Return
*/

;~!PrintScreen::
;Gdip_Startup()
窗口截图二:
SsFileName:=SaveScreen(1.00,"Window",screenshot_path,"",filetp)
IfExist, %A_ScriptDir%\Sound\shutter.wav
SoundPlay, %A_ScriptDir%\Sound\shutter.wav, wait
sleep,100
if(询问=1)
{
 msgbox,3,截图,当前窗口已经截取保存,点击“是”返回,`n点击“否”打开画图，编辑图片,点击“取消”删除。
    IfMsgBox Yes
    Return
    IfMsgBox No
      {
        FileDelete,%screenshot_path%\%SsFileName%.%FileTp%
        Run, mspaint.exe
        WinWaitActive,无标题 - 画图,,3
        if ErrorLevel
        return
        Send,^v
        Return
      }
    Else
    FileDelete,%screenshot_path%\%SsFileName%.%FileTp%
}
Return