WM_QUERYENDSESSION(wParam, lParam)
{
	global ShutdownBlock
	If not ShutdownBlock
		Exit
	SetTimer, ShutdownDialog, 300
	Return false
	/*   ; XP
	ENDSESSION_LOGOFF = 0x80000000
	If (lParam & ENDSESSION_LOGOFF)  ; 用户正在注销
		EventType = 注销
	Else  ; 系统正在关闭或重启。
		EventType = 关机
	MsgBox, 4,, 正在%EventType%，是否允许？
	IfMsgBox Yes
		Return true  ; 告诉操作系统允许 关机/注销 操作继续。
	Else
	{
		; 不再阻止系统关机
		DllCall("ShutdownBlockReasonDestroy","Uint",hAhk)
	Return false  ; 告诉操作系统终止 关机/注销。
	}
	*/
}

;WM_ENDSESSION(wParam, lParam)
;{
;	global ShutdownBlock
;	If not ShutdownBlock
;		Exit
;	Return false
;}


ShutdownDialog:
;sendplay {esc}
;DllCall("AbortSystemShutdown", "Str", 0)
if SubStr(A_OSVersion,1,3) = "10."
{
   sleep 2000
   WinRing0.KeyPress("escape")
   sleep 500
   send {esc}
   sleep 400
   WinClose, ahk_class Progman
   sleep 200
   WinActivate, 关闭 Windows ahk_class #32770
   SetTimer, ShutdownDialog, off
}
else
{
WinWait, ahk_class BlockedShutdownResolver
If not ErrorLevel
{
   WinClose, ahk_class BlockedShutdownResolver
   WinWaitClose, ahk_class BlockedShutdownResolver
   IfNotEqual, ErrorLevel, 1, WinClose, ahk_class Progman
   SetTimer, ShutdownDialog, off
}
}
Return

#IfWinActive, 关闭 Windows ahk_class #32770
Enter::
Space::
ControlGet, Choice, Choice, , ComboBox1
ControlGetFocus, Focus
If Choice in 注销,重新启动,关机,更新并重启,重启,更新并关机
{
   If (Focus = "ComboBox1" && A_ThisHotkey = "Enter")
      or (Focus = "Button3")
      ShutdownBlock := false
}
SendInput, % "{" . A_ThisHotkey . "}"
Return
#IfWinActive

HookProc(hWinEventHook2, Event, hWnd)
{
	global ShutdownBlock
	static hShutdownDialog
	Event += 0
	if Event = 8 ; EVENT_SYSTEM_CAPTURESTART
	{
		WinGetClass, Class, ahk_id %hWnd%
		WinGetTitle, Title, ahk_id %hWnd%
		if (Class = "Button" and Title = "确定")
		{
			ControlGet, Choice, Choice, , ComboBox1, ahk_id %hShutdownDialog%
			if Choice in 注销,重新启动,关机,更新并重启,重启,更新并关机
				ShutdownBlock := false
		}
	}
	if Event = 9
	{
		ifWinActive, 关闭 Windows ahk_class #32770
		{
			sleep,2000
			ShutdownBlock := true
		}
	}
	else if Event = 16 ; EVENT_SYSTEM_DIALOGSTART
	{
		WinGetClass, Class, ahk_id %hWnd%
		WinGetTitle, Title, ahk_id %hWnd%
		If (Class = "#32770" and Title = "关闭 Windows")
			hShutdownDialog := hWnd
	}
	else if Event = 17 ; EVENT_SYSTEM_DIALOGEND
		hShutdownDialog =
}