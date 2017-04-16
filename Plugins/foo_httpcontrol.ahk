#SingleInstance force
#NoTrayIcon

Gui, +LastFound +Resize
Gui,Add, ActiveX, x0 y0 w800 h600 vwb hwndATLWinHWND, Shell.Explorer
OnMessage(0x100, "gui_KeyDown", 2)
OnMessage(0x101, "gui_KeyDown", 2)
gui,show, w700 h700 ,Foobar2000
wb.Navigate("http://192.168.1.100:8888/default")
While wb.ReadyState = 4
  break
return

GuiClose:
Gui, Destroy
ExitApp

GuiSize:
	GuiControl,Move, wb, W%A_GuiWidth% H%A_GuiHeight%
return

/*  Fix keyboard shortcuts in WebBrowser control.
 *  References:
 *    http://www.autohotkey.com/community/viewtopic.php?p=186254#p186254
 *    http://msdn.microsoft.com/en-us/library/ms693360
 */

gui_KeyDown(wParam, lParam, nMsg, hWnd) {
	wb := getDOM()
	if (Chr(wParam) ~= "[A-Z]"|| wParam = 0x74 ) ; Disable Ctrl+O/L/F/N and F5.
		return
	pipa := ComObjQuery(wb, "{00000117-0000-0000-C000-000000000046}")
	VarSetCapacity(kMsg, 48), NumPut(A_GuiY, NumPut(A_GuiX
	, NumPut(A_EventInfo, NumPut(lParam, NumPut(wParam
	, NumPut(nMsg, NumPut(hWnd, kMsg)))), "uint"), "int"), "int")
	Loop 2
	r := DllCall(NumGet(NumGet(1*pipa)+5*A_PtrSize), "ptr", pipa, "ptr", &kMsg)
	; Loop to work around an odd tabbing issue (it's as if there
	; is a non-existent element at the end of the tab order).
	until wParam != 9 || wb.Document.activeElement != ""
	ObjRelease(pipa)
	if r = 0 ; S_OK: the message was translated to an accelerator.
		return 0
}

getDOM(){
	global wb
	return wb
}