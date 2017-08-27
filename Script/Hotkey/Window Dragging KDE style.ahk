; 原脚本已被修改
; MoveInactiveWin.ahk
; http://www.1hoursoftware.com
; Easy Window Dragging -- KDE style (requires XP/2k/NT) -- by Jonny
; http://www.autohotkey.com/forum/topic2062.html 和  帮助文件里的脚本实例中有收录

;SetWinDelay,0
;SetBatchLines,-1
;CoordMode,Mouse,Screen

;#ifWinNotActive,Warcraft III
;!LButton::
Alt和左键移动窗口:
;ifWinActive,ahk_class Valve001
;{
;    Send !{LButton}
;return
;}
MouseGetPos,oldmx,oldmy,mwin,mctrl
WinGet, window_minmax, MinMax, ahk_id %mwin%
; Return if the window is maximized or minimized
if window_minmax <> 0
return
ifWinActive,ahk_class RiotWindowClass
{
    Send !{LButton}
return
}
Loop
{
  GetKeyState,lbutton,LButton,P
  GetKeyState,alt,Alt,P
  If (lbutton="U" Or alt="U")
    Break
  MouseGetPos,mx,my
  WinGetPos,wx,wy,ww,wh,ahk_id %mwin%
  wx:=wx+mx-oldmx
  wy:=wy+my-oldmy
  WinMove,ahk_id %mwin%,,%wx%,%wy%
  oldmx:=mx
  oldmy:=my
}
Return
;#ifWinNotActive

;#ifWinNotActive,Warcraft III
;!RButton::
Alt和右键窗口大小:
;ifWinActive,ahk_class Valve001
;{
;    Send !{RButton}
;return
;}
CoordMode,Mouse,Screen
MouseGetPos,KDE_X1,KDE_Y1,KDE_id
WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
If KDE_Win
    return
; Get the initial window position and size.
WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
; Define the window region the mouse is currently in.
; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
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
    GetKeyState,KDE_Button,RButton,P ; Break if button has been released.
    If KDE_Button = U
        break
    MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
    ; Get the current window position and size.
    WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
    KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
    KDE_Y2 -= KDE_Y1
    ; Then, act according to the defined region.
    WinMove,ahk_id %KDE_id%,, KDE_WinX1 + (KDE_WinLeft+1)/2*KDE_X2  ; X of resized window
                            , KDE_WinY1 +   (KDE_WinUp+1)/2*KDE_Y2  ; Y of resized window
                            , KDE_WinW  -     KDE_WinLeft  *KDE_X2  ; W of resized window
                            , KDE_WinH  -       KDE_WinUp  *KDE_Y2  ; H of resized window
    KDE_X1 := (KDE_X2 + KDE_X1) ; Reset the initial position for the next iteration.
    KDE_Y1 := (KDE_Y2 + KDE_Y1)
}
return
;#ifWinNotActive

;!^LButton::
控件位置:
; Get the initial mouse position and Control id relative to the Window
CoordMode,Mouse,Relative
MouseGetPos,KDE_X1,KDE_Y1,KDE_id,KDE_Ctrl
; Get the initial Control position.
ControlGetPos,KDE_WinX1,KDE_WinY1,,,%KDE_Ctrl%,ahk_id %KDE_id%
Loop
{
    GetKeyState,KDE_Button,LButton,P ; Break if button has been released.
    If KDE_Button = U
        break
    MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
    KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
    KDE_Y2 -= KDE_Y1
    KDE_WinX2 := (KDE_WinX1 + KDE_X2) ; Apply this offset to the Control position.
    KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
    ControlMove,%KDE_Ctrl%,%KDE_WinX2%,%KDE_WinY2%,,,ahk_id %KDE_id% ; Move the Control to the new position.
}
return

;!^RButton::
控件大小:
; Get the initial mouse position and Control id relative to the Window
CoordMode,Mouse,Relative
MouseGetPos,KDE_X1,KDE_Y1,KDE_id,KDE_Ctrl
; Get the initial Control position and size.
ControlGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,%KDE_Ctrl%,ahk_id %KDE_id%
; Define the Control region the mouse is currently in.
; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
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
    GetKeyState,KDE_Button,RButton,P ; Break if button has been released.
    If KDE_Button = U
        break
    MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
    ; Get the current Control position and size.
    ControlGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,%KDE_Ctrl%,ahk_id %KDE_id%
    KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
    KDE_Y2 -= KDE_Y1
    ; Then, act according to the defined region.
    ControlMove,%KDE_Ctrl%,KDE_WinX1 + (KDE_WinLeft+1)/2*KDE_X2  ; X of resized Control
                          ,KDE_WinY1 +   (KDE_WinUp+1)/2*KDE_Y2  ; Y of resized Control
                          ,KDE_WinW  -     KDE_WinLeft  *KDE_X2  ; W of resized Control
                          ,KDE_WinH  -       KDE_WinUp  *KDE_Y2  ; H of resized Control
                          ,ahk_id %KDE_id%
    KDE_X1 := (KDE_X2 + KDE_X1) ; Reset the initial position for the next iteration.
    KDE_Y1 := (KDE_Y2 + KDE_Y1)
}
return