; 主窗口打开按钮运行输入的命令，网址，程序
openbutton:
	Gui, Submit, NoHide

	If !dir  ; dir为空返回
		Return

if changeComboBox=1
{
GuiControl, , dir, |%ComboBoxShowItems%
GuiControl,text,Dir,%dir%
changeComboBox=0
}

	If(RegExMatch(dir,"i)^(HKCU|HKCR|HKCC|HKU|HKLM|HKEY_)"))
	{
 jumptoregedit(dir)
	Return
	}

OpenButton_All_cmd:="@Cmd@|@ExeAhk@|@Proxy@|@regedit@|@转换@UrlDecode@|@转换@UrlEncode@|@转换@10→16@|@转换@16→10@|@转换@农历→公历@|@转换@公历→农历@|@转换@简→繁@|@转换@繁→简@"
 If RegExMatch(dir,"i)^\s*(" OpenButton_All_cmd ")\s*")
{
StringTrimLeft,dir,dir,1
arrOpenButton_Cmd_Str:=StrSplit(dir,"@"," `t")
;msgbox % Array_ToString(arrOpenButton_Cmd_Str)
OpenButton_Cmd_Str1:=arrOpenButton_Cmd_Str[1]
OpenButton_Cmd_Str2:=arrOpenButton_Cmd_Str[2]
OpenButton_Cmd_Str3:=arrOpenButton_Cmd_Str[3]
 If (OpenButton_Cmd_Str1="Cmd")
{
Run, %comspec% /k "%OpenButton_Cmd_Str2%"
		Return
}
Else If (OpenButton_Cmd_Str1="ExeAhk")  
{
		; https://autohotkey.com/board/topic/23575-how-to-run-dynamic-script-through-a-pipe/
		ptr := A_PtrSize ? "Ptr" : "UInt"
		char_size := A_IsUnicode ? 2 : 1
		pipe_name := "运行Ahk命令"
; Before reading the file, AutoHotkey calls GetFileAttributes(). This causes
; the pipe to close, so we must create a second pipe for the actual file contents.
; Open them both before starting AutoHotkey, or the second attempt to open the
; "file" will be very likely to fail. The first created instance of the pipe
; seems to reliably be "opened" first. Otherwise, WriteFile would fail.
		pipe_ga := CreateNamedPipe(pipe_name, 2)
		pipe := CreateNamedPipe(pipe_name, 2)
		If (pipe=-1 or pipe_ga=-1) {
			MsgBox CreateNamedPipe failed.
			Return
		}

		Run, "%A_AhkPath%" "\\.\pipe\%pipe_name%"

; Wait for AutoHotkey to connect to pipe_ga via GetFileAttributes().
		DllCall("ConnectNamedPipe",ptr,pipe_ga,ptr,0)
; This pipe is not needed, so close it now. (The pipe instance will not be fully
; destroyed until AutoHotkey also closes its handle.)
		DllCall("CloseHandle",ptr,pipe_ga)
; Wait for AutoHotkey to connect to open the "file".
		DllCall("ConnectNamedPipe",ptr,pipe,ptr,0)

; AutoHotkey reads the first 3 bytes to check for the UTF-8 BOM "???". If it is
; NOT present, AutoHotkey then attempts to "rewind", thus breaking the pipe.
		OpenButton_Cmd_Str2 := (A_IsUnicode ? chr(0xfeff) : chr(239) chr(187) chr(191)) OpenButton_Cmd_Str2

		If !DllCall("WriteFile",ptr,pipe,"str",OpenButton_Cmd_Str2,"uint",(StrLen(OpenButton_Cmd_Str2)+1)*char_size,"uint*",0,ptr,0)
			MsgBox WriteFile failed: %ErrorLevel%/%A_LastError%
		DllCall("CloseHandle",ptr,pipe)
	Return
	}
Else If (OpenButton_Cmd_Str1="Proxy")  
	{
		If OpenButton_Cmd_Str2
		{
			CF_RegWrite("REG_SZ","HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyServer",OpenButton_Cmd_Str2)
			If CF_regread("HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","Proxyenable") = 1
			{
				CF_RegWrite("REG_DWORD","HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","Proxyenable",0)
				MsgBox,已取消IE代理！
			}
			Else If CF_regread("HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","Proxyenable") = 0
			{
				CF_RegWrite("REG_DWORD","HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","Proxyenable",1)
				MsgBox, IE代理已设置为 ”%OpenButton_Cmd_Str2%”！要取消代理，请再次运行本命令。
			}
			dllcall("wininet\InternetSetOptionW","int","0","int","39","int","0","int","0")
			dllcall("wininet\InternetSetOptionW","int","0","int","37","int","0","int","0")
			Return
		}
		Else
		{
			If CF_regread("HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","Proxyenable") = 1
			{
				CF_RegWrite("REG_DWORD","HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","Proxyenable",0)
				MsgBox,已取消IE代理！
			}
			Else If CF_regread("HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","Proxyenable") = 0
			{
				ProxyServer := CF_regread("HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyServer")
				if ProxyServer
				{
					CF_RegWrite("REG_DWORD","HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","Proxyenable",1)
					MsgBox, IE代理已设置为“%ProxyServer%”！要取消代理，请再次运行本命令。
				}
				else
				{
				MsgBox,请输入代理服务器IP:端口号。
				}
			}
			dllcall("wininet\InternetSetOptionW","int","0","int","39","int","0","int","0")
			dllcall("wininet\InternetSetOptionW","int","0","int","37","int","0","int","0")
			Return
		}
	}
Else If (OpenButton_Cmd_Str1="regedit")  
{
jumptoregedit(OpenButton_Cmd_Str2)
return
}
Else If (OpenButton_Cmd_Str1="转换")  
{
If (OpenButton_Cmd_Str2="UrlDecode")
{
		If OpenButton_Cmd_Str3
		{
			q:=% UrlDecode(OpenButton_Cmd_Str3)          ;默认使用UTF-8编码转换
			settimer,sendq,-2000
			Return
		}
		Else
		{  ;复制到剪贴板的字符串使用GBK编码转换
			If Clipboard
			{
				q:=% UrlDecode(Clipboard,CP936)
				settimer,sendq,-2000
				Return
			}
			Else
				Return
		}
}
Else If (OpenButton_Cmd_Str2="UrlEncode")
	{
		If OpenButton_Cmd_Str3
		{
			q:=% UrlEncode(OpenButton_Cmd_Str3)      ;默认使用UTF-8编码转换
			settimer,sendq,-2000
			Return
		}
		Else
		{  ;复制到剪贴板的字符串使用GBK编码转换
		If Clipboard
		{
			q:=% UrlEncode(Clipboard,CP936)
			settimer,sendq,-2000
			Return
		}
		Else
			Return
		}
	}
Else If (OpenButton_Cmd_Str2="10→16")
		{
			q:=% dec2hex(OpenButton_Cmd_Str3)
			settimer,sendq,-2000
			Return
		}
Else If (OpenButton_Cmd_Str2="16→10")
		{
			q:=% hex2dec(OpenButton_Cmd_Str3)
			settimer,sendq,-2000
			Return
		}
Else If (OpenButton_Cmd_Str2="农历→公历")
		{
			q:=% Date_GetDate(OpenButton_Cmd_Str3)
			settimer,sendq,-2000
			Return
		}
Else If (OpenButton_Cmd_Str2="公历→农历")
		{
			q:=% Date_GetLunarDate(OpenButton_Cmd_Str3?OpenButton_Cmd_Str3:A_YYYY A_MM A_DD)
			settimer,sendq,-2000
			Return
		}
Else If (OpenButton_Cmd_Str2="简→繁")
		{
			q:=% jzf(OpenButton_Cmd_Str3)
			settimer,sendq,-2000
			Return
		}
Else If (OpenButton_Cmd_Str2="繁→简")
		{
			q:=% fzj(OpenButton_Cmd_Str3)
			settimer,sendq,-2000
			Return
		}
}
}

	if (favorites_link=1)
	{
		favorites_link=0
		RunFileName=%dir%.lnk
		run, % RunFileName,%A_ScriptDir%\favorites\ , UseErrorLevel
		if ErrorLevel
		{
			Loop, Files, %A_ScriptDir%\favorites\*.*,D
			{
				If fileexist(A_LoopFileFullPath "\" RunFileName)
				{
					temp_runhistory=1
					run, % A_LoopFileFullPath "\" RunFileName, ,UseErrorLevel
					return
				}
			}
		return
		}
		else 
			{
				temp_runhistory=1
				return
			}
	}

	Transform,dir,Deref,%Dir%
	Run,%Dir%,,UseErrorLevel
	If ErrorLevel
	{
		ErrorLevel = 0
		If dir contains +,~,!,^,=,(,),{,},[,],/,<,>,|,;,:,*,%A_Space%,\,.
		{
			msgbox,3,搜索引擎选择,百度搜索点"是"，google点"否"
			Ifmsgbox yes     
				Run http://www.baidu.com/s?wd=%Dir% 
			Ifmsgbox no
				Run https://www.google.com.hk/search?hl=zh-CN&q=%Dir%
			Else
				Return
		Return
		}
		If % %dir%<>""
		{
			Run,% %Dir%,,UseErrorLevel
			If ErrorLevel
			{
				msgbox,3,搜索引擎选择,百度搜索点"是"，google点"否"
				Ifmsgbox yes     
					Run http://www.baidu.com/s?wd=%Dir% 
				Ifmsgbox no
					Run https://www.google.com.hk/search?hl=zh-CN&q=%Dir%
				Else
					Return
			Return
			}
		}
		Else 
		{
			msgbox,3,搜索引擎选择,百度搜索点"是"，google点"否"
			Ifmsgbox yes     
				Run http://www.baidu.com/s?wd=%Dir% 
			Ifmsgbox no
				Run https://www.google.com.hk/search?hl=zh-CN&q=%Dir%
			Else
				Return
		Return
		}
	}
Return

CreateNamedPipe(Name, OpenMode=3, PipeMode=0, MaxInstances=255)
{
	global ptr
Return DllCall("CreateNamedPipe","str","\\.\pipe\" Name,"uint",OpenMode
        ,"uint",PipeMode,"uint",MaxInstances,"uint",0,"uint",0,ptr,0,ptr,0)
}

jumptoregedit(dir)
{
; 替换字串中第一个“, ”为"\"
	StringReplace,dir,dir,`,%A_Space%,\
; 替换字串中第一个“,”为"\"
	StringReplace,dir,dir,`, ,\
	IfInString, dir,HKLM
	{
		StringTrimLeft, cutdir, dir, 4
		dir := "HKEY_LOCAL_MACHINE" . cutdir
	}
	IfInString, dir,HKCR
	{
		StringTrimLeft, cutdir, dir, 4
		dir := "HKEY_CLASSES_ROOT" . cutdir
	}
	IfInString, dir,HKCC
	{
		StringTrimLeft, cutdir, dir, 4
		dir := "HKEY_CURRENT_CONFIG" . cutdir
	}
	IfInString, dir,HKCU
	{
		StringTrimLeft, cutdir, dir, 4
		dir := "HKEY_CURRENT_USER" . cutdir
	}
	IfInString, dir,HKU
	{
		StringTrimLeft, cutdir, dir, 3
		dir := "HKEY_USERS" . cutdir
	}
; 将字串中的所有"＼"(全角) 替换为“\"(半角)
	StringReplace,dir,dir,＼,\,All
	StringReplace,dir,dir,%A_Space%\,\,All
	StringReplace,dir,dir,\%A_Space%,\,All

; 将字串中的所有“\\”替换为“\”
	StringReplace,dir,dir,\\,\,All

	dir:=LTrim(dir, "[")
	dir:=RTrim(dir, "]")

	IfWinExist, 注册表编辑器 ahk_class RegEdit_RegEdit
	{
		IfNotInString, dir, 计算机\
		dir := "计算机\" . dir
		WinActivate, 注册表编辑器
		ControlGet, hwnd, hwnd, , SysTreeView321, 注册表编辑器
		TVPath_Set(hwnd, dir, matchPath)
	}
	Else
	{
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, %dir%
		Run, regedit.exe -m
	}
return
}

sendq:
WinActivate,%apptitle%
GuiControl,text,Dir,
GuiControl,text,Dir,%q%
q=
Return