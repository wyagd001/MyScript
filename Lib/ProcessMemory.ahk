; https://autohotkey.com/board/topic/113942-solved-get-cpu-usage-in/
CPULoad()
{
    static PIT, PKT, PUT
    if (Pit = "")
    {
        return 0, DllCall("GetSystemTimes", "Int64P", PIT, "Int64P", PKT, "Int64P", PUT)
    }
    DllCall("GetSystemTimes", "Int64P", CIT, "Int64P", CKT, "Int64P", CUT)
    IdleTime := PIT - CIT, KernelTime := PKT - CKT, UserTime := PUT - CUT
    SystemTime := KernelTime + UserTime
    return ((SystemTime - IdleTime) * 100) // SystemTime, PIT := CIT, PKT := CKT, PUT := CUT
}

; https://autohotkey.com/board/topic/113942-solved-get-cpu-usage-in/
GlobalMemoryStatusEx()
{
    static MEMORYSTATUSEX, init := VarSetCapacity(MEMORYSTATUSEX, 64, 0) && NumPut(64, MEMORYSTATUSEX, "UInt")
    if (DllCall("Kernel32.dll\GlobalMemoryStatusEx", "Ptr", &MEMORYSTATUSEX))
    {
        return { 2 : NumGet(MEMORYSTATUSEX,  8, "UInt64")
               , 3 : NumGet(MEMORYSTATUSEX, 16, "UInt64")
               , 4 : NumGet(MEMORYSTATUSEX, 24, "UInt64")
               , 5 : NumGet(MEMORYSTATUSEX, 32, "UInt64") }
    }
}

; https://autohotkey.com/board/topic/113942-solved-get-cpu-usage-in/
GetProcessCount()
{
    proc := ""
    for process in ComObjGet("winmgmts:\\.\root\CIMV2").ExecQuery("SELECT * FROM Win32_Process")
    {
        proc++
    }
    return proc
}

WMI_Query(pid)
{
   wmi :=    ComObjGet("winmgmts:")
    queryEnum := wmi.ExecQuery("" . "Select * from Win32_Process where ProcessId=" . pid)._NewEnum()
    if queryEnum[process]
        sResult.=process.CommandLine
    else
        sResult := 0 
   Return   sResult
}

; https://www.autohotkey.com/boards/viewtopic.php?t=30050
;;JEE_NotepadGetFilename
JEE_NotepadGetPath(hWnd)
{
	WinGetClass, vWinClass, % "ahk_id " hWnd
	if !(vWinClass = "Notepad")
		return
	WinGet, vPID, PID, % "ahk_id " hWnd
	WinGet, vPPath, ProcessPath, % "ahk_id " hWnd
	FileGetVersion, vPVersion, % vPPath
	StringLeft, vPVersionnum, vPVersion, 2
	vPVersionnum+=0.1
	MAX_PATH := 260
	;PROCESS_QUERY_INFORMATION := 0x400 ;PROCESS_VM_READ := 0x10
	if !hProc := DllCall("kernel32\OpenProcess", UInt, 0x410, Int, 0, UInt, vPID, Ptr)
		return
; 如果该进程是32位应用程序，运行在64位操作系统上，该值为True，否则为False。
; 如果该进程是64位应用程序，运行在64位操作系统上，该值也被设置为False。
	if A_Is64bitOS
	{
		DllCall("kernel32\IsWow64Process", Ptr, hProc, IntP, vIsWow64Process)
		vPIs64 := !vIsWow64Process
	}

	if (vPVersion = "5.1.2600.5512") && !vPIs64 ; Notepad (Windows XP version)
		vAddress := 0x100A900

	if !vAddress
	{
		VarSetCapacity(MEMORY_BASIC_INFORMATION, A_PtrSize = 8 ? 48 : 28, 0)
		vAddress := 0

		vMbiBaseAddress := DllCall(A_PtrSize = 4  ? "GetWindowLong" : "GetWindowLongPtr", "Ptr", hwnd, "Int", -6, "Ptr")  ; GWLP_HINSTANCE = -6
		VarSetCapacity(vPath, MAX_PATH*2)
		DllCall("psapi\GetMappedFileName", Ptr, hProc, Ptr, vMbiBaseAddress, Str, vPath, UInt, MAX_PATH*2, UInt)
		;msgbox %vPath%  ; 结果如下
		; \Device\HarddiskVolume6\WINDOWS\notepad.exe XP C盘
		; \Device\HarddiskVolume1\Windows\System32\notepad.exe  win8 J盘
		; \Device\HarddiskVolume10\Windows\notepad.exe  win7 G盘

		if !InStr(vPath, "notepad")
		return

		if (vPVersionnum > 10)    ; win10
		{
			;get address where path starts
			if vPIs64  ; win10 x64 不能得到地址 直接返回
			return
			;vAddress := vMbiBaseAddress + 0x245C0
			;vAddress := vMbiBaseAddress + 0x10B40
			else
			{
				If (vPVersion = "10.0.15063.0")
					vAddress := vMbiBaseAddress + 0x1F000 ; (0x1CB30 文件菜单打开时有效 拖拽无效  0x1E000 拖拽文件打开和文件菜单打开都有效)
				If (vPVersion = "10.0.14393.0")
					vAddress := vMbiBaseAddress + 0x1E000  ; 其他可能的值 0x1D220
					;MsgBox, % Format("0x{:X}", vMbiBaseAddress) "`r`n" Format("0x{:X}", vAddress)
			}
		}
		if (vPVersionnum < 10) 
		{
			;MsgBox, % Format("0x{:X}", vMbiBaseAddress)
			; get address where path starts
			if (vPVersion = "6.1.7601.18917")  ; Win7
			{
				if vPIs64
					vAddress := vMbiBaseAddress + 0x10B40
				else
					vAddress := vMbiBaseAddress + 0xCAE0 ;(vMbiBaseAddress + 0xD378 also appears to work)
			}
			if (vPVersion = "6.3.9600.17930")  ; Win8
			{
				if vPIs64
					vAddress := vMbiBaseAddress + 0x10B40
				else
					vAddress := vMbiBaseAddress + 0x17960  ;(vMbiBaseAddress + 0x18260 对拖拽无效)
			}
		}
	}

	VarSetCapacity(vPath, MAX_PATH*2, 0)
	DllCall("kernel32\ReadProcessMemory", Ptr, hProc, Ptr, vAddress, Str, vPath, UPtr, MAX_PATH*2, UPtr, 0)
	DllCall("kernel32\CloseHandle", Ptr, hProc)

	if A_IsUnicode
	{
		;msgbox % vPath
		If FileExist(vPath)
			return vPath
	}
	else
	{
		; 转换vPath为ansi版能识别的字符 U版不需要转换
		VarSetCapacity(vfilepath, MAX_PATH, 0) 
		DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", vPath, "int", -1, "str", vfilepath, "int", MAX_PATH, "Uint", 0, "Uint", 0)
		If FileExist(vfilepath)
			return vfilepath
	}
}
