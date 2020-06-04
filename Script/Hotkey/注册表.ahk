;#IfWinActive,ahk_class RegEdit_RegEdit
;!x::
注册表复制路径:
ControlGet, hwnd, hwnd, , SysTreeView321,注册表编辑器
ret:=TVPath_Get(hwnd, outPath)
if( ret = "")
{
StringGetPos,hpos,outPath,HKEY
StringTrimLeft, OutputVar, outPath, hpos
clipboard := OutputVar
CF_Traytip("剪贴板", OutputVar " 已经复制到剪贴板。", 2500)
}
Return
;#IfWinActive

/*
q::
ControlGet, hwnd, hwnd, , SysTreeView321,A
ret:=TVPath_Get(hwnd, outPath)
if( ret = "")
{
StringGetPos,hpos,outPath,HKEY
StringTrimLeft, OutputVar, outPath, hpos
clipboard := OutputVar
CF_Traytip("剪贴板", OutputVar "已经复制到剪贴板。", 2500)
}
return
*/