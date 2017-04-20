;
;
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
Chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/

sUrl = %1%
StringGetPos,zpos,sUrl,/,R
zpos++
StringTrimLeft,sFile,sUrl,%zpos%

Status=下载未开始
Percent=0
sp=0
Gui, Add, Text, x12 y20 w80 h25 , 下载链接：
Gui, Add, Edit, x80 y20 w310 h25 vsUrl gsUrl2sFlie,%sUrl%
Gui, Add, Text, x12 y50 w80 h25 , 保存路径：
Gui, Add, Edit, x80 y50 w310 h25 vsFolder, G:\Users\lyh\Desktop
Gui, Add, Button, x390 y50 w50 h25 gSelectFolder, 浏览
Gui, Add, Text, x12 y80 w80 h25 , 文件名称：
Gui, Add, Edit, x80 y80 w310 h25 vsFile,%sFile%

Gui, Add, Button, x12 y120 w50 h25 gDownLoad Default, 下载
Gui, Add, Button, x62 y120 w50 h25 vpause gPause, 暂停
Gui, Add, Button, x112 y120 w50 h25 vContinue gContinue, 恢复
Gui, Add, Button, x162 y120 w50 h25 vesc gStop, 取消
Gui, Add, Button, x212 y120 w60 h25 vrun grun, 打开文件
Gui, Add, Button, x272 y120 w80 h25 vview gview, 打开文件夹
GuiControl,disable,pause
GuiControl,disable,Continue
GuiControl,disable,esc
GuiControl,disable,run
GuiControl,disable,view
Gui, Add, Button, x390 y120 w50 h25 gOnExit, 退出

Gui, Add, Text, x12 y150 w80 h25 , 下载进度:
Gui, Add, Text, x70 y150  w25 vPercentText,%Percent%`%
Gui, Add, Text, x100 y150 w80 h25 , 速度:
Gui, Add, Text, x135 y150  w50 vSpeedText,%sp% K/S
Gui, Add, Text, x190 y150 w170 h25 vFileSize, 文件大小:
Gui, Add, Text, x360 y150 w110 vStatusText,状态:%Status%
Gui, Add, Text, x12 y165 w150 h25, 预计剩余时间:
Gui, Add, Text, x100 y165 w75 vsysj,%sysj%
Gui, Add, Progress, x12 y185 w445 h05 vMyProgress,0

Gui,show,,迅雷下载
WinGet, uniqueID ,,迅雷下载
;SetTimer,monitorurl,500
Return

OnExit:
GuiClose:
if hMoule!=0
	Gosub,Stop
ExitApp

SelectFolder:
   FileSelectFolder,tmpDir,,3,选择目录
   GuiControl,, sFolder, %tmpDir%
Return

DownLoad:
Gui, Submit, NoHide

If (surl="" or sfolder="" or sFile=""){
Return
}

news:= "`n`n文件 " . sFile . " 已下载完成!"

sFile := sFolder . "\" . sFile
IfExist %sFile%
{
SplitPath,sFile,,, ext,name_no_ext
name_no_ext:= name_no_ext . " - 副本"
NAE:= name_no_ext . "." . ext
sFile:= sFolder . "\" . NAE
GuiControl,,sFile,%NAE%
news:= "`n`n文件 " . NAE . " 已下载完成!"
}

;加载dll
hModule := DllCall("LoadLibrary", "str", "XLDownload.dll")
Rtn1:=DllCall("XLDownload\XLInitDownloadEngine")


;下载
;Ansi2Unicode(sUrl, URL, 0)
;Ansi2Unicode(sFile, File, 0)
StrPutVar(sURL, Url, "UTF-16")
StrPutVar(sFile, File, "UTF-16")

rtn2:=DllCall("XLDownload\XLURLDownloadToFile","str",file,"str",URL,"Str",0,"intP",TaskID)
;MsgBox %TaskID%
GuiControl,disable,run
GuiControl,disable,view
SetTimer,Query,100
SetTimer,Speed,1000
Return

;查询进度
Query:
retn:=DllCall("XLDownload\XLQueryTaskInfo","int",TaskID,"intP",TaskStatus,"Uint64P",FileSize,"Uint64P",RecvSize)
if retn=0
{
	if TaskStatus=0
		Status=已经建立连接
	Else if TaskStatus=2
	{
		Status=正在下载
        SetTaskbarProgress(Percent,0,uniqueID)

		}
	Else if TaskStatus=10
	{
		SetTimer,Query,off
		Status=暂停
		SetTaskbarProgress(Percent,"P",uniqueID)
		}
	Else if TaskStatus=11
	{
		;SetTimer,Query,off
		GuiControl,enable,run
		GuiControl,enable,view
		GuiControl,disable,esc
		GuiControl,disable,pause
		SetTaskbarProgress(100,0,uniqueID)
		finish=1
		Status=成功下载
		Gosub,finish
		}
	Else if TaskStatus=12
	   {
		;SetTimer,Query,off
		Status=下载失败
		finish=0
		Gosub,finish
		}
	Else
		Status=未知
    }
/*Else
{
SetTimer,Query,Off
GuiControl,disable,esc
GuiControl,disable,pause
Return
}
*/
GuiControl,,StatusText,状态:%Status%
FS := FileSize/1048576
FS:=Round(FS,4)
RS := RecvSize/1048576
RS:=Round(RS,4)
GuiControl,,FileSize,文件大小:%RS%/%FS% M
Percent:=RecvSize*100//FileSize
Percent:=Round(Percent,0)
GuiControl,,PercentText,%Percent%`%
GuiControl,,MyProgress,%Percent%
if TaskStatus=2
{
GuiControl,enable,esc
GuiControl,Enable,pause
	}
if(finish=1)
{
finish=3
beardboyTray("迅雷提示",news,1,3000)
WinWaitClose,迅雷提示
SetTaskbarProgress(0,0,uniqueID)
SetTimer,Query,off
SetTimer,speed,off
}
if(finish=0)
{
	finish=3
	beardboyTray("迅雷提示","`n`n文件下载失败",0,3000)
	WinWaitClose,迅雷提示
	SetTimer,Query,off
	SetTimer,speed,off
	}
Return

Speed:
if retn=0
{
rets1:=DllCall("XLDownload\XLQueryTaskInfo","int",TaskID,"intP","" ,"Uint64P","","Uint64P",RecvSize1)
sleep 1000
rets2:=DllCall("XLDownload\XLQueryTaskInfo","int",TaskID,"intP","" ,"Uint64P","","Uint64P",RecvSize2)
sp:=(RecvSize2-RecvSize1)/1024
sp:=Round(sp,1)
sykb:=(FileSize-RecvSize2)/1024
sysj :=sykb/sp/60
sysj:=Round(sysj,2)
GuiControl,,SpeedText,%sp% K/S
GuiControl,,sysj,%sysj% 分
}
Return

;monitorurl:
sUrl2sFlie:
GuiControlGet,surl,,sUrl
GuiControlGet,sFolder,,sFolder
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
GuiControl,,sFile,%sFile%

sFile := sFolder . "\" . sFile
IfExist %sFile%
{
SplitPath,sFile,,, ext,name_no_ext
name_no_ext:= name_no_ext . " - 副本"
NAE:= name_no_ext . "." . ext
sFile:= sFolder . "\" . NAE
GuiControl,,sFile,%NAE%
}

Return

;暂停   2016/07/04  暂停任务失效
Pause:
msggg:=DllCall("XLDownload\XLPauseTask","int",TaskID,"IntP",NewTaskID)
MsgBox %msggg% - %TaskID% - %NewTaskID%
TaskID:=NewTaskID
GuiControl,enable,Continue
Return

;恢复
Continue:
SetTimer,Query,100
DllCall("XLDownload\XLContinueTask","int",TaskID)
GuiControl,disable,Continue
Return

;取消
Stop:
DllCall("XLDownload\XLStopTask","int",TaskID)
DllCall("XLDownload\XLUninitDownloadEngine")
DllCall("FreeLibrary", "UInt", hModule)
SetTimer,Query,off
SetTimer,Speed,off
SetTaskbarProgress(0)
GuiControl,disable,esc
GuiControl,disable,Pause
GuiControl,disable,Continue
GuiControl,,FileSize,文件大小：
GuiControl,,StatusText,状态：取消下载
GuiControl,,PercentText,0`%
GuiControl,,SpeedText,0 K/S
GuiControl,,MyProgress,0
Return

finish:
SetTimer,Query,off
SetTimer,Speed,off
DllCall("XLDownload\XLStopTask","int",TaskID)
DllCall("XLDownload\XLUninitDownloadEngine")
DllCall("FreeLibrary", "UInt", hModule)
Return

run:
run %sFile%
Return

view:
oFile := sFile
IfInString, oFile, \\
	StringReplace, oFile, oFile,\\,\,All
If Fileexist(oFile)
	run % "explorer.exe /select," oFile
else
	msgbox % oFile
Return

; SetTaskbarProgress  -  Windows 7+
;  by lexikos, modified by gwarble for U64,U32,A32 compatibility
;
; pct    -  A number between 0 and 100 or a state value (see below).
; state  -  "N" (normal), "P" (paused), "E" (error) or "I" (indeterminate).
;           If omitted (and pct is a number), the state is not changed.
; hwnd   -  The hWnd of the window which owns the taskbar button.
;           If omitted, the Last Found Window is used.
;
SetTaskbarProgress(pct, state="", hwnd="") {
 static tbl, s0:=0, sI:=1, sN:=2, sE:=4, sP:=8
 if !tbl
  Try tbl := ComObjCreate("{56FDF344-FD6D-11d0-958A-006097C9A090}"
                        , "{ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf}")
  Catch 
   Return 0
 If hwnd =
  hwnd := WinExist()
 If pct is not number
  state := pct, pct := ""
 Else If (pct = 0 && state="")
  state := 0, pct := ""
 If state in 0,I,N,E,P
  DllCall(NumGet(NumGet(tbl+0)+10*A_PtrSize), "uint", tbl, "uint", hwnd, "uint", s%state%)
 If pct !=
  DllCall(NumGet(NumGet(tbl+0)+9*A_PtrSize), "uint", tbl, "uint", hwnd, "int64", pct*10, "int64", 1000)
Return 1
}

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
Loop, 55
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