~LButton::
CoordMode, Mouse, Screen
MouseGetPos, lastx, lasty, id, ContName
If(Auto_Raise = 1)
	stophovering(2)
if !Auto_mouseclick
	return
WinGetClass, Class, ahk_id %id%
isF := IsFullscreen("A", false, false)
;ToolTip % (lastx <= 0) ", " (lasty <= 32) ", " !WinActive("ahk_class Flip3D") ", " !isF ", " A_OSVersion
; 屏幕左上角点击按下快捷键
If (lastx <= 0) && (lasty <= 32) && !WinActive("ahk_class Flip3D") && !isF   
{
	if (A_OSVersion = "WIN_7")
		Send ^#{Tab}   ;rundll32.exe DwmApi #105
	else
	{
		Sleep 300
		WinClose ahk_class #32768
		Sleep 400
		Send #{Tab}
	}
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
	if (lastyA != lasty)
	{
		lastyA := lasty
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
			if(AccRole = "文字") or (AccRole = "窗格")
			{
				Send, ^w  ; 关闭标签页
			return
			}
		}
	}
}
else if WinActive("ahk_class WinRarWindow")
{
	CoordMode, Mouse, Window
	MouseGetPos, OutputVarX, OutputVarY
	PixelGetColor, OutputVarColor, %OutputVarX%, %OutputVarY%, RGB
	;tooltip % A_PriorHotKey "-" A_TimeSincePriorHotkey "-" OutputVarColor "-" OutputVarControl "-" OutputVarX
	if (A_PriorHotKey = "~LButton" and A_TimeSincePriorHotkey < 400) and (OutputVarColor = "0xFFFFFF")
	; 判定是否点击的点是白色
		send {backspace}
	; 如果是则发送backspace键
	;tooltip % OutputVarColor " - " A_TimeSincePriorHotkey " - " A_PriorHotKey
	return
}
else if WinActive("ahk_class SciTEWindow")
{
	if (ContName = "SciTeTabCtrl1"){
		if (A_ThisHotkey = A_PriorHotkey && A_TimeSincePriorHotkey < 300) {
			;tooltip % lasty
			Send, ^w  ; 关闭标签页
			return
		}
	}
}
else if WinActive("ahk_class CabinetWClass") && !Qt
{
	CoordMode, Mouse, Window
	MouseGetPos, OutputVarX, OutputVarY
	PixelGetColor, OutputVarColor, %OutputVarX%, %OutputVarY%, RGB
	;tooltip % A_PriorHotKey "-" A_TimeSincePriorHotkey "-" OutputVarColor "-" OutputVarControl "-" OutputVarX
	if (A_PriorHotKey = "~LButton" and A_TimeSincePriorHotkey < 400) and (OutputVarColor = "0xFFFFFF")
	; 判定是否点击的点是白色
		send !{Up}
	; 如果是则发送backspace键
	;tooltip % OutputVarColor " - " A_TimeSincePriorHotkey " - " A_PriorHotKey
	return
}
Return