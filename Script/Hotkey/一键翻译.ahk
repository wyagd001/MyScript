$`::
	Tmp_Val := GetSelText(,,,0.1)
	Tmp_Val := Trim(Tmp_Val, OmitChars := " `t`r`n")
	if !Tmp_Val
	{
		SendRaw, ``
	return
	}
	FileGetTime, newtransT, %A_ScriptDir%\settings\translist.ini
	if (newtransT != transT)
	{
		transT := newtransT
		translist := IniObj(A_ScriptDir "\settings\translist.ini").翻译
	}
	Tmp_Val = %Tmp_Val%
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