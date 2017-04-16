/*
脚本已被修改
作者：ChalamiuS
网址：http://www.autohotkey.com/forum/topic31467.html
缺点：按下显示桌面后，图标可能缺失
*/
#SingleInstance Force ;Directives
#Persistent
#NoEnv
SetWinDelay, -1
Menu,Tray,Icon,%A_ScriptDir%\box.ico

CoordMode,Mouse,Screen
S = %A_ScreenWidth%
ScriptVersion = 1.1.0.0
;SetBatchLines -1
Sh=1

SetTimer,GetMouse,100

GuiA := S//4
GuiB := S//2+GuiA
Ini = %A_ScriptDir%\桌面快速启动.Ini
WinTitle = BasicDock
WinWidth := S//2
MaxIcos := WinWidth/35

Menu,GCM1,Add,Move Right,MRight
Menu,GCM1,Add,Delete,Remove
Menu,GCM2,Add,Move Left,MLeft
Menu,GCM2,Add,Move Right,MRight
Menu,GCM2,Add,Delete,Remove
Menu,GCM3,Add,Move Left,MLeft
Menu,GCM3,Add,Delete,Remove



Menu,tray,Add,[BasicDock %ScriptVersion%],Credits
Menu,tray,Add,
Menu,tray,Add,添加程序,AddApp
Menu,tray,Add,重置设置,Clear
Menu,tray,Add,重载脚本,re
Menu,tray,Add,显示,sh
Menu,tray,Add,
Menu,tray,Add,退出,Exit
Menu, Tray, NoStandard
Menu, Tray, Default,显示
Menu, Tray, Click, 1

;Configs
ConfigRead:
IniRead,Count,%Ini%,General,Count,0

If Count = 0
	Goto AddApp
Loop %Count%
{
	IniRead,Cur_App,%Ini%,Apps,App%A_Index%,ERROR
	StringSplit,App_%A_Index%_,Cur_App,|," ;"
	Icon := App_%A_Index%_2
	IconNum := App_%A_Index%_3
	Gui,1: Add,Pic,% "y7 w32 h32 gStartApp Icon%IconNum% xp+" ((A_Index = 1) ? 0 : 35)  ,%Icon%
}
Gui,1:+ToolWindow
Gui,1: Show,xCenter  y-28 w%WinWidth% h48,%WinTitle%
WinGet, WinID, ,BasicDock
WinSet,Region,4-27 W%WinWidth% H48 R10-10, ahk_id %WinID%
WinGet, DesktopID, ID, ahk_class WorkerW
;MsgBox %WinID% - %DesktopID%
if !DesktopID
    WinGet, DesktopID, ID, Program Manager
;ControlGet,id1,hwnd,,SHELLDLL_DefView1,ahk_class Progman
;ControlGet,DesktopID,hwnd,,SysListView321,ahk_id %id1%
DllCall("SetParent", "UInt", WinID, "UInt", DesktopID)
;msgbox % qq "-" DesktopID "-" WinID
;WinGet, DesktopID, ID, Program Manager
;MsgBox %WinID% - %DesktopID%
Return

GetMouse:
MouseGetPos,X,Y,W,C
If (X != sX) or (Y != sY)
{
If (Y < 48)
{
	If X between %GuiA% and %GuiB%
	{
		GuiTime := A_TickCount
	IfInString,C,Static
	{
		StringTrimLeft,C2,C,6
		ToolTip,% App_%C2%_4
		LS = %C2%
		sX = % X
		sY = % Y
	}
	else
		ToolTip,
	}
	else
		ToolTip,
}
else
	ToolTip,
}
else
  Return

Process, Exist, explorer.exe
If ErrorLevel = 0
{
	SetTimer,GetMouse,Off
	MsgBox,4,恢复桌面,桌面崩溃了，是否重启桌面？
	IfMsgBox Yes
              Run,explorer.exe
	Sleep,5000
	Reload
}
Return

;Add Application label
AddApp:
Gui,2: Destroy
Gui,2: Add,Text,,Insert the path to the application you want to link to in the box below
Gui,2: Add,Edit,vPath w200 gFillIco,
Gui,2: Add,Text,,Icon Path
Gui,2: Add,Edit,vIcon w200,
Gui,2: Add,Text,,Icon number
Gui,2: Add,Edit,vIconNum Number w200,
Gui,2: Add,Text,,Name
Gui,2: Add,Edit,vName w200,
Gui,2: Add,Text,,Parameters
Gui,2: Add,Edit,vParameters +ReadOnly w200,Not Implented yet
Gui,2: Add,Button,gEnterApps,Go!
Gui,2: Show
Return

;Clear Application Label
Clear:
MsgBox,257,警告,是否要删除配置文件，重置脚本？
IfMsgBox Cancel
 Return
else
{
FileDelete,%Ini%
Gui,1: Destroy
Goto ConfigRead
}
Return

GuiDropFiles:
Drop = 1
SplitPath, A_GuiEvent , FN, OD, ext, Name
If (ext = "lnk") {
	FileGetShortcut, %A_GuiEvent% ,Targ, OD,,,OI,OIN,
	Path := Targ
	Icon := ((!OI) ? Path : OI)
	IconNum := ((!OIN) ? 1 : OIN)
}
else {
Path := OD "\" FN
Icon := Path
IconNum = 1
}

EnterApps:
If Drop != 1
	Gui,2: Submit
Count++
If (Count < MaxIcos) {
  TW = %Path%|%Icon%|%IconNum%|%Name%
  IniWrite,%TW%,%Ini%,Apps,App%Count%
  IniWrite,%Count%,%Ini%,General,Count
  Gui,1: Destroy
  Drop = 0
  Goto ConfigRead
}
else
  MsgBox,% "You reached the max number of Icons allowed with your screen size: " MaxIcos
Return

GuiContextMenu:
If (InStr(C,"Static") && (LS > 1) && !InStr(C,"Static" . Count)) {
  Menu,GCM2,Show
}
else if (InStr(C,"Static" . Count)) {
  Menu,GCM3,Show
}
else if (InStr(C,"Static1")) {
  Menu,GCM1,Show
}
Return

FillIco:
Gui,2: Submit,NoHide
GuiControl,2:,Icon,%Path%
Return

StartApp:
Run,% App_%LS%_1
Return

MLeft:
Switch("Left")
Gui,1: Destroy
Goto ConfigRead
Return


MRight:
Switch("Right")
Gui,1: Destroy
Goto ConfigRead
Return

Remove:
IniDelete,%Ini%,Apps,% "App" LS
FileRead,Var,%Ini%
Pos := LS+1
Loop {
	if (Pos > Count)
		break
	StringReplace,Var,Var,% "App" Pos,% "App" Pos - 1
	Pos++
}

FileDelete,%Ini%
FileAppend,%Var%,%ini%
Count--
IniWrite,%Count%,%Ini%,General,Count
Gui,1: Destroy
Goto ConfigRead
Return

Credits:
MsgBox,0,Credits,Made by ChalamiuS,10
Return

Exit:
ExitApp

sh:
If(sh=1){
sh=0
Gui,1: Hide
}
else{
sh=1
Gui,1:Show
}
Return

re:
Reload
Return

Switch(Dir = "Right") {
	global ini,ls
	IniRead,Var1,%Ini%,Apps,App%LS%
	IniRead,Var2,%Ini%,Apps,% "App" ((Dir = "Right") ? LS+1 : LS-1)
	FileRead,Var,%ini%
	StringReplace,Var13,Var,% "App" ((Dir = "Right") ? LS+1 : LS-1) "=" Var2,% "App" ((Dir = "Right") ? LS+1 : LS-1) "=" Var1
	StringReplace,Var13,Var13,% "App" LS "=" Var1,% "App" LS "=" Var2
	FileDelete,%Ini%
	FileAppend,%Var13%,%Ini%
}

