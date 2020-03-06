1014:
SetTimer,保存剪贴板为文件,-200
return

保存剪贴板为文件:
CurrentFolder:=GetCurrentFolder()
if CurrentFolder
PasteToPath(CurrentFolder)
return