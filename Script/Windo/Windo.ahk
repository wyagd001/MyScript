Windo_发送路径到对话框:
ControlSetText , edit1, %Windy_CurWin_FolderPath%, ahk_class #32770
return

Windo_窗口静音:
VA_SetAppMute(Windy_CurWin_Pid, !VA_GetAppMute(Windy_CurWin_Pid))
return

Windo_保存路径到windy收藏夹:
SplitPath,Windy_CurWin_FolderPath,menuname
iniwrite,%Windy_CurWin_FolderPath%,%A_ScriptDir%\Settings\Windy\主窗体\windy_Fav.ini,menu,%menuname%
return

Windo_括起来:
	Candy_Saved_ClipBoard := ClipboardAll
	StringSplit, kql_Arr, A_ThisMenuItem, %A_Space%
	GetSelText(0)
	send {del}{%kql_Arr1%}
	Send,^v
	send {%kql_Arr2%}
	Sleep, 500
	Clipboard := Candy_Saved_ClipBoard    
	Candy_Saved_ClipBoard =
Return

Windo_首字大写:
Candy_Saved_ClipBoard := ClipboardAll
Clipboard =
CandySel:=GetSelText()
	Loop, Parse, CandySel, %A_Space%_`,|;-！`.  
	{  
		; 计算分隔符的位置.  
		Position += StrLen(A_LoopField) + 1
		; 获取解析循环中找到的分隔符.  
		Delimiter := SubStr(CandySel, Position, 1)
		str1:= Format("{:T}", A_LoopField)
		out:=out . str1 . Delimiter 
	}  
	Clipboard :=out  
	Send,^v
	Sleep,500
	Clipboard := Candy_Saved_ClipBoard
	out :=Candy_Saved_ClipBoard:=Position:=""
Return