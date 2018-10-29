Windo_发送路径到对话框:
ControlSetText , edit1, %Windy_CurWin_FolderPath%, ahk_class #32770
return

Windo_窗口静音:
VA_SetAppMute(Windy_CurWin_Pid, !VA_GetAppMute(Windy_CurWin_Pid))
return

Windo_保存路径到windy收藏夹:
SplitPath,Windy_CurWin_FolderPath,menuname
iniwrite,%Windy_CurWin_FolderPath%,%A_ScriptDir%\Settings\Windy\主窗体\windy_Fav.ini,menu,%menuname%
return