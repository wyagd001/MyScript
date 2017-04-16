/*
作者：ChalamiuS
网址：http://www.autohotkey.com/forum/topic31467.html
*/

#SingleInstance Force ;Directives
#Persistent
#NoEnv

CoordMode,Mouse,Screen ;Common settings
FadeStatus = 0
S = %A_ScreenWidth%
ScriptVersion = 1.1.0.0
SetBatchLines -1
SetTimer,GetMouse,15
SetWinDelay,-1

Alpha = 210 ;Random Vars
GuiA := S//4
GuiB := S//2+GuiA
Ini = %A_ScriptDir%\Dock快速启动.Ini
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

Menu,Tray,Icon,%A_ScriptDir%\box.ico
Menu,tray,Tip,[BasicDock]
Menu,tray,NoStandard ;Menus
Menu,tray,Add,[BasicDock %ScriptVersion%],Credits
Menu,tray,Add,
Menu,tray,Add,Add Application,AddApp
Menu,tray,Add,Clear settings files,Clear
Menu,tray,Add
Menu,tray,Add,Autohotkey.com,AHKC
Menu,tray,Add
Menu,tray,Add,Exit,Exit

;Configs
ConfigRead:
IniRead,Count,%Ini%,General,Count,0
Gui,1: +LastFound +ToolWindow -Caption

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
Gui,1: Show,xCenter y0 w%WinWidth% h48,%WinTitle%
Wi := "ahk_id" . WinExist()
GuiTime := A_TickCount
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
FileDelete,%Ini%
Gui,1: Destroy
Goto ConfigRead
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
else if (InStr(C,"Static1")) {
  Menu,GCM1,Show
}
else if (InStr(C,"Static" . Count)) {
  Menu,GCM3,Show
}

FillIco:
Gui,2: Submit,NoHide
GuiControl,2:,Icon,%Path%
Return

GetMouse:
ifWinActive, Warcraft III
return
MouseGetPos,X,Y,W,C
If (X != sX) or (Y != sY)
{
If (Y < 48)
{
	If X between %GuiA% and %GuiB%
	{
		GuiTime := A_TickCount
		If Y < 5
		{
			WinSet,AlwaysOnTop,On,%WinTitle%
			If FadeStatus = 1
				FadeStatus := Slide(Wi,"In") + Fade(Wi,80,Alpha) "0"
		}
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
If (FadeStatus = 0 and A_TickCount-GuiTime > 3000)
{
	FadeStatus := Fade(Wi,Alpha,80,5) + Slide(Wi,"Out") "1"
	WinSet,AlwaysOnTop,Off,%Win%
	WinSet,Bottom,, %Win%
}
Return

StartApp:
Run,% App_%LS%_1
Return

;Functions
Fade(Window, FromAlpha=255, ToAlpha=0, Sleep=5)
{
	Loop, % (FromAlpha > ToAlpha) ? (FromAlpha-ToAlpha)//5	: (ToAlpha-FromAlpha)//5 ;%
	{
		FromAlpha := (FromAlpha > ToAlpha) ? FromAlpha-5 : FromAlpha+5
		WinSet, Transparent, %FromAlpha%, %Window%
		Sleep %Sleep%
	}
}
Slide(Win, Dir, Rate=4, Sleep=5) ;Thanks Infogulch for the idea behind this.
{
	Loop % 48//Rate		;%
	{
		WinMove, %Win%,,, % (Dir = "In") ? A_Index*Rate - 48 : (-A_Index)*Rate		;%
		Sleep, %Sleep%
	}
	WinMove, %Win%,,, % (Dir = "In") ? 0 : Pos			;%
}

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

AhkC:
Run,http://www.autohotkey.com/
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
