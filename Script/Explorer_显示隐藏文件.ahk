显示隐藏文件:
	RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
	If HiddenFiles_Status = 2
	{
		Traytip,通知,显示隐藏文件,,1
		SetTimer,RemoveTraytip, 2000
		RegWrite REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, ShowSuperHidden, 00000001
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
	}
	Else
	{
		Traytip,通知,隐藏文件,,1
		SetTimer,RemoveTraytip, 2000
		RegWrite REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, ShowSuperHidden, 00000000
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
	}
	; 强制刷新
	Send, {F5}

	If (A_OSVersion="WIN_XP"){
			; 发送刷新菜单 XP有效，在Win_7无效
		PostMessage, 0x111, 28931,,,ahk_class Progman
		PostMessage, 0x111, 28931,,,ahk_class WorkerW
		PostMessage, 0x111, 28931,,,ahk_class CabinetWClass
		PostMessage, 0x111, 28931,,,ahk_class ExploreWClass
	}
	else{
		; 发送刷新菜单 Win_7
		PostMessage, 0x111, 41504,,,ahk_class Progman
		PostMessage, 0x111, 41504,,,ahk_class WorkerW
		PostMessage, 0x111, 41504,,,ahk_class CabinetWClass
		PostMessage, 0x111, 41504,,,ahk_class ExploreWClass
	}
	; 刷新桌面
	DllCall("Shell32\SHChangeNotify", "uint", 0x8000000, "uint", 0x1000, "uint", 0, "uint", 0)
Return

文件扩展名切换:
	RegRead, FileExt_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced,HideFileExt
	If FileExt_Status = 0
	{
		Traytip,通知,隐藏文件扩展名,,1
		SetTimer,RemoveTraytip, 2000
		RegWrite REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 00000001
	}
	Else
	{
		Traytip,通知,显示文件扩展名,,1
		SetTimer,RemoveTraytip, 2000
		RegWrite REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 00000000
}
	; 强制刷新
	Send, {F5}

	If (A_OSVersion="WIN_XP"){
		; 发送刷新菜单 XP有效，在Win_7无效
		PostMessage, 0x111, 28931,,,ahk_class Progman
		PostMessage, 0x111, 28931,,,ahk_class WorkerW
		PostMessage, 0x111, 28931,,,ahk_class CabinetWClass
		PostMessage, 0x111, 28931,,,ahk_class ExploreWClass
	}
	else{
		; 发送刷新菜单 Win_7
		PostMessage, 0x111, 41504,,,ahk_class Progman
		PostMessage, 0x111, 41504,,,ahk_class WorkerW
		PostMessage, 0x111, 41504,,,ahk_class CabinetWClass
		PostMessage, 0x111, 41504,,,ahk_class ExploreWClass
	}
	; 刷新桌面
	DllCall("Shell32\SHChangeNotify", "uint", 0x8000000, "uint", 0x1000, "uint", 0, "uint", 0)
Return

; 定时移除TrayTiP
RemoveTrayTip:
	SetTimer, RemoveTrayTip, Off
	TrayTip
return