一键隐藏窗口:   ; Winhide 再次显示窗口时会将窗口在任务栏中的图标按钮放至在最右边(同一程序的组中的最右边)
if !hidewin_hwnd
{
		WinGet, hidewin_hwnd, ID, A
		Winhide, ahk_id %hidewin_hwnd%
}
else
{
		WinShow, ahk_id %hidewin_hwnd%
		hidewin_hwnd := ""
}
return