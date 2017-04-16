;
; AHK版本: 		B:1.0.48.5 L:1.0.92.0
; 语言:			中文/English
; 平台:			Win7
; 作者:			海盗 <healthlolicon@gmail.com>
;
;
;
;
SplitPath,A_ScriptDir,,ParentDir
SetWorkingDir %ParentDir%

#NoEnv
SendMode Input
;SetWorkingDir %A_ScriptDir%  ;
#Include %A_ScriptDir%\..\Lib\String.ahk
Menu, Tray, Icon,pic\thunder.ico
OnExit,stop
Chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/

sFolder := "N:"
sUrl = %1%

IfInString, sUrl, thunder://
{

	StringReplace, surl, surl,thunder://,,All
	StringReplace, surl, surl, /,,All
      IfInString, surl,=
      {
        cut:=StrLen(surl)-InStr(surl,"=",false,1)+1
        StringTrimRight, surl, surl, %cut%
      }
      surl:=Base64Decode(surl)
      StringTrimLeft, surl, surl, 2
      StringTrimRight, surl, surl, 2
	}

StringGetPos,zpos,sUrl,/,R
zpos++
StringTrimLeft,sFile,sUrl,%zpos%

hModule := DllCall("LoadLibrary", "str", "XLDownload.dll")
Rtn1:=DllCall("XLDownload\XLInitDownloadEngine")


sFile := sFolder . "\" . sFile
news:= "`n`n文件" . sFile . "已下载完成!"
StrPutVar(sURL, Url, "UTF-16")
StrPutVar(sFile, File, "UTF-16")

rtn2:=DllCall("XLDownload\XLURLDownloadToFile","str",file,"str",URL,"Str",0,"intP",TaskID)
SetTimer,Query,1000
Return


;查询进度
Query:
retn:=DllCall("XLDownload\XLQueryTaskInfo","int",TaskID,"intP",TaskStatus,"Uint64P",FileSize,"Uint64P",RecvSize)
if retn=0
{
	if TaskStatus=0
	{
		traytip,已经建立连接
		Return
		}
	Else if TaskStatus=2
	{
		traytip,开始下载
	    Return
		}
	Else if TaskStatus=10
	{
        SetTimer,Query,off
		traytip,暂停下载
		beardboyTray("迅雷提示","`n`n文件下载失败",0,3000)
		WinWaitClose,迅雷提示
		Gosub,stop

		}
	Else if TaskStatus=11
	{
        SetTimer,Query,off
		beardboyTray("迅雷提示",news,1,3000)
		WinWaitClose,迅雷提示
		Gosub,stop
		}
	Else if TaskStatus=12
		{
		traytip,下载失败
		SetTimer,Query,off
		beardboyTray("迅雷提示","`n`n文件下载失败",0,3000)
		WinWaitClose,迅雷提示
		Gosub,stop
			}
	Else
    Return
}
else
{
	    traytip,出错
		SetTimer,Query,off
		beardboyTray("迅雷提示","`n`n文件下载失败",0,3000)
		WinWaitClose,迅雷提示
		Gosub,stop
	}
Return

Stop:
DllCall("XLDownload\XLStopTask","int",TaskID)
DllCall("XLDownload\XLUninitDownloadEngine")
DllCall("FreeLibrary", "UInt", hModule)
ExitApp



beardboyTray(title,text, sound = 0, timeout = 4000)
{
  global
  bt_title = %title%
  x := % A_ScreenWidth - 185
  y := % A_ScreenHeight - 30
  gui, 99:+ToolWindow +border
  gui, 99:color, FFFFFF
  gui, 99:Margin, 0, 0
  gui, 99:Add, Text, center w175 h90 cBlue, %text%
  Gui, 99:Show, x%x% y%y%, %title%

  if sound <> 0
    SoundPlay , Sound\download-complete.wav
	Else
	SoundPlay ,Sound\Windows Error.wav
  SetWinDelay, 5
  WinGetPos,, guiy,,, %title%
  Loop, 60
  {
    guiy -= 2
    WinMove, %title%,,, %guiy%
  }
  if timeout <> 0
    SetTimer, CloseTray, %timeout%
}

99GuiClose:
Gui, 99:Destroy
return

CloseTray:
SetTimer, CloseTray, Off
SetWinDelay, 5
WinGetPos,, guiy,,, %bt_title%
Loop, 60
{
  guiy += 2
  WinMove, %bt_title%,,, %guiy%
}
Gui, 99:Destroy
return

DeCode(c) { ; c = a char in Chars ==> position [0,63]
   Global Chars
   Return InStr(Chars,c,1) - 1
}
Base64Decode(code) {
   StringReplace, code, code, `r,,All
   StringReplace, code, code, `n,,All
   Loop Parse, code
   {
      m := A_Index & 3 ; mod 4
      IfEqual m,0, {
         buffer += DeCode(A_LoopField)
         out := out Chr(buffer>>16) Chr(255 & buffer>>8) Chr(255 & buffer)
      }
      Else IfEqual m,1, SetEnv buffer, % DeCode(A_LoopField) << 18
      Else buffer += DeCode(A_LoopField) << 24-6*m
   }
   IfEqual m,0, Return out
   IfEqual m,2, Return out Chr(buffer>>16)
   Return out Chr(buffer>>16) Chr(255 & buffer>>8)
}