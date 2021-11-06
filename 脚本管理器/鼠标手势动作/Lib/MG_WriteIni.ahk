MG_WriteIni(section := "", defaultSet := "")
{
	IniWrite, % defaultSet, % A_ScriptDir "\..\鼠标手势.ini", % section
return
}