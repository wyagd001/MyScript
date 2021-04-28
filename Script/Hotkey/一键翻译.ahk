$`::
	FileGetTime,newtransT,%A_ScriptDir%\settings\translist.ini
	if (newtransT != transT)
	{
		transT:= newtransT
		translist:=IniObj(A_ScriptDir "\settings\translist.ini").翻译
	}
	Tmp_Val := GetSelText()
	Tmp_Val = %Tmp_Val%
	if !Tmp_Val
	{
		SendRaw, ``
	return
	}
	for key, value in translist
	{
		if (Tmp_Val = key) or (Tmp_Val = key "s")
		{
			if InStr(value, "``r")
			{
				value := SubStr(value,1,-2)
				value := value "`r"
			}
			Send {text}%value%
		return
		}
	}
	SendRaw, ``
return