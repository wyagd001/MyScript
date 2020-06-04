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

	If(RegExMatch(dir,"i)^(\[|HKCU|HKCR|HKCC|HKU|HKLM|HKEY_)"))
	{
		f_OpenReg(dir)
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
			if !OpenButton_Cmd_Str2
			return
			else
			{
				RunNamedPipe(OpenButton_Cmd_Str2)
			return
			}
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
			f_OpenReg(OpenButton_Cmd_Str2)
		return
		}
		Else If (OpenButton_Cmd_Str1="转换")  
		{
			If (OpenButton_Cmd_Str2="UrlDecode")
			{
				If OpenButton_Cmd_Str3
				{
					q:=% UrlDecode(OpenButton_Cmd_Str3)          ;默认使用UTF-8编码转换
					settimer,sendq,-1000
				Return
				}
				Else
				{  ;复制到剪贴板的字符串使用GBK编码转换
					If Clipboard
					{
						q:=% UrlDecode(Clipboard,CP936)
						settimer,sendq,-1000
					Return
					}
					Return
				}
			}
			Else If (OpenButton_Cmd_Str2="UrlEncode")
			{
				If OpenButton_Cmd_Str3
				{
					q:=% UrlEncode(OpenButton_Cmd_Str3)      ;默认使用UTF-8编码转换
					settimer,sendq,-1000
				Return
				}
				Else
				{  ;复制到剪贴板的字符串使用GBK编码转换
					If Clipboard
					{
						q:=% UrlEncode(Clipboard,CP936)
						settimer,sendq,-1000
					Return
					}
					Return
				}
			}
			Else If (OpenButton_Cmd_Str2="10→16")
			{
				q:=% dec2hex(OpenButton_Cmd_Str3)
				settimer,sendq,-1000
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
				settimer,sendq,-1000
			Return
			}
			Else If (OpenButton_Cmd_Str2="公历→农历")
			{
				q:=% Date_GetLunarDate(OpenButton_Cmd_Str3?OpenButton_Cmd_Str3:A_YYYY A_MM A_DD)
				settimer,sendq,-1000
			Return
			}
			Else If (OpenButton_Cmd_Str2="简→繁")
			{
				q:=% jzf(OpenButton_Cmd_Str3)
				settimer,sendq,-1000
			Return
			}
			Else If (OpenButton_Cmd_Str2="繁→简")
			{
				q:=% fzj(OpenButton_Cmd_Str3)
				settimer,sendq,-1000
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
		If dir contains +,~,!,^,=,(,),{,},[,],/,<,>,|,;,:,*,%A_Space%,\,.
			goto g_search
		ErrorLevel = 0
		If % %dir%<>""
		{
			Run,% %Dir%,,UseErrorLevel
			If ErrorLevel
				temp_Error = 1
		}
		Else 
			temp_Error = 1
	}
	if temp_Error
		gosub g_search
Return

g_search:
	temp_Error = 0
	msgbox,3,搜索引擎选择,百度搜索点"是"，google点"否"
	Ifmsgbox yes     
		Run http://www.baidu.com/s?wd=%Dir% 
	Ifmsgbox no
		Run https://www.google.com.hk/search?hl=zh-CN&q=%Dir%
return

sendq:
	WinActivate,%apptitle%
	GuiControl,text,Dir,
	GuiControl,text,Dir,%q%
	q=
Return