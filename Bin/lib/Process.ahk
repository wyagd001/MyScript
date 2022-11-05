ExecSend(ByRef StringToSend, ByRef Title, flag=0, Msg:=55555) {
	if (msg=0x4a)
	{
		VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
		SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
		NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
		NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
		DetectHiddenWindows, On
		if Title is integer
		{
			SendMessage, 0x4a, flag, &CopyDataStruct,, ahk_id %Title%
		}
		else if Title is not integer
		{
			SetTitleMatchMode 2
			sendMessage, 0x4a, flag, &CopyDataStruct,, %Title%
		}
	}
	else
	{
		DetectHiddenWindows, On
		SendMessage, 55555, flag, 1,, ahk_id %Title%
		;msgbox % ErrorLevel
	}
	return ErrorLevel
}

GetModuleFileNameEx(p_pid)
{
	if A_OSVersion in WIN_95,WIN_98,WIN_ME,WIN_XP
	{
		MsgBox, Windows 版本 (%A_OSVersion%) 不支持。Win 7 及以上系统才能正常使用。
		return
	}

	h_process := DllCall("OpenProcess", "uint", 0x10|0x400, "int", false, "uint", p_pid)
	if ( ErrorLevel or h_process = 0 )
		return

	name_size = 255
	VarSetCapacity(name, name_size)

	result := DllCall("psapi.dll\GetModuleFileNameEx", "uint", h_process, "uint", 0, "str", name, "uint", name_size)

	DllCall("CloseHandle", h_process)
	return, name
}

/*
q::
Process, Exist, notepad.exe
;tooltip % errorlevel
msgbox % www := GetCommandLine(errorlevel)
toHex(www, ww)
msgbox % ww
return
*/

; GetProcAddress  32 位主程序对32位和64位程序成功
; GetProcAddress  64 位主程序                   失败 ;错误代码 126 找不到该模块
; ReadProcessMemory  32 位主程序对32位程序成功， 64位程序对64位失败  错误代码 299  部分成功   5 拒绝访问
; https://www.autohotkey.com/board/topic/15214-getcommandline/
GetCommandLine(PID) { ;  by Sean          www.autohotkey.com/forum/viewtopic.php?t=16575
 Static pFunc
 If ! (hProcess := DllCall("OpenProcess", UInt, 0x043A, Int,0, UInt, PID))
        Return
 If pFunc=
{
pMoudule := DllCall("GetModuleHandle", Str,"kernel32.dll", "ptr")
    pFunc := DllCall("GetProcAddress", Ptr
           , pMoudule, A_IsUnicode ? "Astr":"str", A_IsUnicode ? "GetCommandLineW" : "GetCommandLineA", "ptr")
;msgbox % pMoudule " - " pFunc
;msgbox % ErrorLevel " - " A_LastError
}
 hThrd := DllCall("CreateRemoteThread", "Ptr", hProcess, "Ptr", 0, "uPtr", 0, "Ptr", pFunc, "Ptr", 0
        , "UInt", 0, "uint", 0)
;msgbox % hThrd
;msgbox % ErrorLevel " - " A_LastError
DllCall("WaitForSingleObject", Ptr, hThrd, UInt, 0xFFFFFFFF)
;msgbox % ErrorLevel " - " A_LastError
 DllCall("GetExitCodeThread", Ptr, hThrd, UIntP, pcl, "Ptr")
;msgbox % pcl
;msgbox % ErrorLevel " - " A_LastError
VarSetCapacity(sCmdLine, 520)
 DllCall("ReadProcessMemory", Ptr, hProcess, Ptr, pcl, Str, sCmdLine, Uint, 520, Uint, 0, int)
;msgbox % ErrorLevel " - " A_LastError
 DllCall("CloseHandle", Ptr, hThrd), DllCall("CloseHandle", Ptr, hProcess)
Return sCmdLine
}

toHex( ByRef V, ByRef H, dataSz:=0 )
{ ; http://goo.gl/b2Az0W (by SKAN)
	P := ( &V-1 ), VarSetCapacity( H,(dataSz*2) ), Hex := "123456789ABCDEF0"
	Loop, % dataSz ? dataSz : VarSetCapacity( V )
		H  .=  SubStr(Hex, (*++P >> 4), 1) . SubStr(Hex, (*P & 15), 1)
}

GetCommandLine2(pid)
{
	for process in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where ProcessId=" pid)
		Return sCmdLine := process.CommandLine
}