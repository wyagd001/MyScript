; appid.exe 只获取鼠标下窗口的Appid
Windo_getappid:
;MouseMove, Windy_X, Windy_Y
;msgbox % A_ScriptDir "\bin\appid.exe " Windy_CurWin_id
happid:=Trim(JEE_RunGetStdOut(A_ScriptDir "\bin\appid.exe " Windy_CurWin_id), " `r`n")
msgbox % happid
return

Windo_SetWinAppId:
happid:=Trim(JEE_RunGetStdOut(A_ScriptDir "\bin\appid.exe " Windy_CurWin_id), " `r`n")
if !IsObject(appidobj)
	appidobj:={}
if happid
	appidobj[Windy_CurWin_id]:=happid
Appid:="My_Custom_Group"
setwinappid(Windy_CurWin_id, Appid)
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