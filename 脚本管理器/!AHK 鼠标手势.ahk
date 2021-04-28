/*
原脚本已被修改
作者： 游否
网址： http://ahk.5d6d.com/thread-1236-1-1.html
*/

#SingleInstance force
SetWorkingDir %A_ScriptDir%
IfNotExist MGConfig.ini
Newini=`n`n注意:`n新的默认配置文件`nMGConfig.ini 已生成!`n`n使用手势 → ← → `n可以查看说明
FileInstall MGConfigDefault.ini,MGConfig.ini
#WinActivateForce
TrayTip AHK鼠标手势,欢迎使用AHK鼠标手势!!%Newini%,,1
SetTitleMatchMode 2
GroupAdd,ddd,- Microsoft Internet Explorer
GroupAdd,ddd,Mozilla Firefox
GroupAdd,ddd,ahk_class Afx:400000:3:10011:1900010:0
#IfWinNotActive, ahk_group ddd
loop
{
	IniRead ActName%A_Index%,MGConfig.ini,ActNames,%A_Index%
	IniRead act%A_Index%,MGConfig.ini,MouseGestures,%A_index%
	If (act%A_Index%="ERROR")
	{
		n:=A_Index-1
		Break
	}
}
Loop %n%
{
	LoopName:=ActName%A_Index%
	LoopAct:=act%A_Index%

	StringReplace LoopAct,LoopAct,R,→,A
	StringReplace LoopAct,LoopAct,L,←,A
	StringReplace LoopAct,LoopAct,U,↑,A
	StringReplace LoopAct,LoopAct,D,↓,A

	instructions=%instructions%%A_Index%.%A_Tab%%LoopAct%%A_Tab%%LoopName%`n`n
}
instructions=`n%instructions%`n`n注意:`n`n其中第1,2点针对的窗口`n(包括控件)都是鼠标手势起始点下的窗口,`n而不是 当前激活的窗口,动作被触发后也`n不会激活目标窗口!`n`n`n游否`nzhangz.music@qq.com

Menu, Tray, Icon,shell32.dll,15
;Menu,tray,NoStandard
Menu,tray,add,查看说明,instructions
Menu,tray,add,打开配置文件 (定制手势),runini
Menu,tray,add,重设所有配置!,Reset
Menu,tray,add
Menu,tray,add,退出,GuiClose
Return

RButton::
MouseGetPos TX,TY,UMWID,UMC

Loop
{
	MouseGetPos TXX,TYY
	TR:=GetKeyState("RButton","P")
	XX:=TXX-TX
	YY:=TYY-TY
	DS:=Sqrt(XX*XX+YY*YY)
	If ((TR=0) And (DS<=20))
	{
		SendPlay {RButton}
		Break
	}
	If ((DS>20) And (TR=1))
	{
		Gosub Do
		Break
	}
}
If (GestureList=act1)
WinClose ahk_id%UMWID%
If (GestureList=act2)
WinMinimize ahk_id%UMWID%
If (GestureList=act3)
{
	SendEvent {LWin}
	WinWaitActive 「开始」菜单,,0.5
	;ControlClick Button1,「开始」菜单
}
If (GestureList=act4)
SendEvent {F5}
If (GestureList=act5)
TrayTip 鼠标手势说明,%instructions%,100
If (GestureList=act6)
{
WinGetClass, ActiveClass, A
If ActiveClass in ExploreWClass,IEFrame,CabinetWClass
{
    WinGetTitle, Title, A
    Send, {Backspace}
}
}
If (GestureList=act7)
sendinput, {Browser_Back}
If (GestureList=act8)
sendinput, {Browser_Forward}
GestureList=
;~ GroupAdd a
Return

instructions:
MsgBox,,鼠标手势说明,%instructions%
Return

RunIni:
Run MGConfig.ini
Return

Reset:
MsgBox 262180,AHK 鼠标手势,确定要重设所有配置吗?
IfMsgBox Yes
{
	FileDelete MGConfig.ini
	If (Errorlevel = 0)
	{
		MsgBox 64,AHK 鼠标手势,执行成功`n`n程序即将重新启动!,10
		Reload
	}
	Else
	MsgBox 16,AHK 鼠标手势,执行失败`,或配置文件已不存在`n`n请重新启动本程序!
}
Return

GuiClose:
ExitApp
Return

Do:
Loop %Count%
Gesture%A_Index%=
GestureList=

Count:=1
lx:=TX
ly:=TY
Loop
{
	Count2:=Count-1
	lastGesture:=Gesture%lastcount%
	TR:=GetKeyState("RButton","P")
	If TR=0
	Break
	Sleep 20
	MouseGetPos nx,ny
	xx:=nx-lx
	yy:=ny-ly
	DS:=Sqrt(XX*XX+YY*YY)
	If (ds<15)
	Continue
	identify()
	lx:=nx
	ly:=ny
	lastcount:=count-1
	If (Gesture%count%=Gesture%lastcount%)
	{
		Gesture%count%=
		Continue
	}
	If Gesture%count%=
	Continue
	index:=Gesture%Count%
	GestureList=%GestureList%%index%
	StringReplace rsuser,GestureList,R,→%A_Space%,A
	StringReplace rsuser,rsuser,L,←%A_Space%,A
	StringReplace rsuser,rsuser,U,↑%A_Space%,A
	StringReplace rsuser,rsuser,D,↓%A_Space%,A
	Loop %n%
	{
		If (GestureList=Act%A_Index%)
		{
			act:=ActName%A_Index%
			Break
		}
	}
	If (count > 3)
	noact=手势已取消
	TrayTip ,AHK 鼠标手势%A_Tab%%noact%,%rsuser%%A_Tab%%act%
	act=
	noact=
	count++
}
TrayTip

Return

identify()
{
	global
	If ((XX>0) And (XX>Abs(YY)*2))
	Gesture%Count%:="R"
	If ((XX<0) And (Abs(XX)>Abs(YY)*2))
	Gesture%Count%:="L"
	If ((YY>0) And (YY>Abs(XX)*2))
	Gesture%Count%:="D"
	If ((YY<0) And (Abs(YY)>Abs(XX)*2))
	Gesture%Count%:="U"
}