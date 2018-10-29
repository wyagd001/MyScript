; ÃüÁîº¯Êý»¯
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

CF_ToolTip(tipText, delay := 1000)
{
	ToolTip, % tipText
	SetTimer, RemoveToolTip, % "-" delay
return

RemoveToolTip:
	ToolTip
return
}

IsStingFunc(str:="")
{
	strfunc:=StrSplit(str,"(")
	If IsFunc(strfunc[1])
	return 1
	else
	return 0
}

RunStingFunc(str:="")
{
	strfunc:=StrSplit(str, "(", ")")
	tempfunc:=strfunc[1]
	params:=StrSplit(strfunc[2], ",")
	if (params.MaxIndex() = "")
	{
		%tempfunc%()
	return
	}
	else if (params.MaxIndex() = 1)
	{
		%tempfunc%(params[1])
	return
	}
	else if (params.MaxIndex() = 2)
	{
		%tempfunc%(params[1],params[2])
	return
	}
	else if (params.MaxIndex() = 3)
	{
		%tempfunc%(params[1],params[2],params[3])
	return
	}
	else (params.MaxIndex() = 4)
	{
		%tempfunc%(params[1],params[2],params[3],params[4])
	return
	}
}