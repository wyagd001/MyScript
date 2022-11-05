Windo_跳转到打开的目录:
AllOpenFolder := GetAllWindowOpenFolder()
Menu SendToOpenedFolder, Add, 跳转到打开的文件夹, nul
Menu SendToOpenedFolder, Add
for k, v in AllOpenFolder
{
	Menu SendToOpenedFolder, add, %v%, Windo_JumpToFolder
}
Menu SendToOpenedFolder, Show
Menu, SendToOpenedFolder, DeleteAll
return

Windo_JumpToFolder:
ControlSetText, edit1, %A_ThisMenuItem%, Ahk_ID %Windy_CurWin_id%
ControlSend, edit1, {Enter}, Ahk_ID %Windy_CurWin_id%
return