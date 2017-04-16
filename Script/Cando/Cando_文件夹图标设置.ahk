Cando_文件夹图标设置:
Splitpath,CandySel,Filename

if Fileexist(CandySel "\" Filename ".exe")
ChangeFolderIcon(CandySel,CandySel "\" Filename ".exe")
Return

Cando_exeicon2folder:
Splitpath,CandySel,,FilePath
ChangeFolderIcon(FilePath,CandySel)
Return

Cando_文件夹图标还原:
If InStr(FileExist(CandySel), "D")  
{
if Fileexist(CandySel "\desktop.ini" ) 
FileRecycle, % CandySel "\desktop.ini"
}
else{
Splitpath,CandySel,,FilePath
If Fileexist(FilePath "\desktop.ini" ) 
FileRecycle, % FilePath "\desktop.ini"
}
Return

;MINIMAL  USAGE:
; ChangeFolderIcon("Test Folder")	;create folder and apply ahk icon to folder

ChangeFolderIcon(TargetFolder, IconFile:=0, IconIndex:=0, FolderInfoText:=0, ConfirmFileOperation:=0){	;target folder doesn't need to exist
;NEEDLESSLY LARGE FUNCTION,JUST BECAUSE...
/*
msdn;
Set IconFile to icon's file name,.ico extension is preferred .bmp/.exe/.dll files with icons can also be speficied,
	Specifying a relative path allows icon to be available over the network-IconIndex entry must also be specified.
If File assigned to IconFile contains a single icon,set IconIndex to 0.
Set ConfirmFileOp to 0, to avoid a "You are deleting a system folder" warning when deleting or moving the folder,though you will still be prompted when deleting desktop.ini.
Set InfoTip entry to an informational text string. It is displayed as an tooltip when the cursor hovers over the folder. If folder is clicked on the info text is displayed in the folders information block below standard informaion.

NoSharing	;Not Supported under vista or later,set to 1 to prevent folder from being shared.
*/
ini=%TargetFolder%\desktop.ini
FileCreateDir %TargetFolder%	;in case folder doesn't exist
FileSetAttrib +S, %TargetFolder%, 2	;msdn: PathMakeSystemFolder to make the folder a system folder,this sets the read-only bit on the folder to indicate that the special behaviour reserved for desktop.ini should be enabled.
if !IconFile
	IniWrite %A_AHKPath%, %ini%, .ShellClassInfo, IconFile	;set the AHK exe icon as folder icon.
else
	{
	IfExist, %IconFile%		;incase the specified icon file doesn't exist
		IniWrite %IconFile%, %ini%, .ShellClassInfo, IconFile	
	else
		{
		MsgBox, 0xC0010, %A_ScriptName%, Specified Icon File Doesn't Exist!
		Return 0
		}
	}
	
if !IconIndex
	IniWrite 0, %ini%, .ShellClassInfo, IconIndex
else IniWrite %IconIndex%, %ini%, .ShellClassInfo, IconIndex
	
if !ConfirmFileOperation
	IniWrite 0, %ini%, .ShellClassInfo, ConfirmFileOp
else IniWrite %ConfirmFileOperation%, %ini%, .ShellClassInfo, ConfirmFileOp

FileSetAttrib +SH, %ini%, 2	;Hide desktop.ini by setting +SH(system,hidden attributes)
}