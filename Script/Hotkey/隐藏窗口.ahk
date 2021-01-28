一键隐藏窗口:
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