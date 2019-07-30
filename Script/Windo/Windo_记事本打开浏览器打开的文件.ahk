;https://autohotkey.com/boards/viewtopic.php?f=6&t=3702
Windo_记事本打开浏览器打开的文件:
ModernBrowsers := "ApplicationFrameWindow,Chrome_WidgetWin_0,Chrome_WidgetWin_1,Maxthon3Cls_MainFrm,MozillaWindowClass,Slimjet_WidgetWin_1,360se6_Frame"
LegacyBrowsers := "IEFrame,OperaWindowClass"
OtherBrowsers :="AuroraMainFrame"
shtmfile := GetActiveBrowserURL2(Windy_CurWin_Class)
if FileExist(shtmfile)
run,% Splitted_Windy_Cmd3 " " shtmfile
return

GetActiveBrowserURL2(sClass) {
	global ModernBrowsers, LegacyBrowsers,OtherBrowsers
	if !sclass
		WinGetClass, sClass, A
	If sClass In % ModernBrowsers
	{
		surl := GetBrowserURL_ACC(sClass,0)
		surl := StrReplace(surl, "file:///")
		htmfile := UrlDecode(surl)
		htmfile := StrReplace(htmfile, "/" , "\")
		;msgbox % htmfile
		return htmfile
	}
	Else If sClass In % LegacyBrowsers
	{
		surl :=  GetBrowserURL_DDE(sClass)
		surl := StrReplace(surl, "file:///")
		htmfile := UrlDecode(surl)
		htmfile := StrReplace(htmfile, "/" , "\")
		;msgbox % htmfile
		Return htmfile
}
	Else If sClass In % OtherBrowsers
		Return GetBrowserURL_hK()
	Else
		Return ""
}