$`::
	FileGetTime,newtransT,%A_ScriptDir%\settings\translist.ini
	if (newtransT != transT)
	{
		transT:= newtransT
		translist:=IniObj(A_ScriptDir "\settings\translist.ini").З­вы
	}
	tempV:=GetSelText()
	tempV=%tempV%
	if !tempV
	{
		SendRaw, ``
	return
	}
	for key, value in translist
	{
		if (tempV = key)
		{
			if InStr(value, "``r")
			{
				value:=SubStr(value,1,-2)
				value:=value "`r"
			}
			Send {text}%value%
		return
		}
	}
return