1007:
	Sleep,500
	If CloseWindowList.Length()
	{
		if(GetKeyState("Shift"))
		{
			gosub,CloseWindowListMenuShow
			return
		}
		If (tmpCW :=CloseWindowList.Pop())
		{ 
			if FileExist(tmpCW) or  InStr(tmpCW, "::{")
				run, % "explorer.exe " tmpCW
		}
	}
	Else
	{
		If FileExist(LastClosewindow) or  InStr(LastClosewindow, "::{")
			Run, % "explorer.exe " LastClosewindow
	}
Return

7PlusMenu_最近关闭的窗口()
{
	section = 最近关闭的窗口
	defaultSet=
	( LTrim
ID = 1007
Name =重新打开关闭的窗口
Description =重新打开关闭的窗口
SubMenu =
FileTypes =
SingleFileOnly =0
Directory =0
DirectoryBackground =1
Desktop =1
showmenu =1
	)
IniWrite, % defaultSet, % 7PlusMenu_ProFile_Ini, % section
return
}