_byteswap_uint64(num) ; 需要 msvcr100.dll
{
return dllcall("msvcr100\_byteswap_uint64", "UInt64", Num, "UInt64")
}

_byteswap_uint32(num)
{
return dllcall("msvcr100\_byteswap_ulong", "UInt", Num, "UInt")
}

PathIsDirectoryEmpty(sFolder)
{
return DllCall("shlwapi\PathIsDirectoryEmpty", Str, sFolder)
}

; https://www.autohotkey.com/boards/viewtopic.php?style=7&t=76062
; 确保路径唯一, 添加 (num) 例如 " (2)"
;msgbox % PathU(A_ScriptFullPath)
PathU(sFile) {                     ; PathU v0.90 by SKAN on D35E/D35F @ tiny.cc/pathu 
Local Q, F := VarSetCapacity(Q,520,0) 
  DllCall("kernel32\GetFullPathNameW", "WStr",sFile, "UInt",260, "Str",Q, "PtrP",F)
  DllCall("shell32\PathYetAnotherMakeUniqueName","Str",Q, "Str",Q, "Ptr",0, "Ptr",F)
Return A_IsUnicode ? Q : StrGet(&Q, "UTF-16")
}

; 删除文件，成功时返回非零值，失败返回0.
DeleteFile(sFile)
{
    if !(DllCall("kernel32.dll\DeleteFile", "Str", sFile))
        return GetLastError()
    return 1
}

GetLastError()
{
    return DllCall("kernel32.dll\GetLastError")
}

; https://docs.microsoft.com/zh-cn/windows/win32/api/winbase/nf-winbase-createhardlinka
; 成功返回非零值，失败返回 0.
CreateHardLink(InFile, OutFile)
{
Return (DllCall("CreateHardLink", "Str", OutFile, "Str", InFile, "Int",0))
}

; https://docs.microsoft.com/zh-cn/windows/win32/api/winbase/nf-winbase-createsymboliclinka
; 成功返回非零值，失败返回 0.
CreateSymbolicLink(InFile, OutFile, IsDirectoryLink := 0)
{
Return (DllCall("CreateSymbolicLink", "Str", OutFile, "Str", InFile, "UInt", IsDirectoryLink))
}

ListHardLinks(sFile)
{
	;static ERROR_MORE_DATA := 234
	static MAX_PATH := 260
	buflen := MAX_PATH
	VarSetCapacity(linkname, buflen)
	handle := DllCall("FindFirstFileNameW", "WStr", sFile, "UInt", 0, "UInt*", buflen, "WStr", linkname)
	root := SubStr(sFile, 1, 2)
	paths := ""
	try
	{
		Loop
		{
			paths .= root linkname "`n"
			
			buflen := MAX_PATH
			VarSetCapacity(linkname, buflen)
			more := DllCall("FindNextFileNameW", "UInt", handle, "UInt*", buflen, "WStr", linkname)
		} until (!more)
	} finally
	DllCall("FindClose", "UInt", handle)
	
	return paths
}

;msgbox % readSector("C:")
;msgbox % readSector("PhysicalDrive0", 0x4A8530000)
readSector(Device, Offset:=0)
{
FileName       := "\\.\" Device
hFile := DllCall("CreateFile", "str", FileName, "UInt", 0x80000000, "UInt", 0x1|0x2, "UInt", 0, "UInt", 3, "Uint", 0, "UInt", 0)
BytesToRead := VarSetCapacity(MySector, 512, 0x55)

ldword := Offset & 0xFFFFFFFF
hdword := (Offset >> 32) & 0xFFFFFFFF
VarSetCapacity(OVERLAPPED, 20, 0)
NumPut(ldword, OVERLAPPED, 8, "UInt")
NumPut(hdword, OVERLAPPED, 12, "UInt")

response := DllCall("ReadFile", "UInt", hFile, "UInt", &MySector, "UInt", 512, "UInt *", BytesToRead, "UInt", &OVERLAPPED)
response := DllCall("CloseHandle", "UInt", hFile)

	i = 0 
	Data_HEX =
	BackUp_FmtInt := A_FormatInteger
	SetFormat, Integer, HEX   
	Loop 512 
	{ 
		;First byte into the Rx FIFO ends up at position 0 

		Data_HEX_Temp := NumGet(MySector, i, "UChar") ;Convert to HEX byte-by-byte 
		StringTrimLeft, Data_HEX_Temp, Data_HEX_Temp, 2 ;Remove the 0x (added by the above line) from the front 

		;If there is only 1 character then add the leading "0' 
		Length := StrLen(Data_HEX_Temp) 
		If (Length =1) 
		  Data_HEX_Temp = 0%Data_HEX_Temp% 
		i++ 
		;Put it all together 
		Data_HEX := Data_HEX . Data_HEX_Temp 
	} 
	SetFormat, Integer, %BackUp_FmtInt%
return Data_HEX
}

/*
q::
;DefineDosDevice("N:")
;DefineDosDevice("N:","Z:")

;MsgBox % QueryDosDevice("N:")

;msgbox % GetVolumeNameForVolumeMountPoint("Z:\")
; \\?\Volume{8973cba8-134d-11eb-87bc-806e6f6b6963}\

您可以通过使用SetVolumeMountPoint函数为本地卷分配一个驱动器号（例如，X:），前提是没有卷已经分配给该驱动器号。如果本地卷已经有一个驱动器号，那么SetVolumeMountPoint将失败。要处理这种情况，首先使用DeleteVolumeMountPoint函数删除驱动器代号。示例代码请参见编辑驱动器号分配。

系统支持每个卷最多支持一个驱动器字母。因此，您不能让C:\和F:\代表同一个卷。
*/

DefineDosDevice(sDevice, sPath = "")
{
	sDevice := RTrim(sDevice, " \")
	sPath := RTrim(sPath, " \")
	Return DllCall("DefineDosDevice", "Uint", sPath ? 0 : 1|2, "str", sDevice, "str", sPath)
}

/*
    Retrieves information about the specified MS-DOS device.
    Parameters:
        DeviceName:
            An MS-DOS device name string specifying the target of the query.
            This parameter can be a path or string like "\\?\Volume{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}\".
            If this parameter is an empty string, the function will return a list of all existing MS-DOS device names.
    Return value:
        If the function succeeds, the return value is an Array with one or more strings.
        - The first string stored into the Array is the current mapping for the device.
        - The other strings represent undeleted prior mappings for the device.
        If the function fails, the return value is zero. A_LastError contains a system error code.
*/
QueryDosDevice(sDevice = "")
{
	sDevice := RTrim(sDevice, " \")
	VarSetCapacity(sPath, 256, 0)
	Size := DllCall("QueryDosDevice", "UPtr", sDevice ? &sDevice : 0, "UPtr", &sPath, "Uint", 256)
	Name := "", List := [], Ptr := &sPath
; Size the number of bytes comprising the formatted return Value.
;   on whether PATHS/PATH contain Unicode characters. It CAN happen that
;   calling QueryDosDeviceW("E:") returns "25: \Device\Harddiskvolume3" and
;   calling QueryDosDeviceW("V:") returns "34: \??\E:\bin\apps" because the
;   \??\ prefix implies a Unicode string.

	if !Size && Errorlevel  
	return 0
	while StrLen(Name := StrGet(Ptr))
	{
		;msgbox % Ptr " - " Name " - " StrPut(Name, "UTF-16")
		List.Push(Name) , Ptr := Ptr+StrPut(Name, "UTF-16")*2
	}
Return List
} ; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-querydosdevicew

GetVolumeNameForVolumeMountPoint(pl)
{
	pl := RTrim(pl, " \")
	pl := pl "\"
	VarSetCapacity(VolumeName, 100, 0)
	hl:=dllcall("Kernel32.dll\GetVolumeNameForVolumeMountPoint", "Str", pl, "Str", VolumeName, "Uint", 100, "Int")
	if hl && !ErrorLevel
	return VolumeName
	else
	return 0
}

DeleteVolumeMountPoint(pl)
{
	pl := RTrim(pl, " \")
	pl := pl "\"
	hl:=dllcall("Kernel32.dll\DeleteVolumeMountPoint", "Str", pl)
	if hl && !ErrorLevel
	return 1
	else
	return 0
}

SetVolumeMountPoint(pl, VolumeName)
{
	pl := RTrim(pl, " \")
	pl := pl "\"
	hl:=dllcall("Kernel32.dll\SetVolumeMountPoint", "Str", pl, "Str", VolumeName)
	if hl && !ErrorLevel
	return 1
	else
	return 0
}

setwinappid(winhwnd,appid)
{
VarSetCapacity(IID_IPropertyStore, 16)
DllCall("ole32.dll\CLSIDFromString", "wstr", "{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}", "ptr", &IID_IPropertyStore)
VarSetCapacity(PKEY_AppUserModel_ID, 20)
DllCall("ole32.dll\CLSIDFromString", "wstr", "{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}", "ptr", &PKEY_AppUserModel_ID)
NumPut(5, PKEY_AppUserModel_ID, 16, "uint")
dllcall("shell32\SHGetPropertyStoreForWindow","Ptr", winhwnd, "ptr", &IID_IPropertyStore, "ptrp", pstore)
VarSetCapacity(variant, 8+2*A_PtrSize, 0)
NumPut(31, variant, 0, "short") ; VT_LPWSTR
NumPut(&Appid, variant, 8)
hr := IPropertyStore_SetValue(pstore, &PKEY_AppUserModel_ID, &variant)
}

IPropertyStore_GetCount(pstore, ByRef count) {
    return DllCall(VTable(pstore,3), "ptr", pstore, "uintp", count)
}
IPropertyStore_GetValue(pstore, pkey, pvalue) {
    return DllCall(VTable(pstore,5), "ptr", pstore, "ptr", pkey, "ptr", pvalue)
}
IPropertyStore_SetValue(pstore, pkey, pvalue) {
    return DllCall(VTable(pstore,6), "ptr", pstore, "ptr", pkey, "ptr", pvalue)
}
