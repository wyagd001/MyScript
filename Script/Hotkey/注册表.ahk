;#IfWinActive,ahk_class RegEdit_RegEdit
;!x::
注册表复制路径:
CopyTvPath:
ControlGet, CTreeView, hwnd, , SysTreeView321, ahk_id %hdialogwin%
if (CTreeView != hTreeView)
{
	Gui,DialogTv:Destroy
	return
}
ret:=TVPath_Get(hTreeView, outPath)
if( ret = "")
{
	If WinActive("ahk_class RegEdit_RegEdit") or WinExist("ahk_class RegEdit_RegEdit")
	{
		StringGetPos, hpos, outPath, HKEY
		StringTrimLeft, OutputVar, outPath, hpos
		clipboard := OutputVar
		CF_Traytip("剪贴板", OutputVar " 已经复制到剪贴板。", 2500)
	}
	else
		msgbox % outPath
}
Return
;#IfWinActive