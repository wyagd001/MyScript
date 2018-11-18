_TrayEvent:
  XWN_FocusFollowsMouse := !XWN_FocusFollowsMouse
IniRead,Auto_Raise,%run_iniFile%,功能开关,Auto_Raise
IniRead,hover_any_window,%run_iniFile%,自动激活,hover_any_window
  If(Auto_Raise=1 && hover_any_window=1)
    Msgbox,,提示,已在“选项→自动激活→窗口自动激活”中自动启用该功能。,5
  Else
  {
    Gosub, _ApplySettings
    Gosub, _MenuUpdate
  }
Return

_MenuUpdate:
	If ( XWN_FocusFollowsMouse )
		Menu, addf, Check, 自动激活窗口(临时)
	Else
		Menu, addf, UnCheck, 自动激活窗口(临时)
Return

_ApplySettings:
	If ( XWN_FocusFollowsMouse )
		SetTimer, XWN_FocusHandler, 1000
	Else
		SetTimer, XWN_FocusHandler, Off
Return

XWN_FocusHandler:
	CoordMode, Mouse, Screen
	MouseGetPos, XWN_MouseX, XWN_MouseY, XWN_WinID
	If ( !XWN_WinID )
		Return

	If ( (XWN_MouseX != XWN_MouseOldX) or (XWN_MouseY != XWN_MouseOldY) )
	{
		IfWinNotActive, ahk_id %XWN_WinID%
			XWN_FocusRequest = 1
		Else
			XWN_FocusRequest = 0
		XWN_MouseOldX := XWN_MouseX
		XWN_MouseOldY := XWN_MouseY
		XWN_MouseMovedTickCount := A_TickCount
	}
	Else
		If ( XWN_FocusRequest and (A_TickCount - XWN_MouseMovedTickCount > 500) )
		{
			WinGetClass, XWN_WinClass, ahk_id %XWN_WinID%
			If ( XWN_WinClass = "Progman" )
				Return

			WinGet, XWN_WinStyle, Style, ahk_id %XWN_WinID%
			If ( (XWN_WinStyle & 0x80000000) and !(XWN_WinStyle & 0x4C0000) )
				Return
			IfWinNotActive, ahk_id %XWN_WinID%
				WinActivate, ahk_id %XWN_WinID%
			XWN_FocusRequest = 0
		}
Return

runwithsys:
run_with_sys := !run_with_sys
IniWrite,%run_with_sys%,%run_iniFile%,功能开关,run_with_sys

	If ( run_with_sys=1 )
	{
		Menu, addf, Check, 开机启动
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Run, Run - Ahk, "%A_AhkPath%" "%A_ScriptFullPath%"
		}
	Else
	{
		Menu, addf, UnCheck, 开机启动
		RegDelete, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Run, Run - Ahk
		}
Return

AutoSaveDeskIcons:
Auto_SaveDeskIcons := !Auto_SaveDeskIcons
IniWrite,%Auto_SaveDeskIcons%,%run_iniFile%,功能开关,Auto_SaveDeskIcons
If  Auto_SaveDeskIcons=1
	Menu, addf, Check, 启动时记忆桌面图标
	Else
	Menu, addf, UnCheck, 启动时记忆桌面图标
Return

smartchooserbrowser:
  smartchooserbrowser := !smartchooserbrowser
  IniWrite,%smartchooserbrowser%,%run_iniFile%,功能开关,smartchooserbrowser
  If  smartchooserbrowser=1
  {
	  Menu, addf, Check, 智能浏览器
	  writeahkurl()
	}
	Else
	{
	  Menu, addf, UnCheck, 智能浏览器
	  delahkurl()
	}
Return

/*
编译的原因：将ahk写入注册表时，某些软件在打开网页时，调用不正确，不会调用ahk(绕过)，会直接打开浏览器。编译后会调用exe文件打开网页，所以编译为exe文件后会稳定些。
资源管理器搜索文件： 浏览器.exe “? 搜索词”
			所以要将%1% 添加 双引号  即 qq = "%1%"
常见写入注册表失败原因  360锁定了浏览器
*/

writeahkurl(){
/*
appurl= "%A_AhkPath%" "%A_ScriptDir%\smartchooserbrowser.ahk" "`%1"

RegRead AhkURL, HKCR, Ahk.URL\shell\open\command
IfNotInString,AhkURL,smartchooserbrowser.ahk
{
	RegWrite, REG_SZ, HKCR, Ahk.URL
	RegWrite, REG_SZ, HKCR, Ahk.URL\shell,,open
	RegWrite, REG_SZ, HKCR, Ahk.URL\shell\open\command, ,%appurl%
}
*/

  appurl= "%A_ScriptDir%\Bin\smartchooserbrowser.exe" "`%1"

  RegRead AhkURL, HKCR, Ahk.URL\shell\open\command
  IfNotInString,AhkURL,smartchooserbrowser.exe
  {
	  RegWrite, REG_SZ, HKCR, Ahk.URL
	  RegWrite, REG_SZ, HKCR, Ahk.URL\shell,,open
	  RegWrite, REG_SZ, HKCR, Ahk.URL\shell\open\command, ,%appurl%
  }

  ; 检查是否存在备份，若不存在则读取系统默认（防止意外退出）
  RegRead old_FTP, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice, URL.LastFound
if ErrorLevel
	RegRead old_FTP, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice, Progid

  RegRead old_HTTP, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice, URL.LastFound
if ErrorLevel
	RegRead old_HTTP, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice, Progid

  RegRead old_HTTPS, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice, URL.LastFound
if ErrorLevel
	RegRead old_HTTPS, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice, Progid

  ; 写入备份设置（防止意外退出）
  RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice, URL.LastFound, %old_FTP%
  RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice, URL.LastFound, %old_HTTP%
  RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice, URL.LastFound, %old_HTTPS%

  ; 设置临时键值
  RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice, Progid, Ahk.URL
  RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice, Progid, Ahk.URL
  RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice, Progid, Ahk.URL
}


delahkurl()
{
  RegRead old_FTP, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice, URL.LastFound
  RegRead old_HTTP, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice, URL.LastFound
  RegRead old_HTTPS, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice, URL.LastFound

  RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice, Progid, %old_FTP%
  RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice, Progid, %old_HTTP%
  RegWrite REG_SZ, HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice, Progid, %old_HTTPS%

  ; 删除备份设置
  RegDelete HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\ftp\UserChoice, URL.LastFound
  RegDelete HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice, URL.LastFound
  RegDelete HKCU, Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice, URL.LastFound
}
