; ÃüÁîº¯Êý»¯
CF_FileRead(filename){
	fileread,hfile,%filename%
Return hfile
}

CF_IniRead(ini, sec, key="", default = ""){
	IniRead, v, %ini%, %sec%, %key%, %default%
Return, v
}

CF_IniRead_Section(ini,sec){
	IniRead,keylist,%ini%,%sec%
Return %keylist%
}

CF_RegDelete(RootKey, SubKey, ValueName="") {
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