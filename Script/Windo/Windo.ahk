Windo_发送路径到对话框:
ControlSetText , edit1, %Windy_CurWin_FolderPath%, ahk_class #32770
return

Windo_窗口静音:
VA_SetAppMute(Windy_CurWin_Pid, !VA_GetAppMute(Windy_CurWin_Pid))
return