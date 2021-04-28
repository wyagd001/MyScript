; appid.exe 只获取鼠标下窗口的Appid
Windo_getappid:
MouseMove, Windy_X, Windy_Y
happid:=Trim(JEE_RunGetStdOut(A_ScriptDir "\bin\appid.exe"), " `r`n")
msgbox % happid
return

Windo_SetWinAppId:
SetTimer, hovering, off
hovering_off:=1
; appid.exe 只获取鼠标下窗口的 Appid，所以点击完菜单后鼠标还在原窗口才能还原appid
MouseMove, Windy_X, Windy_Y
happid:=Trim(JEE_RunGetStdOut(A_ScriptDir "\bin\appid.exe"), " `r`n")
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

Windo_AddAppIdToList2(iList, iListValue)
{
happid:=Trim(JEE_RunGetStdOut(A_ScriptDir "\bin\appid.exe"), " `r`n")
id:=TTLib.AddAppIdToList(iList, happid, iListValue)
;Tooltip % iList " - " happid " - " iListValue " - " id
return
}

Windo_AddAppIdToList(iList, iListValue)
{
happid:=TTLib.GetActiveButtonGroupAppid()
id:=TTLib.AddAppIdToList(iList, happid, iListValue)
;Tooltip % iList " - " happid " - " iListValue " - " id
return
}