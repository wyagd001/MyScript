:*:@zhushi::
zhushi_fun()
{
WinGetTitle, h_hzcWin,A
if InStr(h_hzcWin, ".js") or InStr(h_hzcWin, ".cpp") or InStr(h_hzcWin, ".css")
	send //
if InStr(h_hzcWin, ".vbs")
	send '
if InStr(h_hzcWin, ".bat")
	send ::
if InStr(h_hzcWin, ".reg") or InStr(h_hzcWin, ".ini") or InStr(h_hzcWin, ".inf") or InStr(h_hzcWin, ".ahk") or InStr(h_hzcWin, ".au3")
	Send `;
if InStr(h_hzcWin, ".lst") or InStr(h_hzcWin, ".py") or InStr(h_hzcWin, ".sh") or InStr(h_hzcWin, "hosts")
	send {#}
return
}