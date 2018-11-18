SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags)
{
	return DllCall("SetWinEventHook"
	, Uint,eventMin
	, Uint,eventMax
	, Uint,hmodWinEventProc
	, Uint,lpfnWinEventProc
	, Uint,idProcess
	, Uint,idThread
	, Uint,dwFlags)
}

UnhookWinEvent(hWinEventHook, HookProcAdr)
{
	DllCall( "UnhookWinEvent", Uint,hWinEventHook)
	DllCall( "GlobalFree", UInt,HookProcAdr)  ; free up allocated memory for RegisterCallback
	;msgbox % "成功为0, 但前值为: " qw
	; &HookProcAdr 引发程序异常退出  改为 HookProcAdr不知道是否有同样效用
}