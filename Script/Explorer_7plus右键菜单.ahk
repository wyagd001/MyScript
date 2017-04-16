TriggerFromContextMenu(wParam, lParam){
	Gosub % wparam
	}
Return

1001:
	Gosub,显示隐藏文件
Return

1002:
	Gosub,文件扩展名切换
Return

/*
1003:
sleep,1000
send,#g
Return
*/

1007:
	sleep,500
	If Closewindow && FileExist(Closewindow)
		run, % "explorer.exe " Closewindow
	Else If LastClosewindow && FileExist(LastClosewindow)
		Run, % "explorer.exe " LastClosewindow
;msgbox % Closewindow "-" FileExist(Closewindow) "-" LastClosewindow "-" FileExist(LastClosewindow)
Return

regsvr32dll:
RegisterShellExtension(0)
Return

unregsvr32dll:
Msgbox, 4, Unregister Shell Extension?, WARNING: If you unregister the shell extension, 7plus will not be able`n to show context menu entries. Do this only If you have problems with the shell extension.`nDo you really want to do this?
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
	global  Vista7
	;SetWorkingDir %A_ScriptDir%
		If(Vista7 && !A_IsAdmin)
			uacrep := DllCall("shell32\ShellExecuteA", uint, 0, str, "RunAs", str, "regsvr32", str, "/s """ A_ScriptDir "\ShellExtension.dll""", str, A_ScriptDir, int, 1)
		else
		{
			run regsvr32 "%A_ScriptDir%\ShellExtension.dll"
}
		If(uacrep = 42 || !Vista7) ;UAC Prompt confirmed, application may run as admin
		{
			If(!Silent)
				MsgBox Shell extension successfully installed. Context menu entries defined in 7plus should now be visible.
		}
		else ;Always show error
			MsgBox ,%uacrep% Unable to install the context menu shell extension. Please grant Admin permissions!
	;SetWorkingDir %A_ScriptDir%\plugins\独立脚本\
}

UnregisterShellExtension(Silent=1)
{
	global  Vista7
		If(Vista7)
			uacrep := DllCall("shell32\ShellExecuteA", uint, 0, str, "RunAs", str, "regsvr32", str, "/s /u """ A_ScriptDir "\ShellExtension.dll""", str, A_ScriptDir, int, 1)
		else
			run regsvr32 /s /u "%A_ScriptDir%\ShellExtension.dll"

		If(uacrep = 42) ;UAC Prompt confirmed, application may run as admin
		{
			If(!Silent)
				MsgBox Shell extension successfully deinstalled. All 7plus context menu entries should now be gone.
		}
		else ;Always show error
			MsgBox Unable to deinstall the context menu shell extension. Please grant Admin permissions!
}