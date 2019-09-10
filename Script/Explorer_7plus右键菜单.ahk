TriggerFromContextMenu(wParam, lParam){
	Gosub % wparam
	}
Return

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

regsvr32dll:
	RegisterShellExtension(0)
	gosub savetoreg
Return

unregsvr32dll:
	Msgbox, 4, 注销外壳扩展吗?, 警告: 如果您注销外壳扩展, 7plus 将无法显示`n 上下文菜单项. 只有在外壳扩展有问题时才这样做.`n是否确定卸载外壳扩展?
	IfMsgbox Yes
	{
		UnregisterShellExtension(0)
		RegDelete, HKCU, Software\7plus\ContextMenuEntries
	}
Return

savetoreg:
	RegDelete, HKCU, Software\7plus\ContextMenuEntries

	LV_Delete()

	IniRead,num,%run_iniFile%,ContextMenu,num
	loop,%num%
	{
		ContextMenuId:= A_Index+1000
		IniRead,showmenu_%A_Index%,%run_iniFile%,%ContextMenuId%,showmenu
		LV_Add(showmenu_%A_Index% = 1 ? "Check" : "","", ContextMenuId,name_%A_Index%)
		If (showmenu_%A_Index% = 1)
		{
			IniRead,name_%A_Index%,%run_iniFile%,%ContextMenuId%,name
			IniRead,Directory_%A_Index%,%run_iniFile%,%ContextMenuId%,Directory
			IniRead,Description_%A_Index%,%run_iniFile%,%ContextMenuId%,Description
			IniRead,Submenu_%A_Index%,%run_iniFile%,%ContextMenuId%,Submenu
			IniRead,Extensions_%A_Index%,%run_iniFile%,%ContextMenuId%,FileTypes
			IniRead,DirectoryBackground_%A_Index%,%run_iniFile%,%ContextMenuId%,DirectoryBackground
			IniRead,Desktop_%A_Index%,%run_iniFile%,%ContextMenuId%,Desktop
			IniRead,SingleFileOnly_%A_Index%,%run_iniFile%,%ContextMenuId%,SingleFileOnly

			RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%ContextMenuId%, ID, %ContextMenuId%
			RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%ContextMenuId%, Name,% name_%A_Index%
			RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%ContextMenuId%, Description, % Description_%A_Index%
			RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%ContextMenuId%, Submenu, % Submenu_%A_Index%
			RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%ContextMenuId%, Extensions, % Extensions_%A_Index%
			RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%ContextMenuId%, Directory, % Directory_%A_Index%
			RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%ContextMenuId%, DirectoryBackground, % DirectoryBackground_%A_Index%
			RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%ContextMenuId%, Desktop, % Desktop_%A_Index%
			RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%ContextMenuId%, SingleFileOnly, % SingleFileOnly_%A_Index%
		}
	}
Return

RegisterShellExtension(Silent=1)
{
	If(Vista7)
	{
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, "regsvr32", str, "/s """ A_ScriptDir "\" (A_PtrSize=8 ? "ShellExtension_x64.dll" : "ShellExtension_x32.dll") """", str, A_ScriptDir, int, 1)
		If(uacrep = 42) ; UAC Prompt confirmed, application may run as admin
		{
			If(!Silent)
				MsgBox 外壳扩展已成功安装. 现在应该在资源管理器中可以看到 7plus 中定义的右键菜单了.
		}
		Else ; Always show error  
			MsgBox , % "无法安装右键菜单外壳扩展," (A_PtrSize=8 ? "ShellExtension_x64.dll" : "ShellExtension_x32.dll") "文件无法注册. 请授予管理员权限!"
	}
	Else ; XP
		run regsvr32 "%A_ScriptDir%\ShellExtension_x32.dll"
}

UnregisterShellExtension(Silent=1)
{
	If(Vista7)
{
		uacrep := DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, "regsvr32", str, "/s /u """ A_ScriptDir "\" (A_PtrSize=8 ? "ShellExtension_x64.dll" : "ShellExtension_x32.dll") """", str, A_ScriptDir, int, 1)
		If(uacrep = 42) ;UAC Prompt confirmed, application may run as admin
		{
			If(!Silent)
				MsgBox 外壳扩展已成功卸载. 现在资源管理器中 7plus 中定义的右键菜单应该消失了.
		}
		Else ;Always show error
			MsgBox % "无法卸载右键菜单外壳扩展," (A_PtrSize=8 ? "ShellExtension_x64.dll" : "ShellExtension_x32.dll") "文件无法卸载. 请授予管理员权限!"
}
	Else
		run regsvr32 /u "%A_ScriptDir%\ShellExtension_x32.dll"
}