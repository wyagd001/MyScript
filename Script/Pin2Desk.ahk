;#include %A_ScriptDir%\Lib\StrArray.ahk
;+MButton::
Pin2Desk:
	WinGetClass,WinClass,A
;msgbox % WinClass
	If WinClass In Progman,Manager,Shell_TrayWnd,WorkerW
		Return
 if !WinClass
  Return
 	WinGet,vWinID,ID,ahk_class Shell_TrayWnd
	MouseGetPos,MouseX,MouseY,WinID
if (vWinID=WinID)
return
	If StrAr_Find(ToggleList,WinID)
	{
; 		还原窗口
		DllCall("SetParent", "UInt", WinID, "UInt", 0)
		;WinSet, Style, +0xC00000,ahk_id %WinID%
		WinSet,Region,,ahk_id %WinID%
		ToggleList:=StrAr_DeletElement(ToggleList,WinID,1)
	}
	Else
	{
; 		Pin to Desktop
		Gosub,ToggleDesktop
		ToggleList:=StrAr_Add(ToggleList,WinID)
		DeskGroup_%ActDeskNum%:=StrAr_Add(DeskGroup_%ActDeskNum%,WinID)
	}
	Gosub,AddWinMenu
Return

AddWinMenu:
Menu,AllWinMenu,DeleteAll
Loop, parse,ToggleList,`|
{
	IfWinNotExist,ahk_id %A_LoopField%
	{
		ToggleList:=StrAr_DeletElement(ToggleList,A_LoopField,1)
; 		Desktop_1:=StrAr_DeletElement(Desktop_1,A_LoopField,1)
; 		Desktop_2:=StrAr_DeletElement(Desktop_2,A_LoopField,1)
; 		Desktop_3:=StrAr_DeletElement(Desktop_3,A_LoopField,1)
; 		Desktop_4:=StrAr_DeletElement(Desktop_4,A_LoopField,1)
	}
	Else
	{
		WinGetTitle,Title,ahk_id %A_LoopField%
		Menu,AllWinMenu,Add,%Title%,SubHandler
}
}
Menu,AllWinMenu,Add
Menu,AllWinMenu,Add,还原所有窗口,Disall
Return

DeskAdd: ;添加到桌面 n
If (ActDeskNum=A_ThisMenuItemPos)
{
	Return
}
WinHide,ahk_id %WinID%
Loop 4
{
	DeskGroup_%A_Index%:=StrAr_DeletElement(DeskGroup_%A_Index%,WinID,1)
}
DeskGroup_%A_ThisMenuItemPos%:=StrAr_Add(DeskGroup_%A_ThisMenuItemPos%,WinID)
; MsgBox % DeskGroup_%A_ThisMenuItemPos%
Return

;~+RButton::
Pin2Desk_WinMenu:
Gosub,AddWinMenu
WinGet,WinID,ID,A
If StrAr_Find(ToggleList,WinID)
{
	Menu,SigleMenu,Show
	send {Shift Up}
	}
Return

Disa:
WinGet,WinID,ID,A
	If StrAr_Find(ToggleList,WinID)
	{
; 		ToolTip Delete
		DllCall("SetParent", "UInt", WinID, "UInt", 0)
		;WinSet, Style, +0xC00000,ahk_id %WinID%
		WinSet,Region,,ahk_id %WinID%
		ToggleList:=StrAr_DeletElement(ToggleList,WinID,1)
}
Return

disall:
	Loop, parse,ToggleList,`|
	{
		WinShow,ahk_id %A_LoopField%
		DllCall("SetParent", "UInt", A_LoopField, "UInt", 0)
		;WinSet, Style, +0xC00000, ahk_id %A_LoopField%
		WinSet,Region,,ahk_id %A_LoopField%
		ToggleList:=StrAr_DeletElement(ToggleList,A_LoopField,1)
}
Return

ActDesk: ;激活桌面 n
If (A_ThisMenuItemPos=ActDeskNum)
{
	Return
}
ActDeskNum:=A_ThisMenuItemPos
;----------------------------------------------------------------------------

HotKeyAct:
Loop, parse,ToggleList,`|
{
	WinHide,ahk_id %A_LoopField%
}

;添加虚拟桌面功能
DetectHiddenWindows,Off
SwitchToDesktop(ActDeskNum)
Sleep,200
DetectHiddenWindows,On
;添加虚拟桌面功能

DeskGroup:=DeskGroup_%ActDeskNum%
; MsgBox %DeskGroup%
Loop, parse,DeskGroup,`|
{
	If (A_LoopField="")
	{
		Continue
	}

	IfWinNotExist,ahk_id %A_LoopField%
	{
		temp1:=DeskGroup_%ActDeskNum%
		DeskGroup_%ActDeskNum%:=StrAr_DeletElement(DeskGroup_%ActDeskNum%,A_LoopField,1)
		temp:=DeskGroup_%ActDeskNum%
; 		MsgBox NoExist[%A_LoopField%]`n%temp1%`n%temp%
	}
	WinShow,ahk_id %A_LoopField%
}

Loop 4
{
	MenuName=虚拟桌面 %A_Index%
	Menu,SigleMenu,Uncheck,%MenuName%
}

MenuName=虚拟桌面 %ActDeskNum%
Menu,SigleMenu,Check,%MenuName%
; ToolTip % DeskGroup_%ActDeskNum%

Return

SubHandler:  ;激活菜单窗体
Title:=StrAr_Get(ToggleList,A_ThisMenuItemPos)
WinShow,ahk_id %Title%
WinActivate,ahk_id %Title%
; MsgBox %ToggleList%`n[%A_ThisMenuItemPos%][%Title%]
Return


ToggleDesktop: ;钉住桌面

;Gosub,SetReg

DetectHiddenWindows,Off
WinGet, DesktopID, ID, ahk_class WorkerW
if !DesktopID
WinGet, DesktopID, ID, Program Manager


DllCall("SetParent", "UInt", WinID, "UInt", DesktopID)
DetectHiddenWindows, On

regular=[:\s/\\][\s\S]+
WinClass:=RegExReplace(WinClass,regular,"_")

If WinClass In %ClassTpye%
{
        Gosub,SetExReg
}
Else
{
        Gosub,SetReg
}
Return

SetExReg:

Ctrl_:=Ctrl_%WinClass%
ControlGetPos,td_x,td_y,td_w,td_h,%Ctrl_%,ahk_id %WinID%

Ox:=td_x
Oy:=td_y
Opos=%Ox%-%Oy%

WinSet,Region,%Opos%  W%td_w% H%td_h% R10-10, ahk_id %WinID%
;MsgBox %td_x%-%td_y%-%td_w%-%td_h%-%Ctrl_%-%WinID%-%Opos%
Return

SetReg:
; WinGet,WinID,ID,A
WinGetPos,WinX,WinY,WinW,WinH,ahk_id %WinID%
Ox:=4
Oy:=24
Opos=%Ox%-%Oy%

WinW-=2*Ox
WinH-=Oy+4

;MsgBox %x%-%y%-%w%-%h%-%Ctrl_%-%WinID%-%Opos%-%WinW%-%WinH%
; WinSet,Transparent,200,ahk_id %WinID%
WinSet,Region,%Opos%  W%WinW% H%WinH% R10-10, ahk_id %WinID%
; ToolTip %WinW% %WinH%
Return

/*
Setreg:
WinSet, Style, -0xC00000, ahk_id %WinID%
Return
*/

;!#1::
;!#2::
;!#3::
;!#4::
ToggleVirtualDesktop:
StringRight,ActDeskNum,A_thishotkey,1
Gosub,HotKeyAct
Return

SendActiveToDesktop:
StringRight,TempStr,A_thishotkey,1
SendActiveToDesktop(TempStr)
Return

;^!f1::SendActiveToDesktop(1)
;^!f2::SendActiveToDesktop(2)
;^!f3::SendActiveToDesktop(3)
;^!f4::SendActiveToDesktop(4)

;LWin & Up::
Pin2Desk_WinMoveUp:
WinGet,WinID,ID,A
WinGetPos,x,y,w,h,ahk_id %WinID%
y-=10
If StrAr_Find(ToggleList,WinID)
{
	WinMove,ahk_id %WinID%,,x,y
}
else send #{Up}
Return

;LWin & Down::
Pin2Desk_WinMoveUpDown:
WinGet,WinID,ID,A
WinGetPos,x,y,w,h,ahk_id %WinID%
y+=10
If StrAr_Find(ToggleList,WinID)
{
	WinMove,ahk_id %WinID%,,x,y
}
else send #{Down}
Return

;LWin & Left::
Pin2Desk_WinMoveUpLeft:
WinGet,WinID,ID,A
WinGetPos,x,y,w,h,ahk_id %WinID%
x-=10
If StrAr_Find(ToggleList,WinID)
{
	WinMove,ahk_id %WinID%,,x,y
}
else send #{Left}
Return

;LWin & Right::
Pin2Desk_WinMoveUpRight:
WinGet,WinID,ID,A
WinGetPos,x,y,w,h,ahk_id %WinID%
x+=10
If StrAr_Find(ToggleList,WinID)
{
	WinMove,ahk_id %WinID%,,x,y
}
else send #{Right}
Return

; ***** 虚拟桌面函数 functions *****
; https://autohotkey.com/board/topic/5793-multiple-virtual-desktops/page-1

; switch to the desktop with the given index number
SwitchToDesktop(newDesktop)
{
   global
	WinClose, ahk_class SysShadow
   if (curDesktop <> newDesktop)
   {
      GetCurrentWindows(curDesktop)
      ShowHideWindows(curDesktop, false)
      ShowHideWindows(newDesktop, true)
      activate_window := % active_id%newDesktop%
      WinActivate, ahk_id %activate_window%
      TrayTip, DesktopSwitch, Switching to desktop %newDesktop%
      curDesktop := newDesktop
   }
	WinClose, ahk_class SysShadow
   return
}

; sends the given window from the current desktop to the given desktop
SendToDesktop(windowID, newDesktop)
{
   global
   if (curDesktop <> newDesktop)
   {
   RemoveWindowID(curDesktop, windowID)

   ; add window to destination desktop
   windows%newDesktop% += 1
   i := windows%newDesktop%

   windows%newDesktop%%i% := windowID

   WinHide, ahk_id %windowID%
   TrayTip, DesktopSwitch, Window send to desktop %newDesktop%

   Send, {ALT DOWN}{TAB}{ALT UP}   ; activate the right window
   }
}

; sends the currently active window to the given desktop
SendActiveToDesktop(newDesktop)
{
   WinGet, id, ID, A
   SendToDesktop(id, newDesktop)
}

; removes the given window id from the desktop <desktopIdx>
RemoveWindowID(desktopIdx, ID)
{
   global
   Loop, % windows%desktopIdx%
   {
      if (windows%desktopIdx%%A_Index% = ID)
      {
         windows%desktopIdx%%A_Index%=      ;Emiel: just empty the array element, array will be emptied by next switch anyway
         Break
      }
   }
}

; this builds a list of all currently visible windows in stores it in desktop <index>
GetCurrentWindows(index)
{
   global
   WinGet, active_id%index%, ID, A                      ; get the current active window
   emptyString =
   StringSplit, windows%index%, emptyString             ; Emiel: delete the entire windows_index_ array
   WinGet, windows%index%, List,,, Program Manager      ; get list of all visible windows

   ; remove windows which we want to see on all virtual desktops
   Loop, % windows%index%
   {
      id := % windows%index%%A_Index%
      WinGetClass, windowClass, ahk_id %id%
      if windowClass = Shell_TrayWnd     ; remove task bar window id
           windows%index%%A_Index%=      ; Emiel: just empty the array element, array will be emptied by next switch anyway
      if windowClass = #32770            ; Emiel: we also want multimontaskbar on all virtual desktops
           windows%index%%A_Index%=      ; Emiel: just empty the array element, array will be emptied by next switch anyway
      if windowClass = cygwin/x X rl-xosview-XOsview-0   ; Emiel: xosviews e.d.
           windows%index%%A_Index%=
      if windowClass = cygwin/x X rl-xosview-XOsview-1   ; Emiel: xosviews e.d.
           windows%index%%A_Index%=
      if windowClass = MozillaUIWindowClass              ; Mozilla thunderbird
      {
        WinGet, ExStyle, ExStyle, ahk_id %id%
          if (ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.    ; Alleen de mailboxalertmelding!
           windows%index%%A_Index%=
      }
   }
}