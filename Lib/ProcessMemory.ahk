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
        MsgBox 指定进程没有找到!  
   Return   sResult
}

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
	if !hProc := DllCall("kernel32\OpenProcess", UInt,0x410, Int,0, UInt,vPID, Ptr)
		return
	if !vAddress && A_Is64bitOS
	{
		DllCall("kernel32\IsWow64Process", Ptr,hProc, IntP,vIsWow64Process)
		vPIs64 := !vIsWow64Process
	}
	if (vPVersion = "5.1.2600.5512") && !vPIs64 ;Notepad (Windows XP version)
		vAddress := 0x100A900

	if !vAddress
	{
		VarSetCapacity(MEMORY_BASIC_INFORMATION, A_PtrSize=8?48:28, 0)
		vAddress := 0
		Loop
		{
			if !DllCall("kernel32\VirtualQueryEx", Ptr,hProc, Ptr,vAddress, Ptr,&MEMORY_BASIC_INFORMATION, UPtr,A_PtrSize=8?48:28, UPtr)
				break

			vMbiBaseAddress := NumGet(MEMORY_BASIC_INFORMATION, 0, "Ptr")
			vMbiRegionSize := NumGet(MEMORY_BASIC_INFORMATION, A_PtrSize=8?24:12, "UPtr")
			vMbiState := NumGet(MEMORY_BASIC_INFORMATION, A_PtrSize=8?32:16, "UInt")
			vMbiType := NumGet(MEMORY_BASIC_INFORMATION, A_PtrSize=8?40:24, "UInt")

			vName := ""
			if (vMbiState & 0x1000) ;MEM_COMMIT := 0x1000
			&& (vMbiType & 0x1000000) ;MEM_IMAGE := 0x1000000
			{
				vPath := ""
				VarSetCapacity(vPath, MAX_PATH*2)
				DllCall("psapi\GetMappedFileName", Ptr,hProc, Ptr,vMbiBaseAddress, Str,vPath, UInt,MAX_PATH*2, UInt)
				if !(vPath = "")
					SplitPath, vPath, vName
			}
			if InStr(vName, "notepad") && (vPVersionnum > 10)    ; win10
			{
				;get address where path starts
				if vPIs64
					;vAddress := vMbiBaseAddress + 0x25C0
					vAddress := vMbiBaseAddress + 0x245C0
				else
				{
					If (vPVersion = "10.0.15063.0")
						vAddress := vMbiBaseAddress + 0x1F000 ; (0x1CB30 文件菜单打开时有效 拖拽无效  0x1E000 拖拽文件打开和文件菜单打开都有效)
					If (vPVersion = "10.0.14393.0")
						vAddress := vMbiBaseAddress + 0x1E000
				;MsgBox, % Format("0x{:X}", vMbiBaseAddress) "`r`n" Format("0x{:X}", vAddress)
				}
				break
			}
			if InStr(vName, "notepad") && (vPVersionnum < 10) ; Win7
			{
				;MsgBox, % Format("0x{:X}", vMbiBaseAddress)
				;get address where path starts
				if vPIs64
					vAddress := vMbiBaseAddress + 0x10B40
				else
					vAddress := vMbiBaseAddress + 0xCAE0 ;(vMbiBaseAddress + 0xD378 also appears to work)
				break
			}
			vAddress += vMbiRegionSize
			if (vAddress > 2**32-1) ;4 gigabytes
			{
				DllCall("kernel32\CloseHandle", Ptr,hProc)
				return
			}
		}
	}

	VarSetCapacity(MEMORY_BASIC_INFORMATION, A_PtrSize=8?48:28, 0)
	if DllCall("kernel32\VirtualQueryEx", Ptr,hProc, Ptr,vAddress, Ptr,&MEMORY_BASIC_INFORMATION, UPtr,A_PtrSize=8?48:28, UPtr)
	{
		vMbiBaseAddress := NumGet(MEMORY_BASIC_INFORMATION, 0, "Ptr")
		vPath := ""
		VarSetCapacity(vPath, MAX_PATH*2)
		DllCall("psapi\GetMappedFileName", Ptr,hProc, Ptr,vMbiBaseAddress, Str,vPath, UInt,MAX_PATH*2, UInt)
; \Device\HarddiskVolume6\WINDOWS\notepad.exe XP C盘
; \Device\HarddiskVolume10\Windows\notepad.exe  win7 G盘
;msgbox %vPath%
		if InStr(vPath, "notepad")
		{
			VarSetCapacity(vPath, MAX_PATH*2, 0)
			DllCall("kernel32\ReadProcessMemory", Ptr,hProc, Ptr,vAddress, Str,vPath, UPtr,MAX_PATH*2, UPtr,0)
		}
	}

if !A_IsUnicode
{
;转换vPath为ansi版能识别的字符 U版不需要转换
	VarSetCapacity(vfilepath, MAX_PATH, 0) 
DllCall("WideCharToMultiByte", "Uint",0, "Uint",0, "str",vPath, "int",-1, "str",vfilepath, "int",MAX_PATH, "Uint",0, "Uint",0)
	DllCall("kernel32\CloseHandle", Ptr,hProc)
	return vfilepath
}
else
{
	DllCall("kernel32\CloseHandle", Ptr,hProc)
	return vPath
}
}
