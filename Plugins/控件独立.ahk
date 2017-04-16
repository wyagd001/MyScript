;DetachVideo.ahk
; Detach embedded videos from your tabbed browser
; and show them in a window of their own.
; Usage: Place your mouse over a video and press F12.
;Skrommel @ 2008


#SingleInstance,Force
DetectHiddenWindows,On
SetWinDelay,0
run_iniFile = %A_ScriptDir%\..\settings\setting.ini

applicationname=DetachVideo
counter=0
OnExit,EXIT
Gosub,INIREAD
Gosub,MENU
sleep,3000
Gosub,HOTKEY
SetTimer,MOVE,500
Return


HOTKEY:
sleep,1000
SetTimer,MOVE,Off
MouseGetPos,,,window,ctrl,2
WinGetPos,wx,wy,ww,wh,ahk_id %window%
WinGetPos,cx,cy,cw,ch,ahk_id %ctrl%
current:=counter
Loop,% counter+1
{
  If gui_%A_Index%=
  {
    current:=A_Index
    Break
  }
}
If current>%counter%
  counter+=1
Gui,%current%:+AlwaysOnTop +Resize +ToolWindow +LabelAllGui
Gui,%current%:Show,X0 Y0 W%cw% H%ch%,%applicationname% - www.1HourSoftware.com
Gui,%current%:+LastFound
gui:=WinExist("A")
parent:=DllCall("SetParent","UInt",ctrl,"UInt",gui)
WinMove,ahk_id %ctrl%,,0,0 ;,%cw%,%ch%
ctrl_%current%:=ctrl
gui_%current%:=gui
parent_%current%:=parent
window_%current%:=window
w_%current%:=ww
h_%current%:=wh
SetTimer,MOVE,500
Return


MOVE:
SetTimer,MOVE,Off
Loop,%counter%
{
  ctrl:=ctrl_%A_Index%
  If ctrl=
    Continue
  IfWinExist,ahk_id %ctrl%
    WinMove,ahk_id %ctrl%,,0,0
  Else
    Gui,%A_Index%:Destroy
}
SetTimer,MOVE,500
Return


AllGuiClose:
SetTimer,MOVE,Off
ctrl:=ctrl_%A_Gui%
window:=window_%A_Gui%
DllCall("SetParent","UInt",ctrl_%A_Gui%,"UInt",parent_%A_Gui%)
Gui,%A_Gui%:Destroy
WinMove,ahk_id %ctrl%,,0,0
WinMove,ahk_id %window%,,,,% w_%A_Gui%,% h_%A_Gui%+1
WinMove,ahk_id %window%,,,,% w_%A_Gui%,% h_%A_Gui%
gui_%A_Gui%=
ctrl_%A_Gui%=
parent_%A_Gui%=
gosub,exit
Return


SETTINGS:
Hotkey,%hotkey%,Off
Gui,99:Destroy
Gui,99:Add,GroupBox,w175 h80,&Hotkey
Gui,99:Add,Hotkey,xp+10 yp+20 w155 vvhotkey,%hotkey%
Gui,99:Add,Button,w75 Default GSETTINGSOK,&OK
Gui,99:Add,Button,x+5 yp w75 GSETTINGSCANCEL,&Cancel
Gui,99:Show,,%applicationname% Settings
Return

SETTINGSOK:
Gui,99:Submit
If vhotkey<>
  hotkey:=vhotkey
Hotkey,%hotkey%,HOTKEY
Gosub,INIWRITE
Return

99GuiClose:
SETTINGSCANCEL:
Hotkey,%hotkey%,HOTKEY
Gui,99:Destroy
Return


MENU:
Menu,Tray,DeleteAll
Menu,Tray,NoStandard
Menu,Tray,Add,%applicationname%,ABOUT
Menu,Tray,Add,
Menu,Tray,Add,&Settings...,SETTINGS
Menu,Tray,Add,&About...,ABOUT
Menu,Tray,Add,E&xit,EXIT
Menu,Tray,Tip,%applicationname%
Menu,Tray,Default,%applicationname%
Return


ABOUT:
Gui,99:Destroy
Gui,99:Margin,20,20
Gui,99:Add,Picture,xm Icon1,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,%applicationname% v1.0
Gui,99:Font
Gui,99:Add,Text,y+10,Detach embedded videos from your tabbed browser
Gui,99:Add,Text,xp y+5,and show them in a window of their own.
Gui,99:Add,Text,y+10,Usage: Place your mouse over a video and press F12.

Gui,99:Add,Picture,xm y+20 Icon2,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,1 Hour Software by Skrommel
Gui,99:Font
Gui,99:Add,Text,y+10,For more tools, information and donations, please visit
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 G1HOURSOFTWARE,www.1HourSoftware.com
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon7,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,DonationCoder
Gui,99:Font
Gui,99:Add,Text,y+10,Please support the contributors at
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GDONATIONCODER,www.DonationCoder.com
Gui,99:Font

Gui,99:Add,Picture,xm y+20 Icon6,%applicationname%.exe
Gui,99:Font,Bold
Gui,99:Add,Text,x+10 yp+10,AutoHotkey
Gui,99:Font
Gui,99:Add,Text,y+10,This tool was made using the powerful
Gui,99:Font,CBlue Underline
Gui,99:Add,Text,y+5 GAUTOHOTKEY,www.AutoHotkey.com
Gui,99:Font

Gui,99:Show,,%applicationname% About
hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
OnMessage(0x200,"WM_MOUSEMOVE")
Return

1HOURSOFTWARE:
  Run,http://www.1hoursoftware.com,,UseErrorLevel
Return

DONATIONCODER:
  Run,http://www.donationcoder.com,,UseErrorLevel
Return

AUTOHOTKEY:
  Run,http://www.autohotkey.com,,UseErrorLevel
Return

ABOUTOK:
  Gui,99:Destroy
  OnMessage(0x200,"")
  DllCall("DestroyCursor","Uint",hCur)
Return

WM_MOUSEMOVE(wParam,lParam)
{
  Global hCurs
  MouseGetPos,,,,ctrl
  If ctrl in Static9,Static13,Static17
    DllCall("SetCursor","UInt",hCurs)
  Return
}
Return


EXIT:
SetTimer,MOVE,Off
Loop,%counter%
{
  ctrl:=ctrl_%A_Index%
  window:=window_%A_Index%
  If ctrl=
    Continue
  DllCall("SetParent","UInt",ctrl_%A_Index%,"UInt",parent_%A_Index%)
  Gui,%A_Index%:Destroy
  WinMove,ahk_id %ctrl%,,0,0
  WinMove,ahk_id %window%,,,,% w_%A_Index%,% h_%A_Index%+1
  WinMove,ahk_id %window%,,,,% w_%A_Index%,% h_%A_Index%
}
ExitApp


INIREAD:
IniRead,hotkey,%run_iniFile%,快捷键_控件独立,Hotkey
If hotkey=Error
  hotkey=!F12
Hotkey,%hotkey%,HOTKEY
Return


INIWRITE:
IniWrite,%hotkey%,%run_iniFile%,快捷键_控件独立,Hotkey
Return