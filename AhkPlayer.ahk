/*
下一首:^+F5
上一首: ^+F3
暂停:^+P
加入列表:!F10
显示隐藏歌词:!F8
手气不错：!F9
跳转到指定时间：!F3
编辑歌词：!F5
显示隐藏界面：!F7
移动歌词位置：!F6
退出：^+E
*/

#Persistent
#NoTrayIcon
#SingleInstance force
SetBatchLines, 10ms
DetectHiddenWindows On
SetTitleMatchMode 2
#MaxThreads,255
FileEncoding,CP1200
CoordMode, ToolTip
SingleCycle := false
run_iniFile = %A_ScriptDir%\settings\setting.ini
IniRead, AhkMediaLib, %run_iniFile%, AhkPlayer, AhkMediaLib
IniRead, TTPlayer, %run_iniFile%, AudioPlayer, TTPlayer
IniRead, AutoUpdateMediaLib, %run_iniFile%, AhkPlayer, AutoUpdateMediaLib
IniRead, Lrcfontcolor, %run_iniFile%, AhkPlayer, Lrcfontcolor
IniRead, LrcPath, %run_iniFile%, AhkPlayer, LrcPath
IniRead, LrcPath_Win10, %run_iniFile%, AhkPlayer, LrcPath_Win10
IniRead, LrcPath_2, %run_iniFile%, 路径设置, LrcPath
IniRead, followmouse, %run_iniFile%, AhkPlayer, followmouse
IniRead, PlayListdefalut, %run_iniFile%, AhkPlayer, PlayListdefalut
IniRead, PlayRandom, %run_iniFile%, AhkPlayer, PlayRandom
IniRead, huifushangci, %run_iniFile%, AhkPlayer, huifushangci
IniRead, notepad2, %run_iniFile%, otherProgram, notepad2
lrceditor:=notepad2?notepad2:notepad.exe

global DB := new SQLiteDB
global DBPATH:= A_ScriptDir . "\Settings\AhkPlayer\musiclib.db"
			if (!FileExist(DBPATH))
				isnewdb := 1
			else
				isnewdb := 0
				
if (!DB.OpenDB(DBPATH))
				MsgBox, 16, SQLite错误, % "消息:`t" . DB.ErrorMsg . "`n代码:`t" . DB.ErrorCode
				
if (isnewdb == 1)
migrateHistory()

hidelrc=0
PlaylistIndex=1
ErrCounter:=0
LrcPath:=(SubStr(A_OSVersion, 1, 2)=10)?LrcPath_Win10:LrcPath
LrcPath:=FileExist(LrcPath)?LrcPath:(FileExist(LrcPath_2)?LrcPath_2:"")
AhkMediaLibFile = %A_ScriptDir%\settings\AhkPlayer\mp3s.txt
AhkMediaListFile =  %A_ScriptDir%\settings\AhkPlayer\playlist.txt
historyFile = %A_ScriptDir%\Settings\AhkPlayer\history.txt

If (PlayListdefalut="t") || A_Args.Length()>0
{
	NowPlayFile := AhkMediaListFile
	if A_Args.Length()>0
	{
		IniWrite, % A_Args[A_Args.Length()], %run_iniFile%, AhkPlayer, Mp3Playing
		for n, param in A_Args
		{
			SplitPath, param,,,ext
			If ext in mp3,wma,wmv,wav,mpg,mid,mp4,m4a			;这是我目前已知的能用soundplay播放的格式
				Fileappend,%param%`n, %AhkMediaListFile%
		}
	}
}
else
	NowPlayFile := AhkMediaLibFile

Gui, 2: +LastFound +alwaysontop -Caption +Owner -SysMenu
Gui, 2:Margin, 0
Gui, 2:Color, FF0F0F
Gui, 2:Font, s24,msyh    ;Gui, 2:Font, s24 bold
Gui, 2:add, Text, w1000 r1.9 c%Lrcfontcolor% vlrc,
posy:=A_ScreenHeight-130
WinSet, TransColor, FF0F0F
WinSet, ExStyle, +0x20
Gui, 2:Show, Hide x150 y%posy%

Menu, FileMenu, Add, 添加文件(&F), MenuFileAdd
Menu, FileMenu, Add, 添加文件夹(&D), MenuFolderAdd
Menu, FileMenu, Add, 保存列表(&S), saveplaylist
Menu, FileMenu, Add, 退出(&X), Exit
Menu, EditMenu, Add, 播放所选(单选)(&O), MenuOpen
Menu, EditMenu, Add, 从列表中删除(&R), MenuRemove
Menu, EditMenu, Add, 清空列表(&C), MenuClear
Menu, EditMenu, Add, 打开文件位置(单选)(&C), MenuOpenFilePath

Menu, PlayBack, Add, 暂停/播放(&P), MyPause
Menu, PlayBack, Add, 停止(&S), Stop
Menu, PlayBack, Add, 跳转到(&J), Jump
Menu, PlayBack, Add, 上一首(&V), Prev
Menu, PlayBack, Add, 下一首(&N), Next
Menu, PlayBack, Add
Menu, PlayBack, Add, 顺序播放(&D), CheckPlayorder
Menu, PlayBack, Add, 随机播放(&R), CheckPlayorder
Menu, PlayBack, Add, 单曲循环(&E), CheckPlayorder
Menu, PlayBack, Add
Menu, PlayBack, Add, 下一首跟随鼠标(&F), PTLF
Menu, PlayBack, Add, 播放列表(&L), PTList
Menu, PlayBack, Add, 播放媒体库(&M), PTLib

Menu, Lib, Add, 打开歌词库(&L), OpenLrc
Menu, Lib, Add, 打开媒体库(&M), OpenLib
Menu, Lib, Add, 打开配置文件夹(&F), OpenOptionFolder
Menu, Lib, Add
Menu, Lib, Add, 编辑歌词(&E), EditLrc
Menu, Lib, Add, 编辑配置文件(&O), EditOption
Menu, Lib, Add
Menu, Lib, Add, 启动恢复上次播放(&H),HuiFuShangCiPlay
Menu, Lib, Add, 更新媒体库(&U),UpdateMediaLib
Menu, Lib, Add, 启动自动更新媒体库(&A),AutoUpdateMediaLib

Menu, Help, Add, 关于(&A), About
If (PlayRandom="t")
	Menu,PlayBack,Check,随机播放(&R)
else
	Menu,PlayBack,Check,顺序播放(&D)

If (followmouse="t")
		Menu,PlayBack,Check,下一首跟随鼠标(&F)

If (PlayListdefalut="t")
{
	Menu,PlayBack,Check,播放列表(&L)
	Menu,PlayBack,Disable,播放列表(&L)
}
Else
{
	Menu, PlayBack, Check,播放媒体库(&M)
	Menu,PlayBack,Disable,播放媒体库(&M)
}

if (AutoUpdateMediaLib="t")
	Menu, Lib, Check,启动自动更新媒体库(&A)
if (huifushangci = "t")
	Menu, Lib, Check,启动恢复上次播放(&H)

Menu, MyMenuBar, Add, 文件(&F), :FileMenu
Menu, MyMenuBar, Add, 编辑(&E), :EditMenu
Menu, MyMenuBar, Add, 控制(&P), :PlayBack
Menu, MyMenuBar, Add, 选项(&O), :Lib
Menu, MyMenuBar, Add, 帮助(&H), :Help

OnExit ExitSub

Gosub,GuiShow
SetTimer,CheckStatus,250
SetTimer,Updatevolume,2000

if (AutoUpdateMediaLib="t")
	Gosub, UpdateMediaLib
Else
{
	sleep,1000
	IfNotExist,%AhkMediaLibFile%
		Gosub, UpdateMediaLib
}

if (huifushangci = "t") || A_Args.Length()>0
	Gosub,HuifuPlay
else
	Gosub, StarPlay
Return

HuiFuShangCiPlay:
	IniRead, huifushangci, %run_iniFile%, AhkPlayer,huifushangci
	If (huifushangci ="t")
	{
		Menu,Lib,unCheck,启动恢复上次播放(&H)
		IniWrite,f, %run_iniFile%, AhkPlayer, huifushangci
	}
	Else
	{
		Menu,Lib,Check,启动恢复上次播放(&H)
		IniWrite,t, %run_iniFile%, AhkPlayer, huifushangci
	}
Return

AutoUpdateMediaLib:
	IniRead, AutoUpdateMediaLib, %run_iniFile%, AhkPlayer,AutoUpdateMediaLib
	If (AutoUpdateMediaLib ="t")
	{
		Menu,Lib,unCheck,启动自动更新媒体库(&A)
		IniWrite,f, %run_iniFile%, AhkPlayer, AutoUpdateMediaLib
	}
	Else
	{
		Menu,Lib,Check,启动自动更新媒体库(&A)
		IniWrite,t, %run_iniFile%, AhkPlayer, AutoUpdateMediaLib
	}
Return

UpdateMediaLib:
	Count = 0
	Tmp_Val := ""
	filelistarray := {}
	FileDelete, %AhkMediaLibFile%
	Loop, %AhkMediaLib%\*.*, 0,1
	{
		mp3_loop := A_loopfilename

		Splitpath, mp3_loop,,,Extension
		if (Extension != "mp3" && Extension != "wma")
			Continue
		else
		{
			Tmp_Val .= a_loopfilefullpath "`n"
			filelistarray[a_loopfilefullpath]:=1
			Count++
		}
	}
	FileAppend, % Tmp_Val, %AhkMediaLibFile%
	updateMlib()
	Tmp_Val := ""
	Count -= 1
	IniWrite, %Count%, %run_iniFile%, AhkPlayer, Count
	CF_ToolTip("更新媒体库完毕!		",2500)
	if (PlayListdefalut="f")
		gosub PTLib
Return

HuifuPlay:
	IniRead, Mp3, %run_iniFile%, AhkPlayer, Mp3Playing
	IniRead, PlaylistIndex, %run_iniFile%, AhkPlayer, PlaylistIndex, 0
	if A_Args.Length()>0
		LV_Modify(LV_GetCount(),"+Select +Focus +Vis")
	else
		LV_Modify(PlaylistIndex,"+Select +Focus +Vis")
	; 打开文件
	goto, Gplay
Return

StarPlay:
	If hSound 
	{
		MCI_Stop(hSound)
		MCI_Close(hSound)
	}

	if SingleCycle
		goto Gplay

	Count :=TF_CountLines(NowPlayFile)
	;IniRead, PlayRandom, %run_iniFile%, AhkPlayer, PlayRandom
	;IniRead, followmouse, %run_iniFile%, AhkPlayer, followmouse
	;IniRead, PlayListdefalut, %run_iniFile%, AhkPlayer, PlayListdefalut

	if (PlayRandom = "t")  ; 随机播放
	{
			if (followmouse="t")   ; 跟随鼠标
			{
				if (PlaylistIndex != LV_GetNext(Row))
				{
					PlaylistIndex:=LV_GetNext(Row)
				}
				else   ; 鼠标所在行是上一首播放的
				{
					Random, Rand, 1, %Count%
					LV_Modify(0,"-Select")
					LV_Modify(Rand,"+Select +Focus +Vis")
					PlaylistIndex:=LV_GetNext(Row)
				}
			}
			else   ; 不跟随鼠标
			{
				Random, Rand, 1, %Count%
				LV_Modify(0,"-Select")
				LV_Modify(Rand,"+Select +Focus +Vis")
				PlaylistIndex:=LV_GetNext(Row)
			}
		LV_GetText(Mp3,PlaylistIndex,4)
	}
	else   ; 顺序播放
	{
			if (PlaylistIndex>=LV_GetCount())
				PlaylistIndex:=1
			else if (followmouse="t")
			{
				if (PlaylistIndex=LV_GetNext(Row))
				{
					PlayListIndex++
					if (PlaylistIndex>LV_GetCount())
						PlaylistIndex:=1
				}
				Else
					PlaylistIndex:=LV_GetNext(Row)
			}
			Else
				PlayListIndex++
			LV_GetText(Mp3,PlaylistIndex,4)
			LV_Modify(0,"-Select")
			LV_Modify(PlaylistIndex,"+Select +Focus +Vis")
	}
	IniWrite, %mp3%, %run_iniFile%, AhkPlayer, Mp3Playing
	Iniwrite, %PlaylistIndex%, %run_iniFile%,AhkPlayer, PlaylistIndex

Gplay:
if (mp3!="位置")
{
FileRead, Tmp_Val, %historyFile%
file := FileOpen(historyFile, "w", "UTF-16")
file.Write(mp3 "`r`n" Tmp_Val)
file.close()
Tmp_Val := ""
}
	hSound := MCI_Open(Mp3, "myfile")
	if !hSound
	{
		ErrCounter+=1
		if (ErrCounter>10)
		{
			Gosub, MyPause
			return
		}
	}
	else
		ErrCounter:=0
	SetTimer UpdateSlider,off
	GUIControl,,Slider,0
	GUIControl,Disable,Slider
	Gosub, MyPause
	len := MCI_Length(hSound)
	GUIControl,Enable,Slider
	SetTimer,UpdateSlider,100
	SetTimer,CheckStatus,250
	Gosub, ToolTipMP3
	; Gosub命令：程序跳转到ToolTipMP3标签，执行标签下的语句，遇到Return或break返回，
	; 才继续执行该行下面的语句即继续执行Gosub, StarPlay   Goto命令则不会返回
	; 播放下一首歌曲
	Gosub, StarPlay
Return

Gplay2:
	IniWrite, %mp3%, %run_iniFile%, AhkPlayer, Mp3Playing
if (mp3!="位置")
{
FileRead, Tmp_Val, %historyFile%
file := FileOpen(historyFile, "w", "UTF-16")
file.Write(mp3 "`r`n" Tmp_Val)
file.close()
Tmp_Val := ""
}
	if (PlayListdefalut="t") && (PlayRandom = "f")
		Iniwrite, %PlaylistIndex%, %run_iniFile%,AhkPlayer, PlaylistIndex
	SetTimer UpdateSlider,off
	GUIControl,,Slider,0
	GUIControl Disable,Slider
	If hSound
	{
		MCI_Stop(hSound)
		MCI_Close(hSound)
	}
	hSound := MCI_Open(Mp3, "myfile")
	Gosub, MyPause
	GUIControl Enable,Slider
	Gosub, sNameTrim
	len := MCI_Length(hSound)
	MCI_ToHHMMSS2(pos, hh, mm, ss)
	MCI_ToHHMMSS2(len, hh, lm, ls)
	SetTimer UpdateSlider,100
	SetTimer,CheckStatus,250
	if (ErrCounter=11)
	{
		ErrCounter:=0
		Gosub, StarPlay
	}
Return

CreatContext:
Menu, Context, Add, 播放(单选), PlayLV
Menu, Context, Add, 千千静听打开(单选), TTplayerOpen
Menu, Context, Add, 打开文件位置(单选), OpenfilePath
Menu, Context, Add, 添加到列表, AddList
Menu, Context, Add, 从列表中删除(可多选), Remove
Menu, Context, Add, 清空列表, Remove
Menu, Context, Add, 清除列表中的重复与无效项, RemoveDuplicateInvalid
return

GuiShow:
Gui, Menu, MyMenuBar

pld:=(PlayListdefalut="t")?1:2
Gui, Add,DropDownList, vSelectedplaylist y5 w80 gSelectPlayList Choose%pld%,默认列表|媒体库|历史列表
spo:=(PlayRandom="t")?2:1
Gui, Add,DropDownList, x+5 yp w80 vSelectedPlayorder gSelectPlayorder Choose%spo%,默认|随机|单曲循环
Gui, Add,Edit, x+5 yp+1  w250 vfind
Gui, Add,Button, x+5 yp h20 gfind Default,查找
Gui, Add,Button, x+5 yp h20 grefreshList,返回列表
Gui, Add,Button, x+5 yp h20 gFindToList,追加到列表

Gui, Add,ListView ,xm Grid w600 h400 gListView Count5000 vListView Altsubmit, 序号|曲名|类型|位置|创建时间|上次播放|大小|播放次数
Gui, Add,Slider,xm w600 h25 +Disabled -ToolTip vSlider page1 gSlider AltSubmit
Gui, Add,Picture,xm+150 y+10 vstop gStop,%A_ScriptDir%\pic\AhkPlayer\stop.bmp
Gui, Add,Picture,x+1 yp-1 gprev,%A_ScriptDir%\pic\AhkPlayer\prev.bmp
Gui, Add,Picture,x+1 yp-10 gMyPause vpausepic,%A_ScriptDir%\pic\AhkPlayer\play.bmp
Gui, Add,Picture,x+1 yp+10 gnext,%A_ScriptDir%\pic\AhkPlayer\next.bmp
Gui, Add,Picture, x+10 yp w32 h32 gmute vvol, %A_ScriptDir%\pic\vol.ico
Gui, Add,Slider, x+1 yp+10 w100 h20 vVSlider Range0-100 +ToolTip  gSetVolume
Gui, font,cred bold s24,Verdana
Gui, Add, text, x+5 yp-15  vLrcS  gLrcShow ,Lrc
Gui, font
Gui, Add, StatusBar, xm yp w600 h30, 未播放文件
if !LrcPath
	GuiControl, Disable, LrcS
vol_Master := VA_GetVolume()
Guicontrol,,VSlider,%vol_Master%
SB_SetParts(300,100,220)
SB_SetProgress(0 ,3,"-smooth")
gosub CreatContext
If (PlayListdefalut="t"){
AhkPlayer_Title:="播放列表 - AhkPlayer"
gosub,refreshList
}
else
{
AhkPlayer_Title:="播放媒体库 - AhkPlayer"
if !mLiblistview()
gosub,refreshList
menu, Context, DeleteAll
}
Gui,Show,,%AhkPlayer_Title%
Return

; 停止播放，返回开头
Stop:
  SetTimer,CheckStatus,Off
  MCI_Stop(hSound)
  MCI_Seek(hSound,0)
  Menu, PlayBack, Check,停止(&S)
  Gui,2:hide
  lrcclear()
  SetTimer, clock,Off
  GUIControl,,Slider,0
  gosub,CheckStatus
Return

ToolTipMP3:
	if (Exit = true)
		Exit
	;   例如前一个热键仍在执行时又按了另一个热键，那么当前线程将被中断(暂时地停止)以允许新的线程变成当前的线程
	;	  StarPlay中的ToolTipMP3为当前进程，按下!F9后，当前进程终止进入休眠状态,!F1的ToolTipMP3变为当前的线程
	;   当!F9的ToolTipMP3线程运行完毕之后，StarPlay中的ToolTipMP3恢复
	;   所以按下!F9播放后，热键的线程在持续运行时，再次按下热键没用，因为上一次的热键还没有结束
	Exit = false
	Gosub, sNameTrim
	len := MCI_Length(hSound)

	Loop {
	IniRead, ToolMode, %run_iniFile%, AhkPlayer, ToolMode
	IniRead, ToolX, %run_iniFile%, AhkPlayer, ToolX
	IniRead, ToolY, %run_iniFile%, AhkPlayer, ToolY
			Sleep 100
			pos := MCI_Position(hSound)
			If(pos >= len){
			IniWrite, %mp3%, %run_iniFile%, AhkPlayer, LastPlay
			if (PlayListdefalut = "f")
			{
				updatemusicfile(mp3)
			}
			Break
	}

	MCI_ToHHMMSS2(pos, hh, mm, ss)
	MCI_ToHHMMSS2(len, lhh, lm, ls)
	;If (ToolMode = 0)
			;tooltip
	 If (ToolMode = 1){
		    if lhh=0
			ToolTip, %sName%`n%mm%:%ss% / Length %lm%:%ls%, %ToolX%, %ToolY%
			else
			ToolTip, %sName%`n%hh%:%mm%:%ss% / Length %lhh%:%lm%:%ls%, %ToolX%, %ToolY%
			}
	Else If (ToolMode = 2)
	{
		if lhh=0
		ToolTip, %sName%`n%mm%:%ss% / Length %lm%:%ls%`n%mp3%, %ToolX%, %ToolY%
        else
		ToolTip, %sName%`n%hh%:%mm%:%ss% / Length %lhh%:%lm%:%ls%`n%mp3%, %ToolX%, %ToolY%
}
}
Return

PlayfromList:
	FileReadLine, Mp3, %AhkMediaLibFile%, %PlayIndex%
	If hSound
		MCI_Close(hSound)
	hSound := MCI_Open(Mp3, "myfile")
	MCI_Play(hSound)
	if(hidelrc=0)
		Gosub, Lrc
	Gosub, sNameTrim
	len := MCI_Length(hSound)
	MCI_ToHHMMSS2(pos, hh, mm, ss)
	MCI_ToHHMMSS2(len, hh, lm, ls)
Return 

ListReadWrite:
	IniRead, Count, %run_iniFile%, AhkPlayer, Count
	IniRead, PlayIndex, %run_iniFile%, AhkPlayer, PlayIndex

if (A_ThisHotkey="PgUp")
	PlayIndex-=1
if (A_ThisHotkey="PgDn")
	PlayIndex+=1

if (PlayIndex=0)
	PlayIndex := Count
if (PlayIndex > Count)
	PlayIndex = 1

	IniWrite, %PlayIndex%, %run_iniFile%, AhkPlayer, PlayIndex
Return

sNameTrim:
	StringLen, sLength, mp3
	StringGetPos, cTrim, mp3, \, R1
	cTrim += 2
	fName := (sLength+1) - cTrim
	StringMid, sName, mp3, %cTrim%, %fName%
Return

Lrc:
	lrcclear()
	SetTimer, clock, Off
	newname:=""
	SplitPath, Mp3,,,ext, name
	If FileExist(LrcPath "\" name ".lrc")
	{
		Menu,Lib,Enable,编辑歌词(&E)
		lrcECHO(LrcPath . "\" . name . ".lrc", name)
	Return
	}
	else If FileExist(LrcPath_2 "\" name ".lrc")
	{
		Menu,Lib,Enable,编辑歌词(&E)
		lrcECHO(LrcPath_2 . "\" . name . ".lrc", name)
	Return
	}
	Else
	{
		newname:=StrReplace(name, " - ", "-",,1)
		If FileExist(LrcPath "\" newname ".lrc")
		{
			Menu,Lib,Enable,编辑歌词(&E)
			lrcECHO(LrcPath . "\" . newname . ".lrc", name)
		Return
		}
		else If FileExist(LrcPath_2 "\" newname ".lrc")
		{
			Menu,Lib,Enable,编辑歌词(&E)
			lrcECHO(LrcPath_2 . "\" . newname . ".lrc", name)
		Return
		}
		Else
		{
			newname:=""
			Gui, 2:+LastFound
			GuiControl, 2:, lrc,%name%(歌词欠奉)
			SetTimer, hidenolrc, -6500
			Gui, 2:Show, NoActivate, %name% - AhkPlayer
			Menu,Lib,Disable,编辑歌词(&E)
		Return
		}
	}
Return

hidenolrc:
	Gui, 2:hide
Return

;上一首
^+F3::
prev:
	if (PlayListdefalut="t") && !SingleCycle
	{
		if (PlaylistIndex>1)
		{
			PlaylistIndex:=PlaylistIndex-1
			LV_GetText(Mp3,PlaylistIndex,4)
			LV_Modify(0,"-Select")
			LV_Modify(PlaylistIndex,"+Select +Focus +Vis")
			gosub, Gplay2
		}
	}
	Else
		MCI_Seek(hSound, MCI_Length(hSound))
Return

; 暂停
^+P::
MyPause:
	Status := MCI_Status(hSound)
	; 状态 playing、stopped、stopped
	If(Status = "stopped" OR Status = "Paused")
	{
		If Status = stopped
		{
			MCI_Play(hSound)
			Menu, PlayBack, UnCheck,停止(&S)
			Menu, PlayBack, UnCheck,暂停/播放(&P)
			if(hidelrc=0)
				Gosub, Lrc
			SetTimer,CheckStatus,on
		}
		Else if Status = Paused
		{
			MCI_Resume(hSound)
			if(hidelrc=0)
			{
				lrcPause(0)
				Gui,2:show 
			}
			Menu, PlayBack, ToggleCheck,暂停/播放(&P)
		}
		GuiControl,,pausepic,	%A_ScriptDir%\pic\AhkPlayer\play.bmp
		SetTimer UpdateSlider,on
	}
	Else
	{
		Pausetime:=A_TickCount
		MCI_Pause(hSound)
		if(hidelrc=0)
		{
			lrcPause(1)
			hidelrc=2
			gosub lrcshow
		}
		Menu, PlayBack, ToggleCheck,暂停/播放(&P)
		GuiControl,,pausepic,%A_ScriptDir%\pic\AhkPlayer\pause.bmp
		SetTimer UpdateSlider,off
	}
Return

; 下一首
^+F5::
Next:
	MCI_Seek(hSound, MCI_Length(hSound))
	if (hidelrc=0)
		Gosub, Lrc
Return

; 退出程序
^+E::
Exit:
ExitSub:
	If hSound
	{
		MCI_Stop(hSound)
		MCI_Close(hSound)
	}
	ExitApp
Return

; 播放包含关键字的歌曲
!F9::
;Exit = true
PlayMusic:
	InputBox,userInput,查找,输入要查找的歌曲
	IfEqual,userInput,, Return
	Found = No
	Loop, read, %AhkMediaLibFile%
	{
		mp3 = %A_LoopReadline%
		Loop, Parse, UserInput, %a_Space%
		{
			IfInString, mp3, %A_LoopField%
				SetEnv, Found, Yes
		}
		IfEqual, Found, Yes
		{
			Gosub, Gplay2
			Break
		}
	}
Return

!F3::
Jump:
	InputBox, Seek,跳转,输入要跳转到的时间，歌词不支持跳转`n例子：要跳转到2:20输入220
	IfEqual,Seek,, Return
	StringLen, Length, Seek
	If Length = 4
	{
		StringLeft, MinS, Seek, 2
		StringRight, SecS, Seek, 2
	}
	Else If Length = 3
	{
		StringLeft, MinS, Seek, 1
		StringRight, SecS, Seek, 2
	}
	Else If Length = 2
		StringRight, SecS, Seek, 2
	Else If Length = 1
		StringRight, SecS, Seek, 1

	lrcpos := SecS * 1000
	lrcpos += (MinS * 60) * 1000
	MCI_Seek(hSound, lrcpos)

	IfWinExist, %name% - AhkPlayer
	{
		SetTimer, clock, off
		gosub,LRC
	}
Return

!F5::
	if (newname="")
	{
		IfExist,%LrcPath%\%name%.lrc
			run,%lrceditor% %LrcPath%\%name%.lrc
		IfExist,%LrcPath_2%\%name%.lrc
			run,%lrceditor% %LrcPath_2%\%name%.lrc
	return
	}
	else
	{
		IfExist,%LrcPath%\%newname%.lrc
			run,%lrceditor% %LrcPath%\%newname%.lrc
		IfExist,%LrcPath_2%\%newname%.lrc
			run,%lrceditor% %LrcPath_2%\%newname%.lrc
	return
	}
	CF_ToolTip("歌词文件不存在!",3000)
Return

!F6::
	if caption
	{
		Gui, 2:+LastFound -Caption
		WinSet, ExStyle, +0x20  ; 点击穿透
		caption=0
	}
	Else
	{
		caption=1
		Gui, 2:+Caption	;经测试，的确需要这样写才能够在第一次使用的时候生效
		Gui, 2:+LastFound -Caption
		WinSet, ExStyle, -0x20
		Gui, 2:+Caption
	}
Return

!F8::
LrcShow:
	if (hidelrc=1)
	{
		Gui, Font,cred bold s24,Verdana
		GuiControl,font,LrcS
		hidelrc=0
		;IniWrite, 1, %A_ScriptDir%\tmp\setting.ini, AhkPlayer, ToolMode
		Gui,2:show
	}
	Else if (hidelrc=0)
	{
		Gui, Font, cgreen bold s24,Verdana
		GuiControl,font,LrcS
		hidelrc=1
		Gui,2:Hide
	}
	Else if (hidelrc=2)
	{
		hidelrc=0
		Gui,2:Hide
	}
Return

!F7::
If hide=1
{
	SetTimer,Updatevolume,2000
	Sleep,150
	gui,Show,,%AhkPlayer_Title%
	hide=0
}
Else
{
	IfWinNotActive,%AhkPlayer_Title%
		WinActivate,%AhkPlayer_Title%
	else
	{
		gui,Show,hide,%AhkPlayer_Title%
		SetTimer,Updatevolume,off
		hide=1
	}
}
Return

; 将正在播放的文件加入到播放列表
!F10::
FileRead, NoDoubles, %AhkMediaListFile%
IfNotInString, NoDoubles, %mp3%
	Fileappend, %mp3%`n, %AhkMediaListFile%
else
MsgBox,,添加失败,该文件已在播放列表中!
Return

PgUp::
Gosub, ListReadWrite
Gosub, PlayfromList
Return

PgDn::
Pagedown:
Gosub, ListReadWrite
Gosub, PlayfromList
Return

mute:
Send {Volume_Mute}
Gosub,Updatevolume
;GUIControl Focus,Stop
Return

SetVolume:
VA_SetVolume(VSlider)
Return

; 菜单添加文件到列表
MenuFileAdd:
Gui,Submit, NoHide
FileSelectFile, File, M,, 添加文件, 音频文件 (*.mp3; *.wma; *.wav; *.mid; *.mp4; *.m4a)
if !File
	return
LV_Modify(0, "-Select")
StringSplit, File, File, `n
Loop, % File0-1
{
	xuhao++
	NextIndex := A_Index+1
	w:=File%NextIndex%
	mp3_loop =  %File1%\%w%
	SplitPath, mp3_loop,,,ext, name
	If ext in mp3,wma,wmv,wav,mpg,mid,mp4,m4a			;这是我目前已知的能用soundplay播放的格式
	{
	SetFormat, float ,03
	LV_Add("Focus Select",xuhao+0.0,name,ext, mp3_loop)
	Fileappend,%mp3_loop%`n, %AhkMediaListFile%
	}
}
LV_ModifyCol()
LV_Modify(xuhao,"+Vis")
Return

; 菜单添加文件夹到列表
MenuFolderAdd:
Gui,Submit, NoHide
FileSelectFolder,  Folder,,, 选择音频文件所在文件夹
If !Folder
	return
LV_Modify(0, "-Select")
Loop, %Folder%\*.*,0,1
{
	xuhao++
	SplitPath, A_LoopFileFullPath,,, ext, name
	If ext in mp3,wma,wav,mid,mp4,mpg,m4a
	{
  SetFormat, float ,03
	LV_Add("Focus Select",xuhao+0.0, name,ext, A_LoopFileFullPath)
	Fileappend,%A_LoopFileFullPath%`n, %AhkMediaListFile%
	}
}
LV_ModifyCol()
LV_Modify(xuhao,"+Vis")
return

; 拖拽文件到窗口
GuiDropFiles:
Gui, Submit, NoHide
LV_Modify(0, "-Select")
SetFormat,float ,3.0
Loop, Parse, A_GuiEvent, `n
{
	xuhao++
	SplitPath, A_LoopField,,,ext, name
	If ext in mp3,wma,wmv,wav,mpg,mid,mp4,m4a			;这是我目前已知的能用soundplay播放的格式
	{
	SetFormat, float ,03
	LV_Add("Focus Select",xuhao+0.0, name,ext, A_LoopField)
	Fileappend,%A_LoopField%`n, %AhkMediaListFile%
	}
}
    LV_ModifyCol()
LV_Modify(xuhao,"+Vis")
Return

; 菜单播放所选(单选)
MenuOpen:
	LV_GetText(Mp3, LV_GetNext(Row), 4)
	PlaylistIndex:=LV_GetNext(Row)
	if FileExist(Mp3)
		Gosub, Gplay2
Return

; 菜单/右键 打开所选文件位置(单选)
MenuOpenFilePath:
OpenfilePath:
LV_GetText(mp3_loop, LV_GetNext(Row), 4)
If Fileexist(mp3_loop)
Run,% "explorer.exe /select," mp3_loop
 Return

; 菜单从列表中删除(可多选)
MenuRemove:
FileLineCount :=TF_CountLines(AhkMediaListFile)
LVLineCount :=LV_GetCount()
if(FileLineCount - LVLineCount >2)
{
msgbox,错误！不是播放列表，当前菜单不可用。
return
}
else
{
Loop, % LV_GetCount()			;%
	Row := LV_GetNext(Row), LV_Delete(Row)

FileDelete, %AhkMediaListFile%
	Loop, % LV_GetCount()
	{
	LV_GetText(mp3_loop, A_Index, 4)
	Fileappend,%mp3_loop%`n, %AhkMediaListFile%
    }
gosub,refreshList
}
Return

MenuClear:
MsgBox,4,清空列表,确实要将列表清空吗？移动列表文件到备份Backups文件夹（只保留一个备份）。
IfMsgBox Yes
{
LV_Delete()
FileGetSize, playlistfilesize, %AhkMediaListFile%
if (playlistfilesize <> 0)
FileDelete,%A_ScriptDir%\Backups\playlist.txt

	FileMove, %AhkMediaListFile%,%A_ScriptDir%\Backups,0
if ErrorLevel
MsgBox,,清空列表失败,列表已经为空或文件不可读写
	Fileappend, , %AhkMediaListFile%
}
Return

SelectPlayorder:
Gui, Submit, NoHide
GuiControl, Focus, find
if(SelectedPlayorder="默认")
{
Menu,PlayBack,Check,顺序播放(&D)
Menu,PlayBack,unCheck,随机播放(&R)
Menu,PlayBack,unCheck,单曲循环(&E)
PlayRandom := "f"
SingleCycle := flash
IniWrite,f, %run_iniFile%, AhkPlayer, PlayRandom
return
}
else if(SelectedPlayorder="随机")
{
Menu,PlayBack,Check,随机播放(&R)
Menu,PlayBack,unCheck,顺序播放(&D)
Menu,PlayBack,unCheck,单曲循环(&E)
PlayRandom := "t"
SingleCycle := flash
IniWrite,t, %run_iniFile%, AhkPlayer, PlayRandom
return
}
else if(SelectedPlayorder="单曲循环")
{
SingleCycle:=true
Menu,PlayBack,Check,单曲循环(&E)
}
return

SelectPlayList:
Gui, Submit, NoHide
GuiControl, Focus, find
if(Selectedplaylist="默认列表")
{
gosub PTList
return
}
else if(Selectedplaylist="媒体库")
{
gosub PTLib
return
}
else  ; 历史列表
{
LV_Delete()
file := FileOpen(historyFile, "r", "UTF-16")
history:=""
loop,100
history.=file.ReadLine()
file.Close()
file :=FileOpen(historyFile, "w", "UTF-16")
file.Write(history)
file.Close()
history:=""

xuhao = 0
SetFormat,float ,3.0
Loop, read, %historyFile%
	{
	xuhao++
	mp3_loop = %A_LoopReadline%
	SplitPath, mp3_loop,,,ext, name
	SetFormat, float ,03
    LV_Add("",xuhao+0.0, name, ext,mp3_loop)
    LV_ModifyCol()
}
menu, Context, DeleteAll
Menu, Context, Add, 添加到列表, AddList
}
return

; 播放列表
PTList:
NowPlayFile = %AhkMediaListFile%
FileGetSize, playlistfilesize, %AhkMediaListFile%
if (playlistfilesize = 0)
NowPlayFile := AhkMediaLibFile
Else
{
PlayListdefalut := "t"
AhkPlayer_Title:="播放列表 - AhkPlayer"
IniWrite,t, %run_iniFile%, AhkPlayer, PlayListdefalut
Menu, PlayBack,Check,播放列表(&L)
Menu, PlayBack,UnCheck,播放媒体库(&M)
Menu, PlayBack,Disable,播放列表(&L)
Menu, PlayBack, Enable,播放媒体库(&M)
GuiControl, choose, Selectedplaylist, 1
}
menu, Context, DeleteAll
gosub,refreshList
gosub CreatContext
Gui,Show,,%AhkPlayer_Title%
Return

saveplaylist:
FileSelectFile, file_playlist, S, % A_Desktop,保存当前列表
	Loop, % LV_GetCount()
	{
	LV_GetText(mp3_loop, A_Index, 4)
	Fileappend, %mp3_loop%`n, %file_playlist%
	}
Return

; 播放媒体库
PTLib:
NowPlayFile := AhkMediaLibFile
Menu, PlayBack, Check,播放媒体库(&M)
Menu, PlayBack, Disable,播放媒体库(&M)
Menu, PlayBack, Enable,播放列表(&L)
Menu, PlayBack, UnCheck,播放列表(&L)
GuiControl, choose, Selectedplaylist, 2
PlayListdefalut := "f"
AhkPlayer_Title:="播放媒体库 - AhkPlayer"
IniWrite,f, %run_iniFile%, AhkPlayer, PlayListdefalut
LV_Delete()
mLiblistview()
menu, Context, DeleteAll
Gui,Show,,%AhkPlayer_Title%
Return

PTLF:
IniRead, followmouse, %run_iniFile%, AhkPlayer, followmouse
If (followmouse="t")
{
Menu,PlayBack,unCheck,下一首跟随鼠标(&F)
IniWrite,f, %run_iniFile%, AhkPlayer, followmouse
followmouse:="f"
}
Else
{
Menu,PlayBack,Check,下一首跟随鼠标(&F)
IniWrite,t, %run_iniFile%, AhkPlayer, followmouse
followmouse:="t"
}
Return

; 随机播放
CheckPlayorder:
IniRead, PlayRandom, %run_iniFile%, AhkPlayer, PlayRandom
If (A_ThisMenuItem="顺序播放(&D)")
{
Menu,PlayBack,Check,顺序播放(&D)
Menu,PlayBack,unCheck,随机播放(&R)
Menu,PlayBack,unCheck,单曲循环(&E)
SingleCycle := flash
IniWrite,f, %run_iniFile%, AhkPlayer, PlayRandom
PlayRandom :="f"
GuiControl, choose, SelectedPlayorder,1
}
Else If (A_ThisMenuItem="随机播放(&R)")
{
Menu,PlayBack,Check,随机播放(&R)
Menu,PlayBack,unCheck,顺序播放(&D)
Menu,PlayBack,unCheck,单曲循环(&E)
SingleCycle := flash
IniWrite,t, %run_iniFile%, AhkPlayer, PlayRandom
PlayRandom :="t"
GuiControl, choose, SelectedPlayorder,2
}
else
{
SingleCycle := !SingleCycle
if(SingleCycle=true)
{
Menu,PlayBack,Check,单曲循环(&E)
GuiControl, choose, SelectedPlayorder,3
}
else
{
spo:=(PlayRandom="t")?2:1
GuiControl, choose, SelectedPlayorder,%spo%
Menu,PlayBack,UnCheck,单曲循环(&E)
}
}
Return

OpenLrc:
Run,%LrcPath%
Return

OpenLib:
Run,%AhkMediaLib%
Return

OpenOptionFolder:
Run,%A_ScriptDir%\settings\
Return

EditLrc:
	IfExist,%LrcPath%\%name%.lrc
		run,%lrceditor% %LrcPath%\%name%.lrc
	else
	{
		newname:=StrReplace(name, " - ", "-",,1)
		If FileExist(LrcPath "\" newname ".lrc")
			run,%lrceditor% %LrcPath%\%newname%.lrc
	}
	IfExist,%LrcPath_2%\%name%.lrc
		run,%lrceditor% %LrcPath_2%\%name%.lrc
	else
	{
		newname:=StrReplace(name, " - ", "-",,1)
		If FileExist(LrcPath "\" newname ".lrc")
			run,%lrceditor% %LrcPath_2%\%newname%.lrc
	}
Return

EditOption:
Run,%run_iniFile%
Return

About:
Gui,3:Default
Gui,Add,Text, ,名称：AhkPlayer`n作者：桂林小廖
Gui,Add,Text,y+10,主页：
Gui,Add,Text,y+10  cBlue gLink_1,https://github.com/wyagd001/MyScript
Gui,Add,Text,y+10,致谢：
Gui,Add,Text,y+10  cBlue gLink_2,Sound.ahk - fincs
Gui,Add,Text,y+10  cBlue gLink_3,MCI Library - jballi
Gui,Add,Text,y+10  cBlue gLink_4,QuickSound - Stefan V
Gui,Add,Text,y+10  cBlue gLink_5,NighPlayer - NiGH(dracula004)
Gui,show,,关于
Return

Link_1:
Run,https://github.com/wyagd001/MyScript
Return

Link_2:
Run,http://www.autohotkey.com/forum/topic20666.html
Return

Link_3:
Run,http://www.autohotkey.com/forum/topic35266.html
Return

Link_4:
Run,http://www.autohotkey.com/forum/topic53076.html
Return

Link_5:
Run,http://www.ahkcn.net/thread-2570.html
Return

; 查找歌曲
find:
Libxuhao=0
LV_Delete()
Gui, Submit, NoHide
Loop, read, %AhkMediaLibFile%
		{
			Libxuhao++
			SetFormat, float ,04
			mp3_loop = %A_LoopReadline%
			Found = Yes
			Loop, Parse, find, %a_Space%
			IfNotInString, mp3_loop, %A_LoopField%, SetEnv, Found, No

			IfEqual, Found, Yes
				{
			    SplitPath, mp3_loop,,,ext, name
				LV_Add("Focus",Libxuhao+0.0, name,ext, mp3_loop)
				}
}
LV_ModifyCol()
Return

; 刷新列表
refreshList:
LV_Delete()
xuhao = 0
SetFormat,float ,3.0
Loop, read, %NowPlayFile%
	{
	xuhao++
	mp3_loop = %A_LoopReadline%
	SplitPath, mp3_loop,,,ext, name
	SetFormat, float ,03
    LV_Add("",xuhao+0.0, name, ext,mp3_loop)
}
LV_ModifyCol()
Return

; 查找结果追加到列表
FindToList:
;Findsave:
;FileDelete, %AhkMediaListFile%
;	Fileappend, , %AhkMediaListFile%
;	Loop, % LV_GetCount()
;	{
;	LV_GetText(Mp3, A_Index, 4)
;	Fileappend,%Mp3%`n, %AhkMediaListFile%
;}

FileRead, NoDoubles, %AhkMediaListFile%

	Loop, % LV_GetCount()
	{
	LV_GetText(mp3_loop, A_Index, 4)
    IfNotInString, NoDoubles, %mp3_loop%
	Fileappend, %mp3_loop%`n, %AhkMediaListFile%
	}
Return

; 右键清空列表或从列表中删除
Remove:
If (A_ThisMenuItem = "清空列表")
   {
MsgBox,4,清空列表,确实要将列表清空吗？移动列表文件到备份Backups文件夹（只保留一个备份）。
IfMsgBox Yes
{
	LV_Delete()
FileGetSize, playlistfilesize, %AhkMediaListFile%
if (playlistfilesize <> 0)
FileDelete,%A_ScriptDir%\Backups\playlist.txt
	FileMove, %AhkMediaListFile%,%A_ScriptDir%\Backups,0
if ErrorLevel
MsgBox,,清空列表失败,列表已经为空或文件不可读写
	Fileappend, , %AhkMediaListFile%
	}
}
else If (A_ThisMenuItem = "从列表中删除(可多选)")
{
FileLineCount :=TF_CountLines(AhkMediaListFile)
LVLineCount :=LV_GetCount()
if(FileLineCount - LVLineCount >2)
{
msgbox,错误！不是播放列表，当前菜单不可用。
return
}
else
{
	Loop, % LV_GetCount()			;%
	Row := LV_GetNext(Row), LV_Delete(Row)

	FileDelete, %AhkMediaListFile%
	Loop, % LV_GetCount()
	{
	LV_GetText(mp3_loop, A_Index, 4)
	Fileappend,%mp3_loop%`n, %AhkMediaListFile%
	}
gosub,refreshlist
}
}
Return

; 右键移除重复与无效项
RemoveDuplicateInvalid:
TF_RemoveDuplicateLines(AhkMediaListFile, "", "", 0,false)
sleep,200
FileMove,%A_ScriptDir%\settings\AhkPlayer\playlist_copy.txt,%AhkMediaListFile%,1
sleep,200
newText=
Loop, Read,%AhkMediaListFile%
{
IfExist,%A_LoopReadLine%
newText .= A_LoopReadLine "`n"
}
FileDelete,%AhkMediaListFile%
sleep,200
fileappend,%newText%,%AhkMediaListFile%
sleep,200
gosub,refreshList
Return

; 右键将选中行添加到播放列表
AddList:
RowNumber = 0
FileRead, NoDoubles, %AhkMediaListFile%
Loop, % LV_GetCount()
{
RowNumber := LV_GetNext(RowNumber)
 if not RowNumber
 break
LV_GetText(mp3_loop,RowNumber, 4)
IfNotInString, NoDoubles, %mp3_loop%
	Fileappend, %mp3_loop%`n, %AhkMediaListFile%
else
Repeat .= mp3_loop . "`n"
}
if Repeat
MsgBox,,添加失败, 以下文件已在列表中!`n%Repeat%

Repeat =
Return

ListView:
if (A_GuiEvent = "RightClick")
	Menu, Context , Show
else if (A_GuiEvent = "DoubleClick")
gosub,PlayLV
return

; 右键播放所选歌曲
PlayLV:
	LV_GetText(mp3, LV_GetNext(), 4)
	PlaylistIndex:= LV_GetNext()
	Gosub, Gplay2
return

TTPlayerOpen:
LV_GetText(mp3, LV_GetNext(), 4)
run,%TTPlayer% " %mp3%"
return

Slider:
;Gui,Submit,NoHide
SetTimer,CheckStatus,off
if (A_GuiEvent = 2) or (A_GuiEvent = 3)
{
pass_GuiEvent := 0
return
}
else if (A_GuiEvent = 0) or (A_GuiEvent = 1) or (A_GuiEvent = 5)
{
    pass_GuiEvent := (A_GuiEvent = 5)?0:1
		MCI_ToHHMMSS2(Len*(Slider/100),thh,tmm,tss)
		if (lhh=0)
			CF_ToolTip(tmm ":" tss, 2000)
		else
			CF_ToolTip(thh ":" tmm ":" tss, 2000)
}
else if (A_GuiEvent = "Normal")
{
  if !pass_GuiEvent
{
  MouseGetPos, Slider_x
  Slider := (Slider_x-20)*100/580
  GUIControl,,Slider,% Slider
}
		MCI_ToHHMMSS2(Len*(Slider/100),thh,tmm,tss)
		if (lhh=0)
			CF_ToolTip(tmm ":" tss, 2000)
		else
			CF_ToolTip(thh ":" tmm ":" tss, 2000)


		if hSound
		{
			Status:=MCI_Status(hSound)
			if Status in Playing,Paused
			{
					MCI_Play(hSound,"from " . floor(Len*(Slider/100)),"NotifyEndOfPlay")

					IfWinExist, %name% - AhkPlayer
					{
						SetTimer, clock, off
						lrcpos := %	floor(Len*(Slider/100))
						gosub,LRC
					}

            ;-- MCI_Seek is not used to reposition the media in this example
            ;   because the function will cause a Notify interruption for most
            ;   devices.
            ;
            ;   Using the "From" flag, MCI_Play will successfully reposition
            ;   the media for most MCI devices.  Calling MCI_Play (with
            ;   callback) while media is playing will abort the original Notify
            ;   condition (if any) and will create a new Notify condition.

				if Status=Paused
					MCI_Pause(hSound)
			}
    ;-- Reset focus
      if !pass_GuiEvent
			GUIControl Focus,Stop
		}
}
	SetTimer,CheckStatus,on
Return

UpdateSlider:
if hSound
    {
    ;-- Only update slider if object is NOT in focus
    GUIControlGet Control,FocusV
    if Control<>Slider
        GUIControl,,Slider,% (MCI_Position(hSound)/Len)*100
    }
return

CheckStatus:
	Status := MCI_Status(hSound)
	If Status = stopped
	{
		if (PlayRandom="t")
			temp_sb1:="停止播放(随机) " SName 
		else if (PlayRandom="f")
			temp_sb1:="停止播放(顺序) " SName 
		if SingleCycle
			temp_sb1:="停止播放(单曲循环) " SName
		if (lhh=0)
			SongTime = 0:00 / %lm%:%ls%
		else
			SongTime = 0:0:00 / %lhh%:%lm%:%ls%
		opos:=0
	}
	else If Status = Paused
	{
		if (PlayRandom="t")
			temp_sb1:="暂停播放(随机) " SName 
		else if (PlayRandom="f")
			temp_sb1:="暂停播放(顺序) " SName 
		if SingleCycle
			temp_sb1:="暂停播放(单曲循环) " SName
		if (lhh=0)
			SongTime = %mm%:%ss% / %lm%:%ls%
		else
			SongTime = %hh%:%mm%:%ss% / %lhh%:%lm%:%ls%
		opos := (pos/Len)*100
		opos_color:=red
		opos_color_win7:=0x0003
	}
	else If Status = playing
	{
		if (PlayRandom="t")
			temp_sb1:="正在播放(随机) " SName 
		else if (PlayRandom="f")
			temp_sb1:="正在播放(顺序) " SName 
		if SingleCycle
			temp_sb1:="正在播放(单曲循环) " SName
		if (lhh=0)
			SongTime = %mm%:%ss% / %lm%:%ls%
		else
			SongTime = %hh%:%mm%:%ss% / %lhh%:%lm%:%ls%
		opos := (pos/Len)*100
		opos_color:=87cefe
		opos_color_win7:=0x0001
	}
		if (temp_sb1!=last_temp_sb1)
		{
			SB_SetText(temp_sb1,1)
			last_temp_sb1:=temp_sb1
		}
		if (SongTime!=last_SongTime)
		{
			SB_SetText(SongTime,2)
			last_SongTime:=SongTime
		}
		if (opos!=last_opos)
		{
			SB_SetProgress(opos ,3)
			last_opos:=opos
		}
		if (opos_color!=last_opos_color)
		{
			SB_SetProgress(opos ,3,"c"opos_color)
			last_opos_color:=opos_color
		}
		if (opos_color_win7!=last_opos_color_win7)
		{
			SendMessage, 0x0410, opos_color_win7,, msctls_progress321,%AhkPlayer_Title%
			last_opos_color_win7:=opos_color_win7
		}
Return

Updatevolume:
volume := VA_GetVolume()
Guicontrol,,VSlider,%volume%

master_mute:=VA_GetMute()
if master_mute
volimage = %A_ScriptDir%\pic\m_vol.ico
else
volimage = %A_ScriptDir%\pic\vol.ico

   If (volimage != Oldvolimage)
   {
      GuiControl, , vol, %volimage%
      Oldvolimage := volimage
   }
Return

GuiEscape:
GuiClose:
SetTimer,Updatevolume,off
gui,Hide
hide=1
Return

3GuiEscape:
3GuiClose:
gui,3:Destroy
Return

#IfWinExist  - AhkPlayer ahk_class AutoHotkeyGUI
NumpadMult::gosub MyPause
NumpadAdd::gosub next
NumpadDiv::gosub exit
NumpadSub::gosub !F7
#IfWinExist

#include %A_ScriptDir%\Lib\VA.ahk
#include %A_ScriptDir%\Lib\MCI.ahk
#include %A_ScriptDir%\Lib\LRC.ahk
#include %A_ScriptDir%\Lib\SB.ahk
#include %A_ScriptDir%\Lib\Mlib.ahk
#include %A_ScriptDir%\Lib\Class_SQLiteDB.ahk