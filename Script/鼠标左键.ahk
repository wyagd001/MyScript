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