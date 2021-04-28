;https://autohotkey.com/boards/viewtopic.php?f=6&t=3702
Windo_记事本打开浏览器打开的文件:
surl := GetActiveBrowserURL(Windy_CurWin_Class, 0)
surl := StrReplace(surl, "file:///")
htmfile := UrlDecode(surl)
shtmfile := StrReplace(htmfile, "/" , "\")
;msgbox % shtmfile
if FileExist(shtmfile)
run, % Splitted_Windy_Cmd3 " " shtmfile
return