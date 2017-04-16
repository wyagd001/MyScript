~LButton::
	CoordMode, Mouse, Screen
	MouseGetPos, lastx, lasty, id
	WinGetClass, Class, ahk_id %id%
	isF:=IsFullscreen("A",false,false)
	If(x=0 && y=0 && !WinActive("ahk_class Flip3D") && !isF)
		Send ^#{Tab}
		;rundll32.exe DwmApi #105
	If(lastx>=A_ScreenWidth - 1.5 and lasty>=A_ScreenHeight - 60 and lasty<=A_ScreenHeight - 30 && !isF)
	{
		;if (class = "Progman" || class = "WorkerW")
		Run taskmgr.exe
	}
Return

#If  IsOverCloseButton()
LButton::
	Closewindow:=Explorer_GetPath()
	Send {LButton Down}
	KeyWait, LButton
	Send {LButton Up}
	If Closewindow && (Closewindow <> "Error")
	{
		If LastClosewindow
		{
			If(Closewindow!=LastClosewindow)
			{
				LastClosewindow:=Closewindow
				IniWrite,%LastClosewindow%, %run_iniFile%,常规, LastClosewindow
				Tooltip,该窗口已经记录(点击)。
				Sleep,1000
				Tooltip
			}
		}
		else
		{
			LastClosewindow:=Closewindow
			Tooltip,该窗口已经记录(点击)。
			IniWrite,%LastClosewindow%, %run_iniFile%,常规, LastClosewindow
			Sleep,1000
			Tooltip
		}
	}
Return
#If

IsOverCloseButton()
	{
		IfWinActive, ahk_class CabinetWClass
		{
			MouseGetPos, x, y, winid
			SendMessage, 0x84,, (x & 0xFFFF) | (y & 0xFFFF) << 16,, ahk_id %winid%
			Return (ErrorLevel == 20)
		}
	}