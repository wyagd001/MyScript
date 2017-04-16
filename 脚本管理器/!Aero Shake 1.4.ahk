; Aero Shake (like Windows 7)
;
; AutoHotkey Version: 1.0.47.01 (tested version)
; Language:       English
; Platform:       Windows XP, Vista
; Author:         Bobbo33
;
; Script Function:
;   Left-click on a window's title bar and "shake" it
;   back and forth, all other windows minimize
;
; Inspired by:
;   http://lifehacker.com/5078582/top-10-things-to-look-forward-to-in-windows-7
;
; Change log:
; v1.0 2008-11-08 Release
; v1.1 2008-11-09 Rewrite MouseOverTitleBar function to use titlebarheight, because Office 2007 doesn't use standard windows titlebar controls
;                 Rewrite MINALLEXCEPTACTIVE to use GetMonitorAt so only the windows on the active monitor are minimized
;                 Add window restore to MINALLEXCEPTACTIVE when only one window is visible
; v1.2 2008-11-11 Fix bug to reset shake count if left mouse button is continually held down
;                 Fix bug in GetMonitorAt so minallmonitors works correctly for multimonitor configurations
;                 Add quick minimize mode to suppress window animation
;                 Add AeroShake.ini file for configuration
;                 Add tray icon GUI (title, about, settings)
;                 Add WinGetInOrder to preserve taskbar icon order in window hide/show operations
;v1.3 2008-11-12  Fix bug in multimonitor mode so taskbar icon order is maintained
;v1.4 2008-11-16  Add GetParent check to prevent minimizing modal dialogs

;environment
#NoEnv
SendMode Input
#Persistent
#SingleInstance
SetWorkingDir %A_ScriptDir%

;setup
CoordMode, Mouse, Screen
DetectHiddenWindows, Off
Gosub, CLEARMOUSESHAKE
Gosub, TRAYMENU
Gosub, INI

;start hotkeys looking for action
~LButton::Gosub, STARTMOUSESHAKE
~LButton Up::Gosub, CLEARMOUSESHAKE
return

;runs when left mouse button is pressed
STARTMOUSESHAKE:
SetTimer, CHECKMOUSESHAKE, 10
MouseGetPos, x
xstart := x
xstate := 0
xstate_prev := xstate
xcount := 0
return

;runs when left mouse button is released
CLEARMOUSESHAKE:
SetTimer, CHECKMOUSESHAKE, Off
MouseGetPos, x
xstart := x
xstate := 0
xstate_prev := xstate
xcount := 0
ToolTip
return

;runs on timer to monitor if a window shake has occurred
CHECKMOUSESHAKE:
   if ( MouseOverTitleBar() )
   {
      ;check that active window is neither minimized or maximized
      MouseGetPos, xPos, yPos, WindowUnderMouseID
      WinGet, windowstate, MinMax, ahk_id %WindowUnderMouseID%
      if ( windowstate = 0)
      {
         ;ToolTip, Debug:`nxstart=%xstart%`nxstate=%xstate%`nxstate_prev=%xstate_prev%`nxcount=%xcount%
         xstate_prev := xstate
         MouseGetPos, x, y
         if ( (x-xstart) > shake_distance )
         {
            ; moving up
            xstate := 1
            xstart := x
         }
         else if ( (xstart-x) > shake_distance )
         {
            ; moving down
            xstate := -1
            xstart := x
         }

         if ( xstate <> xstate_prev )
            xcount := xcount + 1

         if ( xcount > shake_count )
         {
            ;ToolTip, Debug: Mouse shake detected
            xcount := 0
            Gosub, MINALLEXCEPTACTIVE
            return
         }
         Sleep, 10
      }
   }
return

;returns true if mouse is over the active window's titlebar
;(probably a better way to do this than the hardcoded titlebarheight constant)
MouseOverTitleBar( )
{
   global titlebarheight
   MouseGetPos, xPos, yPos, WindowUnderMouseID
   WinGetPos, X, Y, W, H, ahk_id %WindowUnderMouseID%
   If ( (yPos-Y) < titlebarheight ) and ( (yPos-Y) > 0 )
      return, true
   Else
      return, false
}

;this is the action taken when a window shake is detected
;if there is more than one window no minimized, minimizes all but active one (and stores list of what was minimized)
;if only one window is minimized, restores windows previously minimized
MINALLEXCEPTACTIVE:
;code credit: http://www.autohotkey.com/forum/topic37539.html

;get window info
Winget, activeID, id, A
;Winget, winlist, list
WinGetInOrder("winlist")
WinGetPos, X, Y, W, H, A
activemonitor := GetMonitorAt(X,Y)

;count number of windows not minimized
windowcount := 0
loop %winlist%
{
   winid := winlist%A_Index%
   WinGetTitle, wintitle, ahk_id %winid%
   WinGetPos, X, Y, W, H, ahk_id %winid%
   thismonitor := GetMonitorAt(X+W/2,Y+H/2)
   WinGet, windowstate, MinMax, ahk_id %winid%
   winParent := DllCall("GetParent", "uint", activeID)
   if ( (strlen(wintitle) != 0) AND (winid != activeID) AND (windowstate >= 0) AND (wintitle != "Program Manager") AND (winParent <> winid) )
   {
      if ( minallmonitors OR (thismonitor = activemonitor) )
      {
         windowcount := windowcount + 1
         minimizelist%windowcount% = %winid%
      }
   }
}

;either minimize or restore windows (based on result of windowcount)
loop %winlist%
{
   ;get each window's parameters
   winid := winlist%A_Index%
   WinGetTitle, wintitle, ahk_id %winid%
   WinGetPos, X, Y, W, H, ahk_id %winid%
   thismonitor := GetMonitorAt(X+W/2,Y+H/2)
   WinGet, windowstate, MinMax, ahk_id %winid%

   ;check if window is on the list before acting on it
   if (windowcount >= 1)
      mincount := windowcount
   match := false
   loop %mincount%
   {
      listedwin := minimizelist%A_Index%
      if (listedwin = winid)
         match := true
   }
   if (match)
   {
      if (quickminimize)
         DllCall("AnimateWindow","UInt", winid, "Int", 0, "UInt", "0xF0000")
      if (windowcount < 1)
      {
         ;only one visible window, so restore from previously saved list
         DllCall("ShowWindow", "UInt", winid, "UInt", 9) ; 9=SW_RESTORE
      }
      else
      {
         ;more than one visible window, so minimize them all
         DllCall("ShowWindow", "UInt", winid, "UInt", 7) ; 7=SW_SHOWMINNOACTIVE
      }
   }
   else
   {
      ;even if not on the list, still have to touch the window state to keep the taskbar buttons in order
      if (quickminimize)
         DllCall("AnimateWindow","UInt", winid, "Int", 0, "UInt", "0xF0000")
      if (windowstate = -1) ;minimized
         DllCall("ShowWindow", "UInt", winid, "UInt", 7) ; 7=SW_SHOWMINNOACTIVE
      else if (windowstate = 1) ;maximized
         DllCall("ShowWindow", "UInt", winid, "UInt", 8) ; 8=SW_SHOWNA
      else
         DllCall("ShowWindow", "UInt", winid, "UInt", 8) ; 8=SW_SHOWNA
   }
   ;if it's the active window, restore it
   if (winid = activeID)
   {
      if (quickminimize)
         DllCall("AnimateWindow","UInt", activeID, "Int", 0, "UInt", "0xF0000")
      DllCall("ShowWindow", "UInt", activeID, "UInt", 9) ; 9=SW_RESTORE
   }
}
;WinActivate ahk_id %activeID%
return

;returns the monitor number of the given coordinates (in pixels)
GetMonitorAt(x, y, default=1)
{
    ; Get the index of the monitor containing the specified x and y co-ordinates.
    ; code credit: http://www.autohotkey.com/forum/topic21703.html
    SysGet, m, MonitorCount

    ; Iterate through all monitors.
    Loop, %m%
    {   ; Check if the window is on this monitor.
        SysGet, Mon, Monitor, %A_Index%
        if (x >= MonLeft && x <= MonRight && y >= MonTop && y <= MonBottom)
            return A_Index
    }

    return default
}

;displays tray icon right-click menu
TRAYMENU:
Menu,Tray,NoStandard
Menu,Tray,DeleteAll
Menu,Tray,Add,&About AeroShake...,ABOUT
Menu,Tray,Add,&Settings...,EDITINI
Menu,Tray,Add,E&xit,Exit
Menu,Tray,Default,&About AeroShake...
Menu,Tray,Tip,AeroShake v1.4
Return

;displays about dialog
ABOUT:
Gui,Destroy
Gui,Font
Gui,Add,Text,xm y+0,Last update by bobbo33 on 2008-11-16
Gui,Font
Gui,Add,Text,xm y+20,Made using AutoHotkey -
Gui,Font,CBlue Underline
Gui,Add,Text,x+5 GAUTOHOTKEY,http://www.autohotkey.com
Gui,Font
Gui,Add,Text,xm y+20,Published by Lifehacker Coders -
Gui,Font,CBlue Underline
Gui,Add,Text,x+5 GLIFEHACKERCODERS,http://groups.google.com/group/lifehacker-coders
Gui,Font
Gui,Add,Text,xm y+20,Inspired by Windows 7 -
Gui,Font,CBlue Underline
Gui,Add,Text,x+5 GINSPIREDBY,http://lifehacker.com/5078582/top-10-things-to-look-forward-to-in-windows-7
Gui,Font
Gui,Add,Button,GABOUTOK Default xm+220 y+20 w75,&OK
Gui,Show,,AeroShake v1.4
about=
Return

AUTOHOTKEY:
Run,http://www.autohotkey.com,,UseErrorLevel
Return

LIFEHACKERCODERS:
Run,http://groups.google.com/group/lifehacker-coders,,UseErrorLevel
Return

INSPIREDBY:
Run,http://lifehacker.com/5078582/top-10-things-to-look-forward-to-in-windows-7,,UseErrorLevel
Return

ABOUTOK:
Gui,Destroy
Return

EDITINI:
Run,notepad.exe AeroShake.ini,,UseErrorLevel
Return

EXIT:
ExitApp


;creates AeroShake.ini if it doesn't exist in the current directory
;loads configuration parameters from ini file
INI:

;configure detection parameters
;shake_distance := 20      ;in pixels
;shake_count := 4          ;number of "back-and-forths"
;titlebarheight := 26      ;in pixels
;minallmonitors := false   ;minimize windows on all monitors (true), or just the active monitor (false)
;quickminimize := false    ;minimize windows using WinMinimizeAll (true), or one at a time (false), requires minallmonitors=false

IfNotExist,AeroShake.ini
{
  FileAppend,;NOTE: YOU MUST RESTART AEROSHAKE FOR CHANGES TO TAKE EFFECT!`n`n,AeroShake.ini

  FileAppend,;Distance (in pixels) is how far the mouse has to travel to count as one "shake"`n,AeroShake.ini
  FileAppend,;Count is how many shakes occur before action is taken`n,AeroShake.ini
  FileAppend,;Title Bar Height (in pixels) is the vertical distance from the top of the selected window that is monitored for shakes`n,AeroShake.ini
  IniWrite,20,AeroShake.ini,Shake Detection,Distance
  IniWrite,4,AeroShake.ini,Shake Detection,Count
  IniWrite,26,AeroShake.ini,Shake Detection,Title Bar Height
  FileAppend,`n,AeroShake.ini

  FileAppend,;Minimize All Monitors: 1=Minimizes windows on all monitors on shake; 0=Only windows on the active monitor (in a multi-monitor system) are minimized`n,AeroShake.ini
  FileAppend,;Quick Minimize: 1=Minimizes without window animation; 0=Minimizes with window animation (if enabled),AeroShake.ini
  IniWrite,1,AeroShake.ini,Action Settings,Minimize All Monitors
  IniWrite,1,AeroShake.ini,Action Settings,Quick Minimize
  FileAppend,`n,AeroShake.ini
}

IniRead,temp,AeroShake.ini,Shake Detection,Distance
shake_distance := temp
IniRead,temp,AeroShake.ini,Shake Detection,Count
shake_count := temp
IniRead,temp,AeroShake.ini,Shake Detection,Title Bar Height
titlebarheight := temp

IniRead,temp,AeroShake.ini,Action Settings,Minimize All Monitors
minallmonitors := temp
IniRead,temp,AeroShake.ini,Action Settings,Quick Minimize
quickminimize := temp

Return

;replaces "WinGet,ListName,List" command with the same result, but in order as icons displayed on the taskbar
WinGetInOrder(ListName)
{
   ;code credit: http://www.autohotkey.com/forum/topic462.html
   global

   idxTB := GetTaskSwBar()
   ControlGet, hwndTB, Hwnd,, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd

   if !WinExist("ahk_id " hwndTB)
      return

   WinGet, pidTaskbar, PID

   hProc := DllCall("OpenProcess", "uint", 0x38, "int", 0, "uint", pidTaskbar)
   pRB := DllCall("VirtualAllocEx", "uint", hProc, "uint", 0, "uint", 20, "uint", 0x1000, "uint", 0x4)

   VarSetCapacity(btn, 20)

   SendMessage, 0x418  ; TB_BUTTONCOUNT
   count := ErrorLevel

   ListCount := 0
   Loop, %count%
   {
      SendMessage, 0x417, A_Index - 1, pRB  ; TB_GETBUTTON

      DllCall("ReadProcessMemory", "uint", hProc, "uint", pRB, "uint", &btn, "uint", 20, "uint", 0)
      DllCall("ReadProcessMemory", "uint", hProc, "uint", NumGet(btn, 12), "uint*", hwnd, "uint", 4, "uint", 0)
      if ( hwnd <> 0 )
      {
         ListCount := ListCount + 1
         %ListName%%ListCount%  := hwnd
         ;btn%A_Index%_idn   := NumGet(btn, 4, "int")
         ;btn%A_Index%_state := NumGet(btn, 8, "UChar")
      }
    }
    %ListName% := ListCount
}

GetTaskSwBar()
{
   WinGet, ControlList, ControlList, ahk_class Shell_TrayWnd
   RegExMatch(ControlList, "(?<=ToolbarWindow32)\d+(?!.*ToolbarWindow32)", nTB)

   Loop, %nTB%
   {
      ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class Shell_TrayWnd
      hParent := DllCall("GetParent", "uint", hWnd)
      WinGetClass, sClass, ahk_id %hParent%
      If (sClass <> "MSTaskSwWClass")
         Continue
      idxTB := A_Index
         Break
   }

   Return idxTB
}
