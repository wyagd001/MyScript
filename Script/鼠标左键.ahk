~LButton::
CoordMode, Mouse, Screen
MouseGetPos, lastx, lasty, id
if !Auto_mouseclick
return
WinGetClass, Class, ahk_id %id%
isF:=IsFullscreen("A",false,false)
; 屏幕左上角点击按下快捷键
If(x=0 && y=0 && !WinActive("ahk_class Flip3D") && !isF)   
{
	if (A_OSVersion="WIN_7")
		Send ^#{Tab}   ;rundll32.exe DwmApi #105
	else
		Send #{Tab}
}
; 屏幕右下角点击打开任务管理器
If(lastx>=A_ScreenWidth - 1.5 and lasty>=A_ScreenHeight - 60 and lasty<=A_ScreenHeight - 30 && !isF)
{
	;if (class = "Progman" || class = "WorkerW")
	Run taskmgr.exe
}
; chrome 标签页双击关闭
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
				Send, ^w  ; 关闭标签页
			return
			}
		}
	}
}
Return