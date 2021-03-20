~LButton::
CoordMode, Mouse, Screen
MouseGetPos, lastx, lasty, id
WinGetClass, Class, ahk_id %id%
isF:=IsFullscreen("A",false,false)
If(x=0 && y=0 && !WinActive("ahk_class Flip3D") && !isF)
{
	if (A_OSVersion="WIN_7")
		Send ^#{Tab}   ;rundll32.exe DwmApi #105
	else
		Send #{Tab}
}
If(lastx>=A_ScreenWidth - 1.5 and lasty>=A_ScreenHeight - 60 and lasty<=A_ScreenHeight - 30 && !isF)
{
	;if (class = "Progman" || class = "WorkerW")
	Run taskmgr.exe
}
if WinActive("ahk_class Chrome_WidgetWin_1") 
{
	if (lastyA!=lasty)
	{
		lastyA:=lasty
	return
	}
	WinGet, state, MinMax
	if (state != 1) {
		Return
	}
	if (lasty <= 34 && lasty=lastyA){
		if (A_ThisHotkey = A_PriorHotkey && A_TimeSincePriorHotkey < 300) {
			Acc := Acc_ObjectFromPoint(ChildId)
			AccRole :=Acc_GetRoleText(Acc.accRole(ChildId))
			;tooltip % AccRole
			if(AccRole = "文字")
			{
				Send, ^w  ; 关闭便签页
			return
			}
		}
	}
}
Return