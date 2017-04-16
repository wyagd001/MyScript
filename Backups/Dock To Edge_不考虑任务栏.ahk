Gui_Dock_Windows:
CoordMode,Mouse,Screen
Edge_Dock_%Gui_wid% =%Gui_wid% ; write window ID to a unique variable
Edge_Dock_Position_%Gui_wid% :=A_ThisMenuItem ; store Left, Right, etc
WinGet, Edge_Dock_State_%Gui_wid%, MinMax, ahk_id %Gui_wid%
If Edge_Dock_State_%Gui_wid% =-1 ; if window is mimised, un-minimise
    WinRestore, ahk_id %Gui_wid%
WinGetPos, Edge_Dock_X_%Gui_wid%, Edge_Dock_Y_%Gui_wid%, Edge_Dock_Width_%Gui_wid%, Edge_Dock_Height_%Gui_wid%, ahk_id %Gui_wid%
Edge_Dock_X_Initial_%Gui_wid% := Edge_Dock_X_%Gui_wid%
Edge_Dock_Y_Initial_%Gui_wid% := Edge_Dock_Y_%Gui_wid%
Edge_Dock_Width_Initial_%Gui_wid% := Edge_Dock_Width_%Gui_wid%
Edge_Dock_Height_Initial_%Gui_wid% := Edge_Dock_Height_%Gui_wid%
; store AlwaysOnTop original status
WinGet, Edge_Dock_AlwaysOnTop_%Gui_wid%, ExStyle, ahk_id %Gui_wid%
If Gui_Dock_Windows_List =
    Gui_Dock_Windows_List =%Gui_wid% ; keep track of number of docked windows
 Else
    Gui_Dock_Windows_List .="|" Gui_wid
    WinSet, AlwaysOnTop, On, ahk_id %Gui_wid%
Gui_Dock_Windows_ReDock:
sleep,1000
Edge_Dock_X =
Edge_Dock_Y =
; leave just 5 pixels (Edge_Dock_Border_Visible) of side visible
If Edge_Dock_Position_%Gui_wid% contains Left
    Edge_Dock_X := - ( Edge_Dock_Width_%Gui_wid% - Edge_Dock_Border_Visible )
Else If Edge_Dock_Position_%Gui_wid% contains Right
    Edge_Dock_X := A_ScreenWidth - Edge_Dock_Border_Visible
If Edge_Dock_Position_%Gui_wid% contains Top
    Edge_Dock_Y := - ( Edge_Dock_Height_%Gui_wid% - Edge_Dock_Border_Visible )
Else If Edge_Dock_Position_%Gui_wid% contains Bottom
    Edge_Dock_Y :=A_ScreenHeight - Edge_Dock_Border_Visible
;WinMove, ahk_id %Gui_wid%,, %Edge_Dock_X%, %Edge_Dock_Y%

Slide(Gui_wid, Edge_Dock_X,Edge_Dock_Y, "In",20)
WinMove, ahk_id %Gui_wid%,, %Edge_Dock_X%, %Edge_Dock_Y%

SetTimer, Check_Mouse_Position, %Edge_Dock_Activation_Delay% ; change to affect response time to having mouse over edge-docked window
Return

Check_Mouse_Position:
CoordMode, Mouse, Screen
Gosub, Check_Docked_Windows_Exist
WinGet, Previously_Active_Window_Before_Using_Docked, ID, A
Edge_Dock_Active_Window =
If ( Edge_Dock_%Previously_Active_Window_Before_Using_Docked% != "" ) ; check keyboard focus
    {
    CoordMode, Mouse, Screen
    MouseGetPos,Check_Mouse_Position_X, Check_Mouse_Position_Y
    Edge_Dock_Active_Window := Previously_Active_Window_Before_Using_Docked
    }
MouseGetPos,,, Mouse_Over_Window
If ( Edge_Dock_%Mouse_Over_Window% != "" ) ; over-ride keyboard with mouse "focus" if necessary
    {
    Edge_Dock_Active_Window := Mouse_Over_Window
    WinActivate, ahk_id %Mouse_Over_Window%
    }
If Edge_Dock_Active_Window != ; i.e. window is already docked
    {
    SetTimer, Check_Mouse_Position, Off
    WinGet, PID_Edge_Dock_Active_Window, PID, ahk_id %Edge_Dock_Active_Window%
    Edge_Dock_X =
    Edge_Dock_Y =
    ; move window onto screen
    If Edge_Dock_Position_%Edge_Dock_Active_Window% contains Left
      Edge_Dock_X =0
    Else If Edge_Dock_Position_%Edge_Dock_Active_Window% contains Right
      Edge_Dock_X :=  - Edge_Dock_Width_%Edge_Dock_Active_Window%
    If Edge_Dock_Position_%Edge_Dock_Active_Window% contains Top
      Edge_Dock_Y =0
    Else If Edge_Dock_Position_%Edge_Dock_Active_Window% contains Bottom
      Edge_Dock_Y := A_ScreenHeight  - Edge_Dock_Height_%Edge_Dock_Active_Window%
    WinSet, AlwaysOnTop, On, ahk_id %Edge_Dock_Active_Window%
;    WinMove, ahk_id %Edge_Dock_Active_Window%,, %Edge_Dock_X%, %Edge_Dock_Y%
;msgbox % Edge_Dock_Y
     Slide(Edge_Dock_Active_Window, Edge_Dock_X,Edge_Dock_Y, "Out",20)
    SetTimer, Check_Mouse_Position_Deactivate, %Edge_Dock_Activation_Delay%
    }
Return

Check_Docked_Windows_Exist:
If Gui_Dock_Windows_List = ; keep track of number of docked windows
    {
    SetTimer, Check_Mouse_Position, Off
    SetTimer, Check_Mouse_Position_Deactivate, Off
    Return
    }
  Loop, Parse, Gui_Dock_Windows_List,| ; check if windows in docked list have been closed before un-docking
    {
    IfWinNotExist, ahk_id %A_LoopField%
      {
      Gui_wid =%A_LoopField%
      Gui_Un_Dock_Window_No_Alt_Esc =1
      Gosub, Gui_Un_Dock_Window
      }
    }
Return


Check_Mouse_Position_Deactivate: ; check if not over an edge-docked window any more
Gosub, Check_Docked_Windows_Exist

WinGet, Style, Style, ahk_id %Edge_Dock_Active_Window%
If ( Style & WS_DISABLED ) ; don't allow disabled windows to be re-docked (e.g., showing save box)
    Return

; retrieve active window focus and mouse over window - active window has priority
WinGet, PID_Active_Window_Now, PID, A
WinGet, Active_Window_Now_ID, ID, A
WinGetTitle, Active_Window_Now_Title, A ; use titles to check if in same program title but over a problematic control such as xplorer2 dropdownbox (different id and pid)
WinGetTitle, Edge_Dock_Active_Window_Title, ahk_id %Edge_Dock_Active_Window%
WinGetTitle, Active_Window_Now_Mouse_Title, ahk_id %Active_Window_Now_Mouse%

CoordMode, Mouse, Screen
MouseGetPos,Active_Window_Now_Mouse_X, Active_Window_Now_Mouse_Y, Active_Window_Now_Mouse
If ((Check_Mouse_Position_X >= Active_Window_Now_Mouse_X -10 and Check_Mouse_Position_X <= Active_Window_Now_Mouse_X +10) ; ; mouse not moved - e.g. clicked taskbar
    and (Check_Mouse_Position_Y >= Active_Window_Now_Mouse_Y -10 and Check_Mouse_Position_Y <= Active_Window_Now_Mouse_Y +10)
    and (Active_Window_Now_Title = Edge_Dock_Active_Window_Title))
      Return

If (Active_Window_Now_Title = Edge_Dock_Active_Window_Title and Active_Window_Now_Mouse_Title = ""
        and (Active_Window_Now_ID != TaskBar_ID and Active_Window_Now_Mouse != TaskBar_ID))
      Return
If (PID_Active_Window_Now != PID_Edge_Dock_Active_Window) ; compare pid to check that a child window is not created/active
    Gosub, Gui_Dock_Windows_ReDock_Initiate
Else
    {
    WinGet, PID_Active_Window_Now_Mouse, PID, ahk_id %Active_Window_Now_Mouse%
    If (PID_Active_Window_Now_Mouse != PID_Edge_Dock_Active_Window)
      {
      Gosub, Gui_Dock_Windows_ReDock_Initiate
      If Gui_Dock_Windows_List contains %Previously_Active_Window_Before_Using_Docked% ; activate window under mouse to prevent looping
        WinActivate, ahk_id %Active_Window_Now_Mouse%
      Else
        WinActivate, ahk_id %Previously_Active_Window_Before_Using_Docked%
      }
    }
Return

Gui_Dock_Windows_ReDock_Initiate:
SetTimer, Check_Mouse_Position_Deactivate, Off
WinSet, AlwaysOnTop, On, ahk_id %Edge_Dock_Active_Window%
WinGetPos, Edge_Dock_X_%Edge_Dock_Active_Window%, Edge_Dock_Y_%Edge_Dock_Active_Window%, Edge_Dock_Width_%Edge_Dock_Active_Window%
    , Edge_Dock_Height_%Edge_Dock_Active_Window%, ahk_id %Edge_Dock_Active_Window%
Gui_wid =%Edge_Dock_Active_Window%
Gosub, Gui_Dock_Windows_ReDock
Return

Gui_Un_Dock_Window:
If Gui_Un_Dock_Window_No_Alt_Esc !=1
; reset
Gui_Un_Dock_Window_No_Alt_Esc =
; 0x8 is WS_EX_TOPMOST - keep AlwaysOnTop if originally on top
If ! ( Edge_Dock_AlwaysOnTop_%Gui_wid% & 0x8 )
    WinSet, AlwaysOnTop, Off, ahk_id %Gui_wid%
; original position
WinMove, ahk_id %Gui_wid%,, % Edge_Dock_X_Initial_%Gui_wid%, % Edge_Dock_Y_Initial_%Gui_wid%, % Edge_Dock_Width_Initial_%Gui_wid%
    , % Edge_Dock_Height_Initial_%Gui_wid%

; erase variables
Edge_Dock_%Gui_wid% =
Edge_Dock_X_Initial_%Gui_wid% =
Edge_Dock_Y_Initial_%Gui_wid% =
Edge_Dock_Width_Initial_%Gui_wid% =
Edge_Dock_Height_Initial_%Gui_wid% =
Edge_Dock_State_%Gui_wid% =
Edge_Dock_X_%Gui_wid% =
Edge_Dock_Y_%Gui_wid% =
Edge_Dock_Width_%Gui_wid% =
Edge_Dock_Height_%Gui_wid% =
Edge_Dock_Position_%Gui_wid% =
Edge_Dock_AlwaysOnTop_%Gui_wid% =

StringReplace, Gui_Dock_Windows_List, Gui_Dock_Windows_List,%Gui_wid%| ; remove entry
If ErrorLevel =1
    StringReplace, Gui_Dock_Windows_List, Gui_Dock_Windows_List,%Gui_wid% ; last window so no delimiter to replace too
Return

Gui_Un_Dock_Windows_All:
  Loop, Parse, Gui_Dock_Windows_List,| ; check if windows in docked list have been closed before un-docking
    {
    Gui_wid := A_LoopField
    Gui_Un_Dock_Window_No_Alt_Esc =1
    Gosub, Gui_Un_Dock_Window
    }
Return

Slide(Win,X,Y,Dir,Num=10, Sleep=5)  ;Thanks Infogulch for the idea behind this.
{
	CoordMode,Mouse,Screen
	WinGetPos, , , Dock_Width,Dock_Hight, ahk_id  %Win%
	if(dir="Out")
	{
		Loop %Num%
		{
			if(x=0)   ;©©вС
				WinMove_X:=A_Index * Dock_Width / Num - Dock_Width
			if(x>0)   ;©©ср
				WinMove_X:=A_ScreenWidth - A_Index * Dock_Width / Num
			if(y=0)   ;©©ио
				WinMove_Y:=A_Index * Dock_Hight / Num - Dock_Hight
			if(y>0)   ;©©об
				WinMove_Y:=A_ScreenHeight - A_Index * Dock_Hight / Num
			WinMove, ahk_id %Win%,, %WinMove_X%, %WinMove_Y%
			Sleep, %Sleep%
		}
	}
	else if(dir="In")
	{
		Loop %Num%
		{
			if(x<0 and x <> "")
				WinMove_X:=(-A_Index) * Dock_Width / Num
			if(x>0)
				WinMove_X:=A_ScreenWidth + A_Index * Dock_Width / Num - Dock_Width
			if(y<0 and y <> "")
				WinMove_Y:=(-A_Index ) * Dock_Hight / Num
			if(y>0)
				WinMove_Y:=A_ScreenHeight  + A_Index * Dock_Hight / Num - Dock_Hight
			WinMove, ahk_id %Win%,, %WinMove_X%, %WinMove_Y%
			Sleep, %Sleep%
		}
	}
}