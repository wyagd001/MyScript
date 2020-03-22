TriggerFromContextMenu(wParam, lParam){
	Gosub % wparam
	}
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
	; 首先删除所有菜单在注册表中的条目
	RegDelete, HKCU, Software\7plus\ContextMenuEntries

	Loop, %A_ScriptDir%\Script\7plus右键菜单\*.ahk
	{
		StringTrimRight, FileName, A_LoopFileName, 4
		IniRead,showmenu,%7PlusMenu_ProFile_Ini%,%FileName%,showmenu
		IniRead,7Plus_id,%7PlusMenu_ProFile_Ini%,%FileName%,id
		If (showmenu = 1) && 7Plus_id/7Plus_id
		{
			IniRead,name,%7PlusMenu_ProFile_Ini%,%FileName%,name
			IniRead,Description,%7PlusMenu_ProFile_Ini%,%FileName%,Description
			IniRead,Submenu,%7PlusMenu_ProFile_Ini%,%FileName%,Submenu
			IniRead,Extensions,%7PlusMenu_ProFile_Ini%,%FileName%,FileTypes
			IniRead,SingleFileOnly,%7PlusMenu_ProFile_Ini%,%FileName%,SingleFileOnly,0
			IniRead,Directory,%7PlusMenu_ProFile_Ini%,%FileName%,Directory,0
			IniRead,DirectoryBackground,%7PlusMenu_ProFile_Ini%,%FileName%,DirectoryBackground,0
			IniRead,Desktop,%7PlusMenu_ProFile_Ini%,%FileName%,Desktop,0

			RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%7Plus_id%, ID, %7Plus_id%
			RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%7Plus_id%, Name,% name
			RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%7Plus_id%, Description, % Description
			RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%7Plus_id%, Submenu, % Submenu
			RegWrite, REG_SZ, HKCU, Software\7plus\ContextMenuEntries\%7Plus_id%, Extensions, % Extensions
			RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%7Plus_id%, SingleFileOnly, % SingleFileOnly
			RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%7Plus_id%, Directory, % Directory
			RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%7Plus_id%, DirectoryBackground, % DirectoryBackground
			RegWrite, REG_DWORD, HKCU, Software\7plus\ContextMenuEntries\%7Plus_id%, Desktop, % Desktop
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