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
TrayTip, 剪贴板,"%OutputVar%"已经复制到剪贴板。
SetTimer, RemoveTrayTip, 2500
}
Return
;#IfWinActive