; Don't consider it hovering if the mouse was clicked.
; However, clicking and then moving a small amount will still trigger hover.
~RButton::
    CoordMode, Mouse, Screen
    MouseGetPos, lastx, lasty
return

hovercheck:
  CoordMode, Mouse, Screen
    MouseGetPos, x, y
    
    if (x != lastx or  y != lasty)
    {
        SetTimer, hovering, % -hover_delay
;tooltip % x "-" lastx
        lastx := x
        lasty := y

        if (remove_ttip_on_move)
        {
            ToolTip
            remove_ttip_on_move := false
        }
    }
return

hovering:
    if (hover_no_buttons && (GetKeyState("LButton") or GetKeyState("RButton") or GetKeyState("Shift") or GetKeyState("CapsLock")))
        return
    if (WinExist("ahk_group ExistDisableHover"))
        return
    if (WinActive("ahk_group ActiveDisableHover"))
        return

CoordMode, Mouse, Screen
    MouseGetPos,x,y,,outCtl
    isF:=IsFullscreen("A",false,false)
    if !isF
   {
    yBottom := A_ScreenHeight - y
    if (yBottom <= 30  &&  x>50)
    WinActivate,ahk_class Shell_TrayWnd
    }
    ; hover over taskbar button to activate window:
    if (hover_task_buttons)
    {   ; hovering over taskbar button.
        if (GetMouseTaskButton(win))
        {
            if (win)
            {     ; 以下代码对win7无效  在win7下变量win总是0
                if (hover_task_min_info)
                {
                    WinGet, min_max, MinMax, ahk_id %win%

                    if (min_max = -1)
                    {
                        WinGetTitle, ti, ahk_id %win%
                        ToolTip, %ti% (最小化)
                        remove_ttip_on_move := true
                        return
                    }
                }
                if (hover_keep_zorder)
                {
                    JustActivate(win)
                    return
                }
                WinActivate, ahk_id %win%
              ; 以上代码对win7无效
            }
            ; May be a group button ("Group similar taskbar buttons")
            else
                {
                Click
                sleep,50
                MouseGetPos, lastx, lasty
                 }
            return
        }
        else if (hover_task_group && WinActive("ahk_class Shell_TrayWnd"))
        {   ; Check if we are hovering over a toolbar window,
            ; possibly a list of grouped buttons/windows.
            MouseGetPos,,, win, ctl, 2
            ctl_parent := DllCall("GetParent", "uint", ctl) ; get control parent
            WinGetClass, ctl, ahk_id %ctl%                  ; get control class
            WinGetClass, ctl_parent, ahk_id %ctl_parent%    ; get parent class
            WinGetClass, win, ahk_id %win%                  ; get window class
            if (win="BaseBar"                       ; probably a button group menu
                || ctl = "ToolbarWindow32"
                || ctl = "ReBarWindow32"
                || (win="Shell_TrayWnd"             ; taskbar
                 && ctl_parent="MSTaskSwWClass"))   ; task buttons
                {
Click
MouseGetPos, lastx, lasty
}
            ; (The win="BaseBar" check excludes the system notification area.)
            return
        }
    }
      ; hover over start button to open start menu:
    if (hover_start_button && !WinActive("ahk_class DV2ControlHost")) ; Start Menu
    {
        MouseGetPos,,, win, ctl
        WinGetTitle, ti, ahk_id %win%
        WinGetClass, cl, ahk_id %win%
        if (Vista7 && (cl = "Button" && ti = "开始"))
            or (cl = "Shell_TrayWnd" && ctl = "Button1")
        {
            Click
            return
        }
    }

    ;SciTe标签自动点击
    if (outCtl = "SysTabControl321")
    {
       Click
       return
    }
    ;WPS 2010 顶部标签自动点击
    ;if (outCtl = "TKsoDocTabControl.UnicodeClass1")
    ;{
    ;   Click
    ;   return
    ;}

    ;WPS 2010 表格工作表标签自动点击
    ;if (outCtl = "TFooterTabCtrl.UnicodeClass1")
    ;{
    ;   Click
    ;   return
    ;}


    ;WPS 2012标签自动点击
    ;if (outCtl = "QWidget3" or outCtl = "QWidget6" or outCtl = "QWidget9" or outCtl = "QWidget12")
    ;{
    ;   Click
    ;   return
   ; }


; hover over minimize, maximize or help buttons on titlebar:
		if (hover_min_max)
		{
		MouseGetPos, x, y, win, ctl, 2
		SendMessage, 0x84,, (x & 0xFFFF) | (y & 0xFFFF) << 16,, % "ahk_id " (ctl ? ctl : win)
        ;ErrorLevel（2:标题栏、3:系统菜单、8:最小化按钮、9:最大化按钮、20:关闭按钮、21:帮助）
			if ErrorLevel in 8,9  ; min,max (titlebar)
			{
			Click
			return
			}
		}
; hover over any window to focus:
    if (hover_any_window)
    {
        ifWinExist, ahk_id %win% ahk_class Shell_TrayWnd
            return  ; don't activate the taskbar
        MouseGetPos,,, win
        if (!WinActive("ahk_id" win)) {
            if (hover_keep_zorder)
               {
                JustActivate(win)
                ;MsgBox,0
                }
            else
            {
                WinGet, XWN_WinStyle, Style, ahk_id %win%
                ;ToolTip %win% - %XWN_WinStyle%
			    If ( (XWN_WinStyle & 0x80000000) and !(XWN_WinStyle & 0x4C0000) )
				Return
                WinActivate, ahk_id %win%
               ;MsgBox,1
            }

        }
   }

    ;Chrome浏览器标签页自动点击激活
    WinGetTitle,browsertitle,ahk_id %win%
    chrometitle = Chromium
    operatitle = Opera
    wpsettitle = WPS 表格
    IfInString,browsertitle,%chrometitle%
    {
        WinGetPos , k_WindowX,k_WindowY,k_WindowWidth, k_WindowHeight, ahk_id %win%
        k_WindowY += 40
        k_WindowWidth1 :=k_WindowX+k_WindowWidth-55
        if (y<=k_WindowY and x<k_WindowWidth1)
        Click
        return
    }
    IfInString,browsertitle,%operatitle%
    {
        WinGetPos , k_WindowX,k_WindowY,k_WindowWidth, k_WindowHeight, ahk_id %win%
        k_WindowY += 49
        k_WindowWidth1 :=k_WindowX+k_WindowWidth-55
        if (y<=k_WindowY and x<k_WindowWidth1)
        Click
         return
    }
    IfInString,browsertitle,%wpsettitle%
    {
    ;WPS 2013  表格工作表底部标签自动点击
    if (outCtl = "QWidget2")
    {
      Click
      return
   }
    }

   ;WPS 9.1 2013皮肤 工具栏显示时 标签自动点击
    if WinActive("ahk_class OpusApp")||WinActive("ahk_class XLMAIN")
   {
    WinGetPos , k_WindowX,k_WindowY,k_WindowWidth, k_WindowHeight, ahk_id %win%
    if (k_WindowWidth=A_ScreenWidth)
    {
    k_WindowY1 :=k_WindowY+23
    k_WindowWidth -=55
    k_WindowY2 :=k_WindowY+95
    k_WindowY3 :=k_WindowY+120
    if (y<=k_WindowY1 and x<k_WindowWidth) | (y>=k_WindowY2 and y<=k_WindowY3 and x<k_WindowWidth)
    {
        Click
        return
     }
    }
    else
    {
    k_WindowY1 :=k_WindowY+55
    k_WindowWidth1 :=k_WindowX+k_WindowWidth-50
    k_WindowY2 :=k_WindowY+123
    k_WindowY3 :=k_WindowY+150
    if (y<=k_WindowY1 and x<k_WindowWidth1) | (y>=k_WindowY2 and y<=k_WindowY3 and x<k_WindowWidth1)
    {
        Click
        return
    }
    }
    }
return


JustActivate(hwnd)
{
    if (WinActive("ahk_id " hwnd))
        return

    ; Get the window which hwnd is positioned after, so hwnd's position
    ; in the z-order can be restored after activation.
    hwnd_prev := GetPrevWindow(hwnd)
    ; DllCall("GetWindow","uint",hwnd,"uint",3) would be simpler,
    ; but doesn't work right since it usually gets an invisible window
    ; which moves when we activate hwnd.

    ; Repositioning a window in the z-order sometimes sets AlwaysOnTop.
    WinGet, OldExStyle, ExStyle, ahk_id %hwnd%

    ;WinActivate, ahk_id %hwnd%  ; -- best to use SetWinDelay,-1 if using WinActivate.
    DllCall("SetForegroundWindow", "uint", hwnd)
    DllCall("SetWindowPos", "uint", hwnd, "uint", hwnd_prev
        , "int", 0, "int", 0, "int", 0, "int", 0
        , "uint", 0x13)  ; NOSIZE|NOMOVE|NOACTIVATE (0x1|0x2|0x10)

    ; Note NOACTIVATE above: if this is not specified, SetWindowPos activates
    ; the window, bringing it forward (effectively ignoring hwnd_prev...)

    ; Check if AlwaysOnTop status changed.
    WinGet, ExStyle, ExStyle, ahk_id %hwnd%
    if (OldExStyle ^ ExStyle) & 0x8
        WinSet, AlwaysOnTop, Toggle
}

; Like GetWindow(hwnd, GW_HWNDPREV), but ignores invisible windows.
GetPrevWindow(hwnd)
{
    global GetPrevWindow_RetVal

    static cb_EnumChildProc
    if (!cb_EnumChildProc)
        cb_EnumChildProc := RegisterCallback("GetPrevWindow_EnumChildProc","F")

    ; Set default in case enumeration fails.
    GetPrevWindow_RetVal := DllCall("GetWindow", "uint", hwnd, "uint", 3)

    ; Enumerate all siblings of hwnd.
    hwnd_parent := DllCall("GetParent", "uint", hwnd)
    DllCall("EnumChildWindows", "uint", hwnd_parent, "uint", cb_EnumChildProc, "uint", hwnd)

    ; Return the last visible window before hwnd.
    return GetPrevWindow_RetVal
}

GetPrevWindow_EnumChildProc(test_hwnd, hwnd)
{
    global GetPrevWindow_RetVal
    ; Continue until hwnd is enumerated.
    if (test_hwnd = hwnd)
        return false
    ; Remember the last visible window before hwnd.
    if (DllCall("IsWindowVisible", "uint", test_hwnd))
        GetPrevWindow_RetVal := test_hwnd
    return true
}


; Gets the index+1 of the taskbar button which the mouse is hovering over.
; Returns an empty string if the mouse is not over the taskbar's task toolbar.
;
; Some code and inspiration from Sean's TaskButton.ahk
GetMouseTaskButton(ByRef hwnd)
{
    MouseGetPos, x, y, win, ctl, 2
    ; Check if hovering over taskbar.
    WinGetClass, cl, ahk_id %win%
    if (cl != "Shell_TrayWnd")
        return
    ; Check if hovering over a Toolbar.
    WinGetClass, cl, ahk_id %ctl%

    ;for Win7
    if (cl = "MSTaskListWClass"  ; Windows 7: the methods used below won't work.
        || A_PtrSize=8  ; Script not compatible with 64-bit AutoHotkey.exe.
        || DllCall("IsWow64Process", "Uint", DllCall("GetCurrentProcess")
            , "intP", iswow64) && iswow64)  ; OS/taskbar is 64-bit - not compatible.
    {
        hwnd := 0
        return 1
    }
    ;for XP
    if (cl != "ToolbarWindow32")
      return
    ;Check if hovering over task-switching buttons (specific toolbar).
    hParent := DllCall("GetParent", "Uint", ctl)
    WinGetClass, cl, ahk_id %hParent%
    if (cl != "MSTaskSwWClass")
      return


    WinGet, pidTaskbar, PID, ahk_class Shell_TrayWnd

    hProc := DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
    pRB := DllCall("VirtualAllocEx", "Uint", hProc
        , "Uint", 0, "Uint", 20, "Uint", 0x1000, "Uint", 0x4)

    VarSetCapacity(pt, 8, 0)
    NumPut(x, pt, 0, "int")
    NumPut(y, pt, 4, "int")

    ; Convert screen coords to toolbar-client-area coords.
    DllCall("ScreenToClient", "uint", ctl, "uint", &pt)

    ; Write POINT into explorer.exe.
    DllCall("WriteProcessMemory", "uint", hProc, "uint", pRB+0, "uint", &pt, "uint", 8, "uint", 0)

;     SendMessage, 0x447,,,, ahk_id %ctl%  ; TB_GETHOTITEM
    SendMessage, 0x445, 0, pRB,, ahk_id %ctl%  ; TB_HITTEST
    btn_index := ErrorLevel
    ; Convert btn_index to a signed int, since result may be -1 if no 'hot' item.
    if btn_index > 0x7FFFFFFF
        btn_index := -(~btn_index) - 1


    if (btn_index > -1)
    {
        ; Get button info.
        SendMessage, 0x417, btn_index, pRB,, ahk_id %ctl%   ; TB_GETBUTTON

        VarSetCapacity(btn, 20)
        DllCall("ReadProcessMemory", "Uint", hProc
            , "Uint", pRB, "Uint", &btn, "Uint", 20, "Uint", 0)

        state := NumGet(btn, 8, "UChar")  ; fsState
        pdata := NumGet(btn, 12, "UInt")  ; dwData

        ret := DllCall("ReadProcessMemory", "Uint", hProc
            , "Uint", pdata, "UintP", hwnd, "Uint", 4, "Uint", 0)
    } else
        hwnd = 0


    DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pRB, "Uint", 0, "Uint", 0x8000)
    DllCall("CloseHandle", "Uint", hProc)


    ; Negative values indicate seperator items. (abs(btn_index) is the index)
    return btn_index > -1 ? btn_index+1 : 0
}