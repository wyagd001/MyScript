; 命令函数化
CF_FileRead(sfile){
	fileread, FileR_TFC, %sfile%
Return FileR_TFC
}

CF_IniRead(ini, sec, key := "", default := ""){
	IniRead, v, %ini%, %sec%, %key%, %default%
Return, v
}

CF_IniRead_Section(ini, sec){
	IniRead,keylist, %ini%, %sec%
Return %keylist%
}

CF_RegDelete(RootKey, SubKey, ValueName := "") {
	RegDelete, % RootKey, % SubKey, % ValueName
Return
}

CF_RegRead(RootKey, SubKey, ValueName = "") {
	RegRead, v, %RootKey%, %SubKey%, %ValueName%
Return, v
}

CF_RegWrite(ValueType, RootKey, SubKey, ValueName="", Value="") {
	RegWrite, % ValueType, % RootKey, % SubKey, % ValueName, % Value
Return
}

CF_StringReplace(InputVar, SearchText, ReplaceText = "", All = "") {
	StringReplace, v, InputVar, %SearchText%, %ReplaceText%, %All%
	Return, v
}

CF_ToolTip(tipText, delay := 1000)
{
	ToolTip
	ToolTip, % tipText
	SetTimer, RemoveToolTip, % "-" delay
return

RemoveToolTip:
	ToolTip
return
}

CF_Traytip(tipTitle, tipText, delay := 1000,Options:=0)
{
	Traytip, % tipTitle, % tipText, ,% Options
	SetTimer, RemoveTraytip, % "-" delay
return

RemoveTraytip:
	TrayTip
	if SubStr(A_OSVersion,1,3) = "10."
	{
		Menu Tray, NoIcon
		Sleep 200  ; 可能有必要调整 sleep 的时间.
		Menu Tray, Icon
	}
return
}

CF_GetDriveFS(sfile){
	SplitPath, sfile, , , , , sDrive
	DriveGet, DFS, FS, %sDrive%
	return DFS
}

CF_FolderIsEmpty(sfolder){
Loop, Files, %sfolder%\*.*, FD
	return 0
return 1
}

CF_Isinteger(ByRef hNumber){
	if hNumber is integer
	{
		hNumber := Round(hNumber)
		return true
	}
}

CF_IsFolder(sfile){
	if InStr(FileExist(sfile), "D")
	|| (sfile = """::{20D04FE0-3AEA-1069-A2D8-08002B30309D}""")
	|| SubStr(sfile, 1, 2) = "\\"
		return 1
	else
		return 0
}

CF_OpenFolder(sfile, OnlyFolder := 1){
	if !CF_IsFolder(sfile)
		SplitPath, sfile, , oPath
	if OnlyFolder
		Run %oPath%
	else
		Run, % "explorer.exe /select," sfile
}

CF_GetParentPath(sfile){
	return SubStr(sfile, 1, InStr(SubStr(sfile, 1, -1), "\", 0, 0)-1)
}

CF_GetParentFolderName(sfile){
	RegExMatch(sfile, "(.+\\\K|^)[^\\]+(?=\\)", m)
	return m
}

CF_FileIsReadOnly(sfile){
	FileGetAttrib, Attributes, %sfile%
	if InStr(Attributes, "R")
	return 1
	else
	return 0
}

CF_SendMessage(Msg, wParam := 0, lParam := 0, Control := "", WinTitle := "A"){
	SendMessage, % Msg, % wParam, % lParam, %control%, %WinTitle%
	return ErrorLevel
}

CF_PostMessage(Msg, wParam := 0, lParam := 0, Control := "", WinTitle := "A"){
	PostMessage, % Msg, % wParam, % lParam, %control%, %WinTitle%
}

CF_ControlGetText(Control, WinTitle := ""){
	if WinTitle
		ControlGetText, OutputVar, %Control%, %WinTitle%
	else
		ControlGetText, OutputVar, , ahk_id %Control%
return OutputVar
}