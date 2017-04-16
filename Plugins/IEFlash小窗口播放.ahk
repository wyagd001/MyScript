#SingleInstance Force
SetBatchLines -1
DetectHiddenWindows, on
Coordmode Mouse
Menu, Tray, Icon, Shell32.dll, 5

OnExit, ForceExit

WinGetPos, , , , CommandBarHeight, ahk_class Shell_TrayWnd
return

ForceExit:
loop %WS_n%
   If WinExist("ahk_id " . WS_GuiHWND%A_Index%)
      GoSub WS_Restore
exitapp
return


;============================================Window Snap============================================================================================================================================================

Ctrl & LButton::
MouseGetPos, WS_MouseX, WS_MouseY, Window, Ctrl
Loop %WS_n%
   If (WS_GuiHWND%A_Index% = Window)
   {
      Gosub WS_Restore
      Return
   }
WinGetPos, WS_WinX, WS_WinY, , , ahk_id %Window%
WinGetTitle, ActiveTitle, ahk_id %Window%
WS_CancelDraw = U
Gui 91:color, FF007F
Gui 91:+ToolWindow -SysMenu -Caption +AlwaysOnTop
Gui 92:color, FF007F
Gui 92:+ToolWindow -SysMenu -Caption +AlwaysOnTop
Gui 93:color, FF007F
Gui 93:+ToolWindow -SysMenu -Caption +AlwaysOnTop
Gui 94:color, FF007F
Gui 94:+ToolWindow -SysMenu -Caption +AlwaysOnTop
Gui 95:color, FF007F
Gui 95:+ToolWindow -SysMenu -Caption +AlwaysOnTop
WS_Over = 0
Loop
{
   GetKeyState, WS_Clicked, LButton, P
   GetKeyState, WS_CancelDraw, Space, P
   MouseGetPos, WS_NewMouseX, WS_NewMouseY, , NewCtrl
   If (NewCtrl <> Ctrl) {
      If (InStr(NewCtrl, "Flash") or InStr(NewCtrl, "Silverlight")) ;macromedia flash objects and microsoft silverlight objects were the only two that I noticed had different controls in ie browser windows. if you know of others let me know.
      {
         Ctrl := NewCtrl
         ControlGetPos, WS_cx, WS_cy, WS_cw, WS_ch, %Ctrl%, ahk_id %window%
         WS_cx += WS_WinX, WS_cy += WS_WinY
         Gui 91:destroy
         Gui 92:destroy
         Gui 93:destroy
         Gui 94:destroy
         Gui 95:destroy
         WS_n++
         WS_MouseX -= WS_cw / 2
         WS_MouseY -= WS_ch / 2
         WS_OffsetX%WS_n% = 0
         WS_OffsetY%WS_n% = 0
         Goto WS_CreateGUI
      } Else
         WS_Over++
   } Else
      If WS_Over
         WS_Over--
   If (WS_Clicked = "U") or (WS_CancelDraw= "D") or (WS_Over > 10)
      Break
   WS_ClickX := (WS_NewMouseX > WS_MouseX) ? WS_MouseX - 15 : WS_NewMouseX - 15
   WS_ClickY := (WS_NewMouseY > WS_MouseY) ? WS_MouseY - 15 : WS_NewMouseY - 15
   WS_cw := (WS_NewMouseX > WS_MouseX) ? WS_NewMouseX - WS_MouseX + 25 : WS_MouseX - WS_NewMouseX + 25
   WS_ch := (WS_NewMouseY > WS_MouseY) ? WS_NewMouseY - WS_MouseY + 25 : WS_MouseY - WS_NewMouseY + 25
   WS_RCorner := WS_ClickX + WS_cw
   WS_LCorner := WS_ClickY + WS_ch
   Gui 91:show, H5 W%WS_cw% X%WS_ClickX% Y%WS_ClickY% NA
   Gui 92:show, H%WS_ch% W5 X%WS_ClickX% Y%WS_ClickY% NA
   Gui 93:show, H5 W%WS_cw% X%WS_ClickX% Y%WS_LCorner% NA
   Gui 94:show, H%WS_ch% W5 X%WS_RCorner% Y%WS_ClickY% NA
   Gui 95:show, H5 W5 X%WS_RCorner% Y%WS_LCorner% NA
}
WS_ClickX += 15, WS_ClickY += 15, WS_cw -= 25, WS_ch -= 25
WS_n++
ControlGetPos, WS_cx, WS_cy, , , %Ctrl%, ahk_id %window%
WS_OffsetX%WS_n% := WS_cx + WS_WinX - WS_ClickX
WS_OffsetY%WS_n% := WS_cy + WS_WinY - WS_ClickY
Gui 91:destroy
Gui 92:destroy
Gui 93:destroy
Gui 94:destroy
Gui 95:destroy
WS_MouseX := WS_ClickX + WS_cw / 2
WS_MouseY := WS_ClickY + WS_ch / 2
If (WS_CancelDraw = "U") and (WS_cw > 100) and (WS_ch > 100)
   Goto WS_CreateGUI
Return

WS_Restore:
DllCall("SetParent", "UInt", WS_Control%A_Index%, "UInt", WS_Parent%A_Index%)
Gui, %A_Index%:Destroy
WS_Control%A_Index% =
WS_ThisGui := A_Index
Goto WS_RefreshWin
return

WS_CreateGUI:
ControlGet, WS_Control%WS_n%, HWND, , %Ctrl%, ahk_id %window%
Gui, %WS_n%:+AlwaysOnTop +ToolWindow +LabelAllGui +LastFound
Gui, %WS_n%:Show, X%WS_MouseX% Y%WS_MouseY% W%WS_cw% H%WS_ch%, %ActiveTitle% - %WS_n%
WS_GuiHWND%WS_n% := WinActive("A")
WS_Parent%WS_n% := DllCall("SetParent", "UInt", WS_Control%WS_n%, "UInt", WS_GuiHWND%WS_n%)
WinHide, ahk_id %Window%
WS_Window%WS_n% := Window
WinMove, % "ahk_id " WS_Control%WS_n%, , WS_OffsetX%WS_n%, WS_OffsetY%WS_n%
WS_MoveGUI = 1
WS_StopMove = 0
Hotkey, LButton, WS_ClickOff, on
KDE_WinX1 := WS_MouseX, KDE_WinY1 := WS_MouseY, KDE_WinW := WS_cw, KDE_WinH := WS_ch, KDE_X1 := WS_MouseX + WS_cw / 2, KDE_Y1 := WS_MouseY + WS_ch / 2, KDE_ID := WS_GuiHWND%WS_n%
;Goto KDE_Move
Return

WS_ClickOff:
WS_StopMove = 1
Hotkey, LButton, off
Return

AllGuiClose:
DllCall("SetParent", "UInt", WS_Control%A_Gui%, "UInt", WS_Parent%A_Gui%)
Gui, %A_Gui%:Destroy
WS_Control%A_Gui% =

If WinExist("ahk_id " . WS_Window%A_Gui%)
{
   WS_ThisGui := A_Gui
   Gosub WS_RefreshWin
}
Return

WS_RefreshWin:
WinGet, Maxed, MinMax, % "ahk_id " . WS_Window%WS_ThisGui%
If Maxed
{
   WinRestore, % "ahk_id " . WS_Window%WS_ThisGui%
   WinMaximize, % "ahk_id " . WS_Window%WS_ThisGui%
} Else {
   WinMaximize, % "ahk_id " . WS_Window%WS_ThisGui%
   WinRestore, % "ahk_id " . WS_Window%WS_ThisGui%
}
WinShow, % "ahk_id " . WS_Window%WS_ThisGui%
WinActivate, % "ahk_id " . WS_Window%WS_ThisGui%
Return

;========================================KDE Windowing============================================================

!+LButton::
MouseGetPos, KDE_X1, KDE_Y1, KDE_ID
Loop %WS_n%
   If (KDE_ID = WS_GuiHWND%WS_n%)
   {
      WS_MoveGUI = 1
      WS_StopMove = 0
      WinGetPos, KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDE_ID%
     ; Hotkey, LButton, WS_ClickOff, on
      ;Goto KDE_Move
   }
WinGet, KDE_Win, MinMax, ahk_id %KDE_ID%
If KDE_Win
{
   WinRestore ahk_id %KDE_ID%
   WinGetPos, KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDE_ID%
   KDE_WinX1 := KDE_X1 - KDE_WinW / 2, KDE_WinY1 := KDE_Y1 - KDE_WinH / 2
} Else

   WinGetPos, KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDE_ID%
   ;Goto KDE_Move

Return

KDE_Move:
Loop
{
   GetKeyState, KDE_Button, LButton, P
   MouseGetPos, KDE_X2, KDE_Y2
   KDE_WinX2 := (KDE_WinX1 + KDE_X2 - KDE_X1)
   KDE_WinY2 := (KDE_WinY1 + KDE_Y2 - KDE_Y1)
   If (Abs(KDE_WinX2) < 20)
      KDE_WinX2 := 0
   If (Abs(KDE_WinY2) < 20)
      KDE_WinY2 := -1
   If (Abs(KDE_WinX2 + KDE_WinW - A_ScreenWidth) < 20)
      KDE_WinX2 := A_ScreenWidth - KDE_WinW
   If (Abs(KDE_WinY2 + KDE_WinH - A_ScreenHeight) < 20)
      KDE_WinY2 := A_ScreenHeight - KDE_WinH
   WinMove, ahk_id %KDE_ID%, , %KDE_WinX2%, %KDE_WinY2%
   If WS_MoveGUI
      If WS_StopMove
         Break
      Else
         Continue
   If (KDE_WinY2 = A_ScreenHeight - KDE_WinH)
      WinSet, AlwaysOnTop, ON, ahk_id %KDE_ID%
   Else
      WinSet, AlwaysOnTop, OFF, ahk_id %KDE_ID%
   If (KDE_Button = "U")
      Break
   If (KDE_Y2 < 20)
   {
      WinMaximize, ahk_id %KDE_ID%
      Break
   } Else If (A_ScreenHeight - KDE_Y2 < 20) {
      WinMinimize, ahk_id %KDE_ID%
      Break
   } Else If (KDE_X2 < 20) {
      WinMaximize, ahk_id %KDE_ID%
      WinMove, ahk_id %KDE_ID%, , 0, 0, A_ScreenWidth / 2, A_ScreenHeight - CommandBarHeight
      Break
   } Else If (A_ScreenWidth - KDE_X2 < 20) {
      WinMaximize, ahk_id %KDE_ID%
      WinMove, ahk_id %KDE_ID%, , A_ScreenWidth / 2, 0, A_ScreenWidth / 2, A_ScreenHeight - CommandBarHeight
      Break
   }
}
WS_MoveGUI = 0
Return

WS_AdjustGUI:
Loop
{
   GetKeyState, KDE_Button, RButton, P
   If KDE_Button = U
      Break
   MouseGetPos, KDE_X2, KDE_Y2
   If (WS_OffsetX%WS_ThisGui% + KDE_X2 - KDE_X1 > 0)
      WS_OffsetX%WS_ThisGui% = 0
   Else If (WS_OffsetX%WS_ThisGui% + KDE_X2 - KDE_X1 < KDE_WinW - KDE_CtrlW)
      WS_OffsetX%WS_ThisGui% :=  KDE_WinW - KDE_CtrlW
   Else
      WS_OffsetX%WS_ThisGui% := WS_OffsetX%WS_ThisGui% + KDE_X2 - KDE_X1
   If (WS_OffsetY%WS_ThisGui% + KDE_Y2 - KDE_Y1 > 0)
      WS_OffsetY%WS_ThisGui% = 0
   Else If (WS_OffsetY%WS_ThisGui% + KDE_Y2 - KDE_Y1 < KDE_WinH - KDE_CtrlH)
      WS_OffsetY%WS_ThisGui% := KDE_WinH - KDE_CtrlH
   Else
      WS_OffsetY%WS_ThisGui% := WS_OffsetY%WS_ThisGui% + KDE_Y2 - KDE_Y1
   WinMove, % "ahk_id " WS_Control%WS_ThisGui%, , WS_OffsetX%WS_ThisGui%, WS_OffsetY%WS_ThisGui%
   KDE_X1 := KDE_X2, KDE_Y1 := KDE_Y2
}
Return

!+RButton::
MouseGetPos, KDE_X1, KDE_Y1, KDE_ID
Loop %WS_n%
   If (KDE_ID = WS_GuiHWND%A_Index%)
   {
      WS_ThisGui := A_Index
      WinGetPos, , , KDE_WinW, KDE_WinH, % "ahk_id " . WS_GuiHWND%WS_ThisGui%
      ControlGetPos, , , KDE_CtrlW, KDE_CtrlH, , % "ahk_id " . WS_Control%WS_ThisGui%
      If (Abs(KDE_WinW - KDE_CtrlW) < 20) and (Abs(KDE_CtrlH = KDE_WinH) < 30)
         Soundplay, %A_WinDir%\Media\Windows Ding.wav
      Else
         Gosub WS_AdjustGUI
      Return
   }
WinGet, KDE_Win, MinMax, ahk_id %KDE_ID%
WinGetPos, KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDE_ID%
If KDE_Win and (KDE_WinW > A_ScreenWidth) and (KDE_WinH > A_ScreenHeight - CommandBarHeight)
{
   KDE_WinH := A_ScreenHeight - CommandBarHeight, KDE_WinW := A_ScreenWidth
   WinMove, ahk_id %KDE_ID%, , 0, 0, KDE_WinW, KDE_WinH
}
If (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
   KDE_WinLeft := 1
Else
   KDE_WinLeft := -1
If (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
   KDE_WinUp := 1
Else
   KDE_WinUp := -1
Loop
{
   GetKeyState, KDE_Button, RButton, P
   If KDE_Button = U
      Break
   MouseGetPos, KDE_X2, KDE_Y2
   WinGetPos, KDE_WinX1, KDE_WinY1, KDE_WinW, KDE_WinH, ahk_id %KDE_ID%
   KDE_X2 -= KDE_X1
   KDE_Y2 -= KDE_Y1
   If (KDE_WinW - KDE_WinLeft * KDE_X2 > A_ScreenWidth + 10) or (KDE_WinH - KDE_WinUp * KDE_Y2 > A_ScreenHeight)
   {
      WinGet, KDE_Win, MinMax, ahk_id %KDE_ID%
      If KDE_Win
         WinRestore, ahk_id %KDE_ID%
      WinMaximize, ahk_id %KDE_ID%
      break
   }
   WinMove, ahk_id %KDE_ID%, , KDE_WinX1 + (KDE_WinLeft + 1) / 2 * KDE_X2, KDE_WinY1 + (KDE_WinUp + 1) / 2 * KDE_Y2, KDE_WinW - KDE_WinLeft * KDE_X2, KDE_WinH - KDE_WinUp * KDE_Y2
   KDE_X1 := (KDE_X2 + KDE_X1)
   KDE_Y1 := (KDE_Y2 + KDE_Y1)
}
return