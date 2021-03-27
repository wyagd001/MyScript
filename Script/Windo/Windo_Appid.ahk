; appid.exe 只获取鼠标下窗口的Appid
Windo_getappid:
happid:=JEE_RunGetStdOut(A_ScriptDir "\bin\appid.exe")
if !IsObject(appidobj)
	appidobj:={}
appidobj[Windy_CurWin_id]:=happid
msgbox % appidobj[Windy_CurWin_id]
return

Windo_SetWinAppId:
SetTimer, hovering, off
hovering_off:=1
; appid.exe 只获取鼠标下窗口的 Appid，所以点击完菜单后鼠标还在原窗口才能还原appid
MouseMove, Windy_X, Windy_Y
happid:=JEE_RunGetStdOut(A_ScriptDir "\bin\appid.exe")
if !IsObject(appidobj)
	appidobj:={}
if happid
	appidobj[Windy_CurWin_id]:=happid
Appid:="My_Custom_Group"
setwinappid(Windy_CurWin_id, Appid)
hovering_off:=0
return

Windo_RestoreAppId:
if appidobj[Windy_CurWin_id]
{
	setwinappid(Windy_CurWin_id, appidobj[Windy_CurWin_id])
	appidobj[Windy_CurWin_id]:=""
}
return

setwinappid(winhwnd,appid)
{
VarSetCapacity(IID_IPropertyStore, 16)
DllCall("ole32.dll\CLSIDFromString", "wstr", "{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}", "ptr", &IID_IPropertyStore)
VarSetCapacity(PKEY_AppUserModel_ID, 20)
DllCall("ole32.dll\CLSIDFromString", "wstr", "{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}", "ptr", &PKEY_AppUserModel_ID)
NumPut(5, PKEY_AppUserModel_ID, 16, "uint")
dllcall("shell32\SHGetPropertyStoreForWindow","Ptr", winhwnd, "ptr", &IID_IPropertyStore, "ptrp", pstore)
VarSetCapacity(variant, 8+2*A_PtrSize, 0)
NumPut(31, variant, 0, "short") ; VT_LPWSTR
NumPut(&Appid, variant, 8)
hr := IPropertyStore_SetValue(pstore, &PKEY_AppUserModel_ID, &variant)
}

vt(p,i) {
    return NumGet(NumGet(p+0)+i*A_PtrSize)
}
IPropertyStore_GetCount(pstore, ByRef count) {
    return DllCall(vt(pstore,3), "ptr", pstore, "uintp", count)
}
IPropertyStore_GetValue(pstore, pkey, pvalue) {
    return DllCall(vt(pstore,5), "ptr", pstore, "ptr", pkey, "ptr", pvalue)
}
IPropertyStore_SetValue(pstore, pkey, pvalue) {
    return DllCall(vt(pstore,6), "ptr", pstore, "ptr", pkey, "ptr", pvalue)
}

JEE_RunGetStdOut(vTarget, vSize:="")
{
	DetectHiddenWindows, On
	vComSpec := A_ComSpec ? A_ComSpec : ComSpec
	Run, % vComSpec,, Hide, vPID
	WinWait, % "ahk_pid " vPID
	DllCall("kernel32\AttachConsole", UInt,vPID)
	oShell := ComObjCreate("WScript.Shell")
	oExec := oShell.Exec(vTarget)
	vStdOut := ""
	if !(vSize = "")
		VarSetCapacity(vStdOut, vSize)
	while !oExec.StdOut.AtEndOfStream
		vStdOut := oExec.StdOut.ReadAll()
	DllCall("kernel32\FreeConsole")
	Process, Close, % vPID
	return vStdOut
}