1001:
	f_ToggleHidden(1)
Return

1002:
	f_ToggleFileExt(1)
Return

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

1012:
SetTimer,八个收藏的文件夹菜单,-200
Return

1013:
SetTimer,Windy,-200
Return