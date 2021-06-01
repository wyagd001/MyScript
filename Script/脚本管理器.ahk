; 脚本启动时会打开运行"脚本管理器"目录中文件名开头不是"!"的所有脚本
tsk_openAll:
BackUp_WorkingDir:=A_WorkingDir
SetWorkingDir %ScriptManager_Path%
Loop, %scriptCount%
{
	thisScript := scripts%A_index%0
	If scripts%A_index%1 = 0    ;没打开
	{
		ifinstring, thisScript, !
			continue
		IfWinNotExist %thisScript% - AutoHotkey    ; 没有打开
			Run,"%A_AhkPath%" "%ScriptManager_Path%\%thisScript%"

		scripts%A_index%1 = 1
		StringRePlace menuName, thisScript, .ahk
		Menu scripts_unclose, add, %menuName%, tsk_close
		Menu scripts_unopen, delete, %menuName%
	}
}
SetWorkingDir,%BackUp_WorkingDir%
Return

tsk_open:
BackUp_WorkingDir:=A_WorkingDir
SetWorkingDir %ScriptManager_Path%
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If thisScript = %A_thismenuitem%.ahk  ; match found.
    {
        IfWinNotExist %thisScript% - AutoHotkey    ; 没有打开
            Run,"%A_AhkPath%" "%ScriptManager_Path%\%thisScript%"

        scripts%A_index%1 := 1

        Menu scripts_unclose, add, %A_thismenuitem%, tsk_close
        Menu scripts_unopen, delete, %A_thismenuitem%
        Break
    }
}
SetWorkingDir,%BackUp_WorkingDir%
Return

tsk_close:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If thisScript = %A_thismenuitem%.ahk  ; match found.
    {
        WinClose %thisScript% - AutoHotkey
        scripts%A_index%1 := 0

        Menu scripts_unopen, add, %A_thismenuitem%, tsk_open
        Menu scripts_unclose, delete, %A_thismenuitem%
        Break
    }
}
Return

tsk_closeAll:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If scripts%A_index%1 = 1  ; 已打开
    {
        WinClose %thisScript% - AutoHotkey
        scripts%A_index%1 = 0

        StringRePlace menuName, thisScript, .ahk
        Menu scripts_unopen, add, %menuName%, tsk_open
        Menu scripts_unclose, delete, %menuName%
    }
}
Return

tsk_edit:
Run, notepad %ScriptManager_Path%\%A_thismenuitem%.ahk
Return

tsk_reload:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If thisScript = %A_thismenuitem%.ahk  ; match found.
    {
        WinClose %thisScript% - AutoHotkey
        Run %ScriptManager_Path%\%thisScript%
        Break
    }
}
Return

tsk_UpdateMenu:
Loop, %scriptCount%
{
  thisScript := scripts%A_index%0
  If scripts%A_index%1 = 1  ; 已打开
  {
    if WinExist(thisScript " - AutoHotkey")
      continue
    else
    {
      scripts%A_index%1 = 0

      StringRePlace menuName, thisScript, .ahk
      Menu scripts_unopen, add, %menuName%, tsk_open
      Menu scripts_unclose, delete, %menuName%
    }
  }
}


WinGet, id, List, ahk_class AutoHotkey
Loop, %id% {
  this_id := id%A_Index%
  WinGet, this_pid, PID, ahk_id %this_id%
  WinGetTitle, this_title, ahk_id %this_id%
  fPath := RegExReplace(this_title, " - AutoHotkey v[\d.]+$")
  if InStr(fPath, A_ScriptDir "\脚本管理器")
  {
    SplitPath, fPath, fName
    Loop, %scriptCount%
    {
      if (fName = scripts%A_index%0)
      {
        If scripts%A_index%1 = 0
        {
          scripts%A_index%1 = 1
          StringRePlace menuName, fName, .ahk
          Menu scripts_unclose, add, %menuName%, tsk_close
          Menu scripts_unopen, delete, %menuName%
        }
      }
    }
  }
}
return

AHK_NOTIFYICON(wParam, lParam)
{
  if (lParam = 0x204)
  {
    gosub tsk_UpdateMenu
    ;menu,tray,show
    ShowMenu(MenuGetHandle("Tray"), False, TrayMenuParams()*)
  }
  return
}

ShowMenu(hMenu, MenuLoop:=0, X:=0, Y:=0, Flags:=0) {            ; Ver 0.61 by SKAN on D39F/D39G
Local                                                           ;            @ tiny.cc/showmenu
  If (hMenu="WM_ENTERMENULOOP")
    Return True
  Fn := Func("ShowMenu").Bind("WM_ENTERMENULOOP"), n := MenuLoop=0 ? 0 : OnMessage(0x211,Fn,-1)
  DllCall("SetForegroundWindow","Ptr",A_ScriptHwnd)
  R := DllCall("TrackPopupMenu", "Ptr",hMenu, "Int",Flags, "Int",X, "Int",Y, "Int",0
             , "Ptr",A_ScriptHwnd, "Ptr",0, "UInt"),                     OnMessage(0x211,Fn, 0)
  DllCall("PostMessage", "Ptr",A_ScriptHwnd, "Int",0, "Ptr",0, "Ptr",0)
Return R
}

TrayMenuParams() {      ; Original function is TaskbarEdge() by SKAN @ tiny.cc/taskbaredge
Local    ; This modfied version to be passed as parameter to ShowMenu() @ tiny.cc/showmenu
  VarSetCapacity(var,84,0), v:=&var,   DllCall("GetCursorPos","Ptr",v+76)
  X:=NumGet(v+76,"Int"), Y:=NumGet(v+80,"Int"),  NumPut(40,v+0,"Int64")
  hMonitor := DllCall("MonitorFromPoint", "Int64",NumGet(v+76,"Int64"), "Int",0, "Ptr")
  DllCall("GetMonitorInfo", "Ptr",hMonitor, "Ptr",v)
  DllCall("GetWindowRect", "Ptr",WinExist("ahk_class Shell_SecondaryTrayWnd"), "Ptr",v+68)
  DllCall("SubtractRect", "Ptr",v+52, "Ptr",v+4, "Ptr",v+68)
  DllCall("GetWindowRect", "Ptr",WinExist("ahk_class Shell_TrayWnd"), "Ptr",v+36)
  DllCall("SubtractRect", "Ptr",v+20, "Ptr",v+52, "Ptr",v+36)
  Loop % (8, offset:=0)
    v%A_Index% := NumGet(v+0, offset+=4, "Int")
Return ( v3>v7 ? [v7, Y, 0x18] : v4>v8 ? [X, v8, 0x24]
       : v5>v1 ? [v5, Y, 0x10] : v6>v2 ? [X, v6, 0x04] : [0,0,0] )
}