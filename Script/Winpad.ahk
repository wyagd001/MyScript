; WindowPad:
;
;   Move and resize windows with Win+Numpad.
;     Win+Numpad1 = Fill bottom-left quarter of screen
;     Win+Numpad2 = Fill bottom half of screen
;     etc.
;
;   Move windows across monitors. For example:
;     Win+Numpad4 places the window on the left half of the screen.
;     Win+Numpad4 again moves it to the monitor to the right.
;
;   Quick monitor switch:
;     Win+Numpad5 places the window in the center of the screen.
;     Win+Numpad5 again moves the window to the next monitor.
;     (This works by monitor number, not necessarily left to right.)
;
;   QUICKER Monitor Switch:
;     Win+NumpadDot switches to the next monitor (1->2->3->1 etc.)
;     Win+NumpadDiv moves ALL windows to monitor 2.
;     Win+NumpadMult moves ALL windows to monitor 1.
;
;   Other shortcuts:
;     Win+Numpad0 toggles maximize.
;     Insert (or some other key) can be used in place of "Win".
;
; Credits:
;   Concept based on HiRes Screen Splitter by JOnGliko.
;   Written from scratch by Lexikos to support multiple monitors.
;   NumpadDot key functionality suggested by bobbo.
;
; Built with AutoHotkey v1.0.47.02
;
; HISTORY
;
; Version 1.14:
;   - Fixed modifier+EasyKey combos losing their native functions.
;
; Version 1.13:
;   - Applied bobbo's hack for moving maximized windows.
;
; Version 1.12:
;   - Added two methods to exclude windows from GatherWindows():
;       GatherExclude window group (exclude by title, class, etc.)
;       ProcessGatherExcludeList (exclude by process name)
;
; Version 1.11:
;   - Fixed compatiblity issue with screens that don't align at the top.
;
; Version 1.1:
;   - "Gather windows" hotkeys (NumpadDiv and NumpadMult)
;   - NumpadDot to move window to next monitor
;   - Added more EasyKey combos (for symmetry)
;   - Original functionality of EasyKey is retained (on key-release)
;   - SetWinDelay, -1 to reduce lag when making multiple moves (quickly)
;
; Version 1:
;   - intial release




; Comma-delimited list of processes to exclude.
;ProcessGatherExcludeList = sidebar.exe

; (ProcessGatherExcludeList excludes ALL windows belonging to those processes,
;  including windows you may not want to exclude, like the sidebar config window.)

/*
;ÒÆ³ýEasyKey
SendEasyKey:
    Send {Blind}{%EasyKey%}
    return
;ÒÆ³ýEasyKey
*/

; This is actually based on monitor number, so if your secondary is on the
; right, you may want to switch these around.
GatherWindowsLeft:
    GatherWindows(2)
    return
GatherWindowsRight:
    GatherWindows(1)
    return

; Hotkey handler.
DoMoveWindowInDirection:
    DoMoveWindowInDirection()
    return

DoMoveWindowInDirection()
{
    local dir, dir0, dir1, dir2, widthFactor, heightFactor
   
    ; Define constants.
    if (!Directions1) {
        dir = -1:+1,0:+1,+1:+1,-1:0,0:0,+1:0,-1:-1,0:-1,+1:-1
        StringSplit, Directions, dir, `,
    }

    gosub WP_SetLastFoundWindowByHotkey
   
    ; Determine which direction we want to go.
    if (!RegExMatch(A_ThisHotkey, "\d+", dir) or !Directions%dir%)
    {
        MsgBox Error: "%A_ThisHotkey%" was registered and I can't figure out which number it is!
        return
    }
    
    dir := Directions%dir%
    StringSplit, dir, dir, :
   
    ; Determine width/height factors.
    if (dir1 or dir2) { ; to a side
        widthFactor  := dir1 ? 0.5 : 1.0
        heightFactor := dir2 ? 0.5 : 1.0
    } else {            ; to center
        widthFactor  := CenterWidthFactor
        heightFactor := CenterHeightFactor
    }
   
    ; Move the window!
    MoveWindowInDirection(dir1, dir2, widthFactor, heightFactor)
   ;msgbox %dir1%`n%dir2%`n%widthFactor%`n%heightFactor%
}
return

WP_SetLastFoundWindowByHotkey:
    ; Set Last Found Window.
    if (InStr(A_ThisHotkey, Prefix_Other))
        WinPreviouslyActive()
    else
        WinExist("A")
return

; "Maximize"
DoMaximizeToggle:
    MaximizeToggle()
return
   
MaximizeToggle()
{
    gosub WP_SetLastFoundWindowByHotkey
    WinGet, state, MinMax
    if state
        WinRestore
    else
        WinMaximize
}


; Does the grunt work of the script.
MoveWindowInDirection(sideX, sideY, widthFactor, heightFactor, screenMoveOnly=false)
{
    WinGetPos, x, y, w, h
   
    ; Determine which monitor contains the center of the window.
    m := GetMonitorAt(x+w/2, y+h/2)
   
    ; Get work area of active monitor.
    gosub CalcMonitorStats
    ; Calculate possible new position for window.
    gosub CalcNewPosition

    ; If the window is already there,
    if (newx "," newy "," neww "," newh) = (x "," y "," w "," h)
    {   ; ..move to the next monitor along instead.
   
        if (sideX or sideY)
        {   ; Move in the direction of sideX or sideY.
            SysGet, monB, Monitor, %m% ; get bounds of entire monitor (vs. work area)
            x := (sideX=0) ? (x+w/2) : (sideX>0 ? monBRight : monBLeft) + sideX
            y := (sideY=0) ? (y+h/2) : (sideY>0 ? monBBottom : monBTop) + sideY
            newm := GetMonitorAt(x, y, m)
        }
        else
        {   ; Move to center (Numpad5)
            newm := m+1
            SysGet, mon, MonitorCount
            if (newm > mon)
                newm := 1
        }
   
        if (newm != m)
        {   m := newm
            ; Move to opposite side of monitor (left of a monitor is another monitor's right edge)
            sideX *= -1
            sideY *= -1
            ; Get new monitor's work area.
            gosub CalcMonitorStats
        }
        ; Calculate new position for window.
        gosub CalcNewPosition
    }

    ; Restore before resizing...
    WinGet, state, MinMax
    if state
        WinRestore

    ; Finally, move the window!
    SetWinDelay, -1
    WinMove,,, newx, newy, neww, newh
   
    return

CalcNewPosition:
    ; Calculate new size.
    if (IsResizable()) {
        neww := Round(monWidth * widthFactor)
        newh := Round(monHeight * heightFactor)
    } else {
        neww := w
        newh := h
    }
    ; Calculate new position.
    newx := Round(monLeft + (sideX+1) * (monWidth  - neww)/2)
    newy := Round(monTop  + (sideY+1) * (monHeight - newh)/2)
    return

CalcMonitorStats:
    ; Get work area (excludes taskbar-reserved space.)
    SysGet, mon, MonitorWorkArea, %m%
    monWidth  := monRight - monLeft
    monHeight := monBottom - monTop
    return
}

; Get the index of the monitor containing the specified x and y co-ordinates.
GetMonitorAt(x, y, default=1)
{
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

IsResizable()
{
    WinGet, Style, Style
    return (Style & 0x40000) ; WS_SIZEBOX
}

; Note: This may not work properly with always-on-top windows. (Needs testing)
WinPreviouslyActive()
{
   DetectHiddenWindows Off
    active := WinActive("A")
    WinGet, win, List

    ; Find the active window.
    ; (Might not be win1 if there are always-on-top windows?)
    Loop, %win%
        if (win%A_Index% = active)
        {
            if (A_Index < win)
                N := A_Index+1
           
            ; hack for PSPad: +1 seems to get the document (child!) window, so do +2
            ifWinActive, ahk_class TfPSPad
                N += 1
           
            break
        }
      DetectHiddenWindows On
    ; Use WinExist to set Last Found Window (for consistency with WinActive())
    return WinExist("ahk_id " . win%N%)
}


;
; Switch without moving/resizing (relative to screen)
;
MoveWindowToNextScreen:
    gosub WP_SetLastFoundWindowByHotkey
    WinGet, MinMax_State, MinMax
    if MinMax_State = 1
    {   ; Maximized windows don't move correctly on XP
        ; (and possibly other versions of Windows)
        WinRestore
        MoveWindowToNextScreen()
        WinMaximize
    }
    else
        MoveWindowToNextScreen()
return

MoveWindowToNextScreen()
{
    WinGetPos, x, y, w, h
   
    ; Determine which monitor contains the center of the window.
    ms := GetMonitorAt(x+w/2, y+h/2)
   
    ; Determine which monitor to move to.
    md := ms+1
    SysGet, mon, MonitorCount
    if (md > mon)
        md := 1
   
    ; This may happen if someone tries it with only one screen. :P
    if (md = ms)
        return

    ; Get source and destination work areas (excludes taskbar-reserved space.)
    SysGet, ms, MonitorWorkArea, %ms%
    SysGet, md, MonitorWorkArea, %md%
    msw := msRight - msLeft, msh := msBottom - msTop
    mdw := mdRight - mdLeft, mdh := mdBottom - mdTop
   
    ; Calculate new size.
    if (IsResizable()) {
        w *= (mdw/msw)
        h *= (mdh/msh)
    }
    SetWinDelay, -1
    ; Move window, using resolution difference to scale co-ordinates.
    WinMove,,, mdLeft + (x-msLeft)*(mdw/msw), mdTop + (y-msTop)*(mdh/msh), w, h
}


;
; "Gather" windows on a specific screen.
;

GatherWindows(md=1)
{
    ; Copy bounds of all monitors to an array.
    SysGet, mc, MonitorCount
    if mc=1
       return
    global ProcessGatherExcludeList
   
    SetWinDelay, -1 ; Makes a BIG difference to perceived performance.
    DetectHiddenWindows Off
    ; List all visible windows.
    WinGet, win, List
   
    Loop, %mc%
        SysGet, mon%A_Index%, MonitorWorkArea, %A_Index%
   
    ; Destination monitor
    mdx := mon%md%Left
    mdy := mon%md%Top
    mdw := mon%md%Right - mdx
    mdh := mon%md%Bottom - mdy
   
    Loop, %win%
    {
        ; If this window matches the GatherExclude group, don't touch it.
        if (WinExist("ahk_group GatherExclude ahk_id " . win%A_Index%))
            continue
       
        ; Set Last Found Window.
        if (!WinExist("ahk_id " . win%A_Index%))
            continue

        WinGet, procname, ProcessName
        ; Check process (program) exclusion list.
        if procname in %ProcessGatherExcludeList%
            continue
       
        WinGetPos, x, y, w, h
       
        ; Determine which monitor this window is on.
        xc := x+w/2, yc := y+h/2
        ms := 1
        Loop, %mc%
            if (xc >= mon%A_Index%Left && xc <= mon%A_Index%Right
                && yc >= mon%A_Index%Top && yc <= mon%A_Index%Bottom)
            {
                ms := A_Index
                break
            }
        ; If already on destination monitor, skip this window.
        if (ms = md)
            continue
       
        ; Source monitor
        msx := mon%ms%Left
        msy := mon%ms%Top
        msw := mon%ms%Right - msx
        msh := mon%ms%Bottom - msy
       
        ; If the window is resizable, scale it by the monitors' resolution difference.
        if (IsResizable()) {
            w *= (mdw/msw)
            h *= (mdh/msh)
        }
   
        WinGet, state, MinMax
        if state = 1
            WinRestore
       
        ; Move window, using resolution difference to scale co-ordinates.
        WinMove,,, mdx + (x-msx)*(mdw/msw), mdy + (y-msy)*(mdh/msh), w, h

        if state = 1
            WinMaximize
    }
DetectHiddenWindows On
}