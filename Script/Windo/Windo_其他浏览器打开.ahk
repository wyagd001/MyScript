Windo_其他浏览器打开:
sURL := GetActiveBrowserURL(Windy_CurWin_Class)
; msgbox % Windy_CurWin_Class "`n" sURL
run,% Splitted_Windy_Cmd3 " " sURL
return