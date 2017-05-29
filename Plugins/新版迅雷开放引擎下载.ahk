;
;
;
; AHK版本:	1.0.48.5(及以上版本)
; 语言:				中文
; 平台:				Win7 32位 测试通过
;
#NoEnv
SendMode Input

SplitPath,A_ScriptDir,,ParentDir
SetWorkingDir %ParentDir%
; xldl.dll 所在目录为工作目录
;SetWorkingDir %A_ScriptDir%
Menu, Tray, Icon,pic\thunder.ico
Chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/

sUrl = %1%
StringGetPos,zpos,sUrl,/,R
zpos++
StringTrimLeft,sFile,sUrl,%zpos%

OnExit ExitSub
Status=等待开始
Percent=0
sp=0
Gui, Add, Text, x12 y20 w80 h25 , 下载链接：
Gui, Add, Edit, x80 y20 w310 h25 vsUrl gsUrl2sFlie,%sUrl%
Gui, Add, Button, x390 y20 w60 h25 gxunlei,迅雷下载
Gui, Add, Text, x12 y50 w80 h25 , 保存路径：
Gui, Add, Edit, x80 y50 w310 h25 vsFolder, N:\
Gui, Add, Button, x390 y50 w60 h25 gSelectFolder, 浏览
Gui, Add, Text, x12 y80 w80 h25 , 文件名称：
Gui, Add, Edit, x80 y80 w310 h25 vsFile,%sFile%
Gui, Add, Button, x390 y80 w60 h25 vspeedlimit gspeedlimit,速度限制

Gui, Add, Button, x12 y120 w50 h25 vButtonDownLoad gDownLoad Default, 下载
Gui, Add, Button, x62 y120 w50 h25 vpause gPause, 暂停
Gui, Add, Button, x112 y120 w50 h25 vContinue gContinue, 恢复
Gui, Add, Button, x162 y120 w50 h25 vButtonCancel gStop, 取消
Gui, Add, Button, x212 y120 w60 h25 vopenfile grun, 打开文件
Gui, Add, Button, x272 y120 w80 h25 vopenpath gview, 打开文件夹
GuiControl,disable,speedlimit
GuiControl,disable,pause
GuiControl,disable,Continue
GuiControl,disable,ButtonCancel
GuiControl,disable,openfile
GuiControl,disable,openpath 
Gui, Add, Button, x390 y120 w60 h25 gExitsub, 退出

Gui, Add, Text, x12 y150 w80 h25 , 下载进度:
Gui, Add, Text, x70 y150  w30 vPercentText,%Percent%`%
Gui, Add, Text, x100 y150 w80 h25 , 速度:
Gui, Add, Text, x135 y150  w60 vSpeedText,%sp% K/S
Gui, Add, Text, x200 y150 w170 h25 vFileSize, 文件大小:
Gui, Add, Text, x370 y150 w110 vStatusText,状态:%Status%
Gui, Add, Text, x12 y165 w150 h25, 预计剩余时间:
Gui, Add, Text, x100 y165 w75 vsysj,%sysj%
Gui, Add, Progress, x12 y185 w445 h05 vMyProgress,0

Gui,show,,迅雷下载
WinGet, uniqueID ,,迅雷下载
;SetTimer,monitorurl,1000
Return

;使用迅雷下载
^k::
xunlei:
	Gui, Submit, NoHide
	If !hModule
	{
		hModule:=DllCall("LoadLibrary", "str", "xldl.dll")
		DllCall("xldl\XL_Init")
	}
	qq:=DllCall("xldl\XL_CreateTaskByThunder","str",sUrl,"str",sFile,"str",0,"str",0,"str",0)
	If (qq!=0)
	{
		try {
			thunder := ComObjCreate("ThunderAgent.Agent")
			thunder.AddTask( sUrl  ;下载地址
			       , sFile  ;另存文件名
			       , "N:\"  ;保存目录
			       , "ahk_迅雷"  ;任务注释
			       , ""  ;引用地址
			       , 1 ;开始模式
			       , true  ;只从原始地址下载
			       , 10 )  ;从原始地址下载线程数
			thunder.CommitTasks()
		}
		Catch, e {
			MsgBox, 抱歉，您未安装迅雷或Dll文件没有注册。
		}
	}
Return

;限速
^S::
speedlimit:
	InputBox,limitspeed,限制下载速度,输入最大的下载速度，单位 KB/s,,,120
	DllCall("xldl\XL_SetSpeedLimit","int",limitspeed)
Return

ExitSub:
GuiClose:
	If hModule!=0
	{
		VarSetCapacity(DelTaskParam, 26564, 0)
		StrPut(szFilename,&DelTaskParam + 16532,-1,1200)
		StrPut(sFolder,&DelTaskParam + 17572,-1,1200)
		DllCall("xldl\XL_StopTask","int",TaskID)
		DllCall("xldl\XL_DeleteTask","int",TaskID)
		SetTimer,Query,off
		;SetTimer,monitorurl,off
		DllCall("xldl\XL_UnInit")
		DllCall("FreeLibrary", "UInt", hModule)
		ExitApp
	}
	Else
		ExitApp

SelectFolder:
	FileSelectFolder,tmpDir,,3,选择目录
	GuiControl,, sFolder, %tmpDir%
Return

DownLoad:
	Gui, Submit, NoHide
	If (surl="" or sfolder="" or sFile="")
		Return
	news:= "`n`n文件 " . sFile . " 已下载完成!"

	; 加载dll
	If !hModule
	{
		hModule := DllCall("LoadLibrary", "str", "xldl.dll")
		Rtn1:=DllCall("xldl\XL_Init")
	}
	; 下载参数
	DownTaskParam =""
	VarSetCapacity(DownTaskParam, 26564, 0)
	StrPut(sUrl,&DownTaskParam + 4,-1,1200)
	StrPut(sFile,&DownTaskParam + 16532,-1,1200)
	StrPut(sFolder,&DownTaskParam + 17572,-1,1200)
	NumPut(1,&DownTaskParam,18368,"int")
	VarSetCapacity(DownTaskInfo, 1432, 0)

	TaskID:=DllCall("xldl\XL_CreateTask","int",&DownTaskParam,"Cdecl")
	qq1:=DllCall("xldl\XL_StartTask","int",TaskID)

	GuiControl,disable,ButtonDownLoad
	GuiControl,disable,openfile
	GuiControl,enable,openpath
	GuiControl,enable,speedlimit
	SetTimer,Query,100
Return

;查询进度
Query:
	retn:=DllCall("xldl\XL_QueryTaskInfoEx","int",TaskID,"int",&DownTaskInfo,"Cdecl")
	stat:= numGet(&DownTaskInfo,0,"int")
	fail_code:= numGet(&DownTaskInfo,4,"int")
	szFilename:= StrGet(&DownTaskInfo+8,520,1200)
	nTotalSize:=numGet(&DownTaskInfo,1048,"int64")
	nTotalDownload:=numGet(&DownTaskInfo,1056,"int")
	fPercent:=numGet(&DownTaskInfo,1064,"Float")
	nSpeed:=numGet(&DownTaskInfo,1152,"int")

	If retn=1
	{
		If stat=0
			Status=未建立连接
		Else If stat=3	; 正在下载
		{
			Status=正在下载
			GuiControl,enable,ButtonCancel
			GuiControl,Enable,pause
			SetTaskbarProgress(Percent,0,uniqueID)
		}
		Else If stat=2	; 下载暂停
		{
			SetTimer,Query,off
			Status=下载暂停
			SetTaskbarProgress(Percent,"P",uniqueID)
		}
		Else If stat=4	; 下载完成
		{
			GuiControl,disable,speedlimit
			GuiControl,enable,ButtonDownLoad
			GuiControl,disable,pause
			GuiControl,disable,ButtonCancel
			GuiControl,enable,openfile
			GuiControl,enable,openpath

			SetTaskbarProgress(100,0,uniqueID)
			finish=1
			Status=下载完成
			Gosub,finish
		}
		Else If stat=1 ; 下载出错
		{
			;SetTimer,Query,off
			Status=下载出错
			finish=0
			Gosub,finish
		}
		Else If stat= 5
			Status=正在开始
		Else
			Status=正在停止
	}

	GuiControl,,StatusText,状态:%Status%
	FS := nTotalSize/1048576
	FS:=Round(FS,4)
	RS := nTotalDownload/1048576
	RS:=Round(RS,4)
	GuiControl,,FileSize,文件大小:%RS%/%FS% M
	Percent:= fPercent*100
	Percent:=Round(Percent,1)
	GuiControl,,PercentText,%Percent%`%
	GuiControl,,MyProgress,%Percent%
	sp:=nSpeed/1024
	sp:=Round(sp,0)
	GuiControl,,SpeedText,%sp% K/S
	sykb:=(nTotalSize-nTotalDownload)/1024
	sysj :=sykb/sp/60
	sysj:=Round(sysj,2)
	GuiControl,,sysj,%sysj% 分

	If(finish=1)
	{
		finish=3
		beardboyTray("迅雷提示",news,1,3000)
		WinWaitClose,迅雷提示
		SetTaskbarProgress(0,0,uniqueID)
		SetTimer,Query,off
	}
	If(finish=0)
	{
		finish=3
		beardboyTray("迅雷提示","`n`n文件下载取消或失败",0,3000)
		SetTimer,Query,off
		WinWaitClose,迅雷提示
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

	Filefullpath := sFolder . "\" . sFile
	If(fileExist(Filefullpath) and sFile and sUrl)
	{
		SplitPath,sFile,,, ext,name_no_ext
		name_no_ext:= name_no_ext . "(1)"
		NAE:= name_no_ext . "." . ext
		Filefullpath:= sFolder . "\" . NAE
		GuiControl,,sFile,%NAE%
	}
Return

;暂停
Pause:
	msggg:=DllCall("xldl\XL_StopTask","int",TaskID)
	GuiControl,enable,Continue
Return

;恢复
Continue:
	SetTimer,Query,100
	DllCall("xldl\XL_StartTask","int",TaskID)
	GuiControl,disable,Continue
Return

;取消
Stop:
	SetTimer,Query,off
	Sleep,500

	VarSetCapacity(DelTaskParam, 26564, 0)
	StrPut(szFilename,&DelTaskParam + 16532,-1,1200)
	StrPut(sFolder,&DelTaskParam + 17572,-1,1200)
	DllCall("xldl\XL_StopTask","int",TaskID)
	DllCall("xldl\XL_DeleteTask","int",TaskID)
	DllCall("xldl\XL_DelTempFile","int",&DelTaskParam)

	;SetTimer,monitorurl,off
	SetTaskbarProgress(0)
	GuiControl,disable,speedlimit
	GuiControl,enable,ButtonDownLoad
	GuiControl,disable,Pause
	GuiControl,disable,Continue
	GuiControl,disable,ButtonCancel
	GuiControl,disable,openpath
	GuiControl,,FileSize,文件大小：
	GuiControl,,StatusText,状态：下载取消
	GuiControl,,PercentText,0`%
	GuiControl,,SpeedText,0 K/S
	GuiControl,,MyProgress,0
Return

finish:
	SetTimer,Query,off
	DllCall("xldl\XL_StopTask","int",TaskID)
	DllCall("xldl\XL_DeleteTask","int",TaskID)
Return

run:
	;msgbox % FileFullPath
	run %Filefullpath%
Return

;根目录在 C:\\ 的情况
view:
	If(Filefullpath="")
	{
		Gui, Submit, NoHide
		Filefullpath := sFolder . "\" . sFile
	}
	oFilefullpath := Filefullpath
	IfInString, oFilefullpath, \\
		StringReplace, oFilefullpath, oFilefullpath,\\,\,All
	If Fileexist(oFileFullPath)
		run % "explorer.exe /select," oFileFullPath
	Else
		msgbox % oFileFullPath
Return

; SetTaskbarProgress  -  Windows 7+
; by lexikos, modified by gwarble for U64,U32,A32 compatibility
;
; pct    -  A number between 0 and 100 or a state value (see below).
; state  -  "N" (normal), "P" (paused), "E" (error) or "I" (indeterminate).
;  If omitted (and pct is a number), the state is not changed.
; hwnd   -  The hWnd of the window which owns the taskbar button.
;  If omitted, the Last Found Window is used.
;
SetTaskbarProgress(pct, state="", hwnd="") {
	static tbl := ""
	If (!tbl){
		Try tbl := ComObjCreate("{56FDF344-FD6D-11d0-958A-006097C9A090}"
		                   , "{ea1afb91-9e28-4b86-90e9-9e9f8a5eefaf}")
	}

	State := (State = "I" ? 1 : State = "N" ? 2 : State = "E" ? 4 : State = "P" ? 8 : 0)
	Hwnd := (Hwnd = "" ? WinExist() : Hwnd)

	DllCall(NumGet(NumGet(tbl+0)+10*A_PtrSize), "Ptr", tbl, "Ptr", hwnd, "uint", state)
	If pct !=
		DllCall(NumGet(NumGet(tbl+0)+9*A_PtrSize), "Ptr", tbl, "Ptr", hwnd, "int64", pct*10, "int64", 1000)
Return (TBL ? 0 : 1)
}

beardboyTray(title,text, sound = 0, timeout = 4000)
	{
		global
		bt_title = %title%
		x := % A_ScreenWidth - 185
		y := % A_ScreenHeight - 30
		Gui, 99:+ToolWindow +border
		Gui, 99:color, FFFFFF
		Gui, 99:Margin, 0, 0
		Gui, 99:Add, Text, center w175 h90 cBlue, %text%
		Gui, 99:Show, x%x% y%y%, %title%

		If sound <> 0
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
		If timeout <> 0
			SetTimer, CloseTray, %timeout%
}

99GuiClose:
	Gui, 99:Destroy
Return

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
Return

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