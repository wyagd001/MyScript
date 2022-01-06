1007:
Sleep, 100

If CloseWindowList_Arr.Length()
{
	if(GetKeyState("Shift"))
	{
		gosub, CloseWindowListMenuShow
	return
	}
	If (Tmp_CW := CloseWindowList_Arr.Pop())
	{
		if FileExist(Tmp_CW) or InStr(Tmp_CW, "::{")
		{
			;run, % "explorer.exe " Tmp_CW
			run, % Tmp_CW
		}
		else
		{
			Tmp_CW := CloseWindowList_Arr.Pop()
			if FileExist(Tmp_CW) or InStr(Tmp_CW, "::{")
				run, % Tmp_CW
		}
	}
}
Else
{
	If FileExist(LastClosewindow) or InStr(LastClosewindow, "::{")
		;Run, % "explorer.exe " LastClosewindow
		Run, % LastClosewindow
}
Return

7PlusMenu_最近关闭的窗口()
{
	section = 最近关闭的窗口
	defaultSet=
	( LTrim
		ID = 1007
		Name = 重新打开关闭的窗口
		Description = 重新打开关闭的窗口
		SubMenu =
		FileTypes =
		SingleFileOnly = 0
		Directory = 0
		DirectoryBackground = 1
		Desktop = 1
		showmenu = 1
	)
	IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}