;文件夹中以文件名来搜索
文件夹中搜索文件:
pppp:=GetCurrentFolder()
If(pppp)
{
	Old_ClipBoard := ClipboardAll    ;备份剪贴板
	Clipboard =                                  ;清空剪贴板
	Clipboard := pppp
	run "%A_AhkPath%" "%A_ScriptDir%\Plugins\文件夹中搜索文件.ahk"
	Sleep,3000
	Clipboard := Old_ClipBoard        ;还原剪贴板
	Old_ClipBoard =                          ;清除变量内容
}
Return

;搜索文件夹中的某种类型的文件内容是否包含字符
文件中查找字符:
pppp:=GetCurrentFolder()
If InStr(FileExist(pppp), "D")
{
	IniWrite, % pppp, %run_iniFile%, 文件中查找字符, 路径
	Run "%A_AhkPath%" "%A_ScriptDir%\Plugins\文件中查找字符.ahk"
}
Else
	Run "%A_AhkPath%" "%A_ScriptDir%\Plugins\文件中查找字符.ahk"
Return

;调用迅雷下载
新版迅雷开放引擎下载:
IfInString, Clipboard,://
{
	Run,"%A_AhkPath%" "%A_ScriptDir%\Plugins\新版迅雷开放引擎下载.ahk" %Clipboard%
}
Else
{
	Old_ClipBoard := ClipboardAll
	Send, ^c
	Clipwait
	Run,%A_AhkPath% "%A_ScriptDir%\Plugins\新版迅雷开放引擎下载.ahk" %Clipboard%
	Clipboard := Old_ClipBoard
	Old_ClipBoard = 
}
Return