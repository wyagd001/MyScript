SendToOpenedFolder:
Files := GetSelectedFiles()
AllOpenFolder := GetAllWindowOpenFolder()
if !WinActive("ahk_class #32770")
{
	Menu SendToOpenedFolder, Add, 发送到打开的文件夹(按住Shift为剪切), nul
	Menu SendToOpenedFolder, Add
	for k, v in AllOpenFolder
	{
		Menu SendToOpenedFolder, add, %v%, % (Files ? "SendToFolder" : "CopyFolderPath")
	}
	Menu SendToOpenedFolder, Show
	Menu SendToOpenedFolder, DeleteAll
}
else
{
	Menu SendToOpenedFolder, Add, 对话框定位到当前打开窗口, nul
	Menu SendToOpenedFolder, Add
	for k, v in AllOpenFolder
	{
		Menu SendToOpenedFolder, add, %v%, dialogEdit
	}
	Menu SendToOpenedFolder, Show
	Menu SendToOpenedFolder, DeleteAll
}
return

SendToFolder:
Loop Parse, Files, `n, `r
{
	SplitPath, A_LoopField, FileName
	TargetFile := PathU(A_ThisMenuItem "\" FileName)
	if !GetKeyState("shift")
		FileCopy %A_LoopField%, %TargetFile%
	else
		FileMove %A_LoopField%, %TargetFile%
}
Return

CopyFolderPath:
clipboard := A_ThisMenuItem
return

dialogEdit:
ControlSetText, edit1, %A_ThisMenuItem%, ahk_class #32770
ControlSend, Edit1, {Enter}, ahk_class #32770
return