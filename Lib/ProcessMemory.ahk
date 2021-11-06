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

;----------------------------------------------------------------------------------------------
; Function: OpenProcess
;         Opens an existing local process object.
;
; Parameters:
;         DesiredAccess - The desired access to the process object. 
;
;         InheritHandle - If this value is TRUE, processes created by this process will inherit
;                         the handle. Otherwise, the processes do not inherit this handle.
;
;         ProcessId     - The Process ID of the local process to be opened. 
;
; Returns:
;         If the function succeeds, the return value is an open handle to the specified process.
;         If the function fails, the return value is NULL.
;
OpenProcess(DesiredAccess, InheritHandle, ProcessId)
{
	return DllCall("OpenProcess"
	             , "Int", DesiredAccess
				 , "Int", InheritHandle
				 , "Int", ProcessId
				 , "Ptr")
}

;----------------------------------------------------------------------------------------------
; Function: CloseHandle
;         Closes an open object handle.
;
; Parameters:
;         hObject       - A valid handle to an open object
;
; Returns:
;         If the function succeeds, the return value is nonzero.
;         If the function fails, the return value is zero.
;
CloseHandle(hObject)
{
	return DllCall("CloseHandle"
	             , "Ptr", hObject
				 , "Int")
}

;----------------------------------------------------------------------------------------------
; Function: VirtualAllocEx
;         Reserves or commits a region of memory within the virtual address space of the 
;         specified process, and specifies the NUMA node for the physical memory.
;
; Parameters:
;         hProcess      - A valid handle to an open object. The handle must have the 
;                         PROCESS_VM_OPERATION access right.
;
;         Address       - The pointer that specifies a desired starting address for the region 
;                         of pages that you want to allocate. 
;
;                         If you are reserving memory, the function rounds this address down to 
;                         the nearest multiple of the allocation granularity.
;
;                         If you are committing memory that is already reserved, the function rounds 
;                         this address down to the nearest page boundary. To determine the size of a 
;                         page and the allocation granularity on the host computer, use the GetSystemInfo 
;                         function.
;
;                         If Address is NULL, the function determines where to allocate the region.
;
;         Size          - The size of the region of memory to be allocated, in bytes. 
;
;         AllocationType - The type of memory allocation. This parameter must contain ONE of the 
;                          following values:
;								MEM_COMMIT
;								MEM_RESERVE
;								MEM_RESET
;
;         ProtectType   - The memory protection for the region of pages to be allocated. If the 
;                         pages are being committed, you can specify any one of the memory protection 
;                         constants:
;								 PAGE_NOACCESS
;								 PAGE_READONLY
;								 PAGE_READWRITE
;								 PAGE_WRITECOPY
;								 PAGE_EXECUTE
;								 PAGE_EXECUTE_READ
;								 PAGE_EXECUTE_READWRITE
;								 PAGE_EXECUTE_WRITECOPY
;
; Returns:
;         If the function succeeds, the return value is the base address of the allocated region of pages.
;         If the function fails, the return value is NULL.
;
VirtualAllocEx(hProcess, Address, Size, AllocationType, ProtectType)
{
	return DllCall("VirtualAllocEx"
				 , "Ptr", hProcess
				 , "Ptr", Address
				 , "UInt", Size
				 , "UInt", AllocationType
				 , "UInt", ProtectType
				 , "Ptr")
}

;----------------------------------------------------------------------------------------------
; Function: VirtualFreeEx
;         Releases, decommits, or releases and decommits a region of memory within the 
;         virtual address space of a specified process
;
; Parameters:
;         hProcess      - A valid handle to an open object. The handle must have the 
;                         PROCESS_VM_OPERATION access right.
;
;         Address       - The pointer that specifies a desired starting address for the region 
;                         to be freed. If the dwFreeType parameter is MEM_RELEASE, lpAddress 
;                         must be the base address returned by the VirtualAllocEx function when 
;                         the region is reserved.
;
;         Size          - The size of the region of memory to be allocated, in bytes. 
;
;                         If the FreeType parameter is MEM_RELEASE, dwSize must be 0 (zero). The function 
;                         frees the entire region that is reserved in the initial allocation call to 
;                         VirtualAllocEx.
;
;                         If FreeType is MEM_DECOMMIT, the function decommits all memory pages that 
;                         contain one or more bytes in the range from the Address parameter to 
;                         (lpAddress+dwSize). This means, for example, that a 2-byte region of memory
;                         that straddles a page boundary causes both pages to be decommitted. If Address 
;                         is the base address returned by VirtualAllocEx and dwSize is 0 (zero), the
;                         function decommits the entire region that is allocated by VirtualAllocEx. After 
;                         that, the entire region is in the reserved state.
;
;         FreeType      - The type of free operation. This parameter can be one of the following values:
;								MEM_DECOMMIT
;								MEM_RELEASE
;
; Returns:
;         If the function succeeds, the return value is a nonzero value.
;         If the function fails, the return value is 0 (zero). 
;
VirtualFreeEx(hProcess, Address, Size, FType)
{
	return DllCall("VirtualFreeEx"
				 , "Ptr", hProcess
				 , "Ptr", Address
				 , "UINT", Size
				 , "UInt", FType
				 , "Int")
}

;----------------------------------------------------------------------------------------------
; Function: WriteProcessMemory
;         Writes data to an area of memory in a specified process. The entire area to be written 
;         to must be accessible or the operation fails
;
; Parameters:
;         hProcess      - A valid handle to an open object. The handle must have the 
;                         PROCESS_VM_WRITE and PROCESS_VM_OPERATION access right.
;
;         BaseAddress   - A pointer to the base address in the specified process to which data 
;                         is written. Before data transfer occurs, the system verifies that all 
;                         data in the base address and memory of the specified size is accessible 
;                         for write access, and if it is not accessible, the function fails.
;
;         Buffer        - A pointer to the buffer that contains data to be written in the address 
;                         space of the specified process.
;
;         Size          - The number of bytes to be written to the specified process.
;
;         NumberOfBytesWritten   
;                       - A pointer to a variable that receives the number of bytes transferred 
;                         into the specified process. This parameter is optional. If NumberOfBytesWritten 
;                         is NULL, the parameter is ignored.
;
; Returns:
;         If the function succeeds, the return value is a nonzero value.
;         If the function fails, the return value is 0 (zero). 
;
WriteProcessMemory(hProcess, BaseAddress, Buffer, Size, ByRef NumberOfBytesWritten = 0)
{
	return DllCall("WriteProcessMemory"
				 , "Ptr", hProcess
				 , "Ptr", BaseAddress
				 , "Ptr", Buffer
				 , "Uint", Size
				 , "UInt*", NumberOfBytesWritten
				 , "Int")
}

;----------------------------------------------------------------------------------------------
; Function: ReadProcessMemory
;         Reads data from an area of memory in a specified process. The entire area to be read 
;         must be accessible or the operation fails
;
; Parameters:
;         hProcess      - A valid handle to an open object. The handle must have the 
;                         PROCESS_VM_READ access right.
;
;         BaseAddress   - A pointer to the base address in the specified process from which to 
;                         read. Before any data transfer occurs, the system verifies that all data 
;                         in the base address and memory of the specified size is accessible for read 
;                         access, and if it is not accessible the function fails.
;
;         Buffer        - A pointer to a buffer that receives the contents from the address space 
;                         of the specified process.
;
;         Size          - The number of bytes to be read from the specified process.
;
;         NumberOfBytesWritten   
;                       - A pointer to a variable that receives the number of bytes transferred 
;                         into the specified buffer. If lpNumberOfBytesRead is NULL, the parameter 
;                         is ignored.
;
; Returns:
;         If the function succeeds, the return value is a nonzero value.
;         If the function fails, the return value is 0 (zero). 
;
ReadProcessMemory(hProcess, BaseAddress, ByRef Buffer, Size, ByRef NumberOfBytesRead = 0)
{
	return DllCall("ReadProcessMemory"
	             , "Ptr", hProcess
				 , "Ptr", BaseAddress
				 , "Ptr", &Buffer
				 , "UInt", Size
				 , "UInt*", NumberOfBytesRead
				 , "Int")
}