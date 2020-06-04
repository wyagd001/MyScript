; 命令函数化
CF_FileRead(filename){
	fileread, hfile, %filename%
Return hfile
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