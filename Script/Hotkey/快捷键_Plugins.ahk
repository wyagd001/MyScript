; 文件夹中以文件名来搜索
文件夹中搜索文件:
Tmp_Val := GetCurrentFolder()
If(Tmp_Val)
{
	clipmonitor := 0
	BackUp_ClipBoard := ClipboardAll    ; 备份剪贴板
	Clipboard =                                  ; 清空剪贴板
	Clipboard := Tmp_Val
	run "%A_AhkPath%" "%A_ScriptDir%\Plugins\文件夹中搜索文件.ahk"
	Sleep, 3000
	Clipboard := BackUp_ClipBoard        ; 还原剪贴板
	Sleep, 50
	clipmonitor := 1
	BackUp_ClipBoard =                          ; 清除变量内容
}
Return

; 搜索文件夹中的某种类型的文件内容是否包含字符
文件中查找字符:
Tmp_Val := GetCurrentFolder()
If CF_IsFolder(Tmp_Val)
{
	IniWrite, % Tmp_Val, %run_iniFile%, 文件中查找字符, 路径
	Run "%A_AhkPath%" "%A_ScriptDir%\Plugins\文件中查找字符.ahk"
}
Else
	Run "%A_AhkPath%" "%A_ScriptDir%\Plugins\文件中查找字符.ahk"
Return

; 调用迅雷下载
新版迅雷开放引擎下载:
IfInString, Clipboard, ://
{
	Run,"%ahklu%" "%A_ScriptDir%\Plugins\新版迅雷开放引擎下载.ahk" %Clipboard%
}
Else
{
	DURL := GetSelText()
	Run,%ahklu% "%A_ScriptDir%\Plugins\新版迅雷开放引擎下载.ahk" %DURL%
	DURL = 
}
Return