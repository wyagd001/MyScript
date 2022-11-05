#SingleInstance force

if FileExist(A_Args[1]) && InStr(A_Args[1], ".lnk")
{
	SplitPath, % A_Args[1], LnkName, LnkFolder
	LnkPath := A_Args[1]
}
else
{
	LnkFolder := A_Desktop
	LnkPath := ""
}
ComObjError(0)

LnkEditorGui:
Gui, Destroy
Gui, Default

Gui, Add, ListView, x8 y10 w180 h530 vLnkList gloadlnk, lnk列表|文件路径
Gui, Add, GroupBox, x195 y10 w468 h425, 编辑
Gui, Add, Text, xp+10 yp+15 w65 h30 +0x200, 文件路径:
Gui, Add, Edit, xp+60 yp+2 w350 h25 ReadOnly  vLnk_Path,
Gui, Add, Text, xp-60 yp+35 w65 h30 +0x200, 文件名:
Gui, Add, Edit, xp+60 yp+2 w350 h25 vLnk_Name,
Gui, Add, Text, xp-60 yp+35 w65 h30 +0x200, 目标:
Gui, Add, Edit, xp+60 yp+2 w350 h25 vLnk_Target,
Gui, Add, Text, xp-60 yp+35 w65 h30 +0x200, 参数:
Gui, Add, Edit, xp+60 yp+2 w350 h25 vLnk_Args,
Gui, Add, Text, xp-60 yp+35 w87 h30 +0x200, 起始位置:
Gui, Add, Edit, xp+60 yp+2 w350 h25 vLnk_Dir,
Gui, Add, Text, xp-60 yp+35 w87 h30 +0x200, 快捷键:
Gui, Add, Hotkey, xp+60 yp+2 w350 h25 vLnk_Hotkey gsethotkey,  ; Hotkey
Gui, Add, Text, xp-60 yp+35 w85 h30 +0x200, 运行方式:
Gui, Add, DropDownList, xp+60 yp+2 w163 vLnk_RunState, 普通窗口|最大化|最小化
Gui, Add, Text, xp-60 yp+35 w85 h30 +0x200, 备注:
Gui, Add, Edit, xp+60 yp+2 w350 h25 vLnk_Description,
Gui, Add, Text, xp-60 yp+35 w85 h30 +0x200, 图标:
Gui, Add, Edit, xp+60 yp+2 w350 h25 vLnk_Icon gload_icon,
Gui, Add, Picture, xp+355 yp w32 h30 vPic,
Gui, Add, Text, xp-415 yp+35 w85 h30 +0x200, 管理员:
Gui, Add, CheckBox, xp+60 yp+2 w120 h25 vLnk_Admin, 以管理员身份运行
Gui, Add, Text, xp+140 yp-2 w85 h30 +0x200, 文件属性:
Gui, Add, CheckBox, xp+60 yp+2 w100 h25 vLnk_ReadOnly, 只读
Gui, Add, Button, x205 yp+35 w40 h30 gSelFolder, 选择
Gui, Add, DropDownList, xp+50 yp w100 h150 gSelFav vFavKey, 开始菜单|用户开始菜单|桌面|用户桌面|启动|用户启动|快速启动栏|发送到|脚本收藏夹
Gui, Add, Button, xp+110 yp w70 h30 gOPenFav, 打开文件夹

Gui, Add, Button, xp+130 yp w70 h30 gGuiClose, 取消
Gui, Add, Button, xp+80 yp w70 h30 gSaveLnk, 保存
Gui, Add, Button, x620 y25 w40 h30 vStartMGHZ gDelLnkFileFB, 删除
Gui, Add, Button, xp yp+35 w40 h30  gReNameLnkFile, 修改

Gui, Add, GroupBox, x195 y440 w468 h100, 批量替换
Gui, Add, Text, xp+10 yp+20 w260 h30 +0x200, 批量替换目录下所有快捷方式中的文本
Gui, Add, Button, xp+360 yp+2 w80 h30 gLnksChange, 批量替换
Gui, Add, Text, xp-360 yp+35 w50 h30 +0x200 , 旧文本:
Gui, Add, Edit, xp+60 yp+2 w160 h25 vOldStr,
Gui, Add, Text, xp+180 yp-2 w50 h30 +0x200 , 新文本:
Gui, Add, Edit, xp+50 yp+2 w160 h25 vNewStr, 

ImageListID1 := IL_Create(10, ,0)
LV_SetImageList(ImageListID1, 1)

LoadFolder(LnkFolder)
if LnkPath
	SetGuiValue(LnkPath)

Menu MyListViewMenu, Add, 打开, openlnkfileFM
Menu MyListViewMenu, Add, 删除, dellnkfileFM
Menu, MyListViewMenu, Icon, 删除, %A_WinDir%\system32\shell32.dll, 132
Return

loadlnk:
Gui, submit, nohide
Gui, Default
if A_GuiEvent = DoubleClick
{
	RF:=LV_GetNext("F")
	if RF
	{
		LV_GetText(LnkPath, RF, 2)
		SetGuiValue(LnkPath)
	}
}
return

SetGuiValue(LnkFile:="")
{
	global lLnkObj, Init_Lnk_Admin, Init_Lnk_ReadOnly
	if FileExist(LnkFile) && InStr(LnkFile, ".lnk")
	{
		SplitPath, LnkFile, LnkName
		lLnkObj := GetLnkObj(LnkFile)
	}
	else
		LnkFile := ""
	GuiControl, , Lnk_Path, % LnkFile?LnkFile:""
	GuiControl, , Lnk_Name, % LnkName?LnkName:""
	
	GuiControl, , Lnk_Target, % LnkFile?lLnkObj.TargetPath:""
	GuiControl, , Lnk_Args, % LnkFile?lLnkObj.Arguments:""
	GuiControl, , Lnk_Dir, % LnkFile?lLnkObj.WorkingDirectory:""
	GuiControl, , Lnk_Hotkey, % LnkFile?HotkeyStringToAhk(lLnkObj.Hotkey):""
	GuiControl, Choose, Lnk_RunState, % LnkFile?((lLnkObj.WindowStyle=7)?3:(lLnkObj.WindowStyle=3)?2:1):0
	GuiControl, , Lnk_Description, % LnkFile?lLnkObj.Description:""
	GuiControl, , Lnk_Icon, % LnkFile?lLnkObj.IconLocation:""
	Array := StrSplit(lLnkObj.IconLocation, ",")
	GuiControl, , pic, % LnkFile?((Array[1])? "*Icon" Array[2]+1 " " Array[1]  : "*Icon" Array[2]+1 " " lLnkObj.TargetPath):""
	if LnkFile && InStr(lLnkObj.TargetPath, ".exe")
	{
		GuiControl, Enable, Lnk_Admin
		Init_Lnk_Admin := GetLnkAdmin(LnkFile)
		GuiControl, , Lnk_Admin, % Init_Lnk_Admin?1:0
	}
	else if LnkFile && !InStr(lLnkObj.TargetPath, ".exe")
	{
		GuiControl, , Lnk_Admin, 0
		Init_Lnk_Admin := 0
		GuiControl, Disable, Lnk_Admin
	}
	else
	{
		Init_Lnk_Admin := 0
		GuiControl, Enable, Lnk_Admin
		GuiControl, , Lnk_Admin, 0
	}
	Init_Lnk_ReadOnly := CF_FileIsReadOnly(LnkFile)
	GuiControl, , Lnk_ReadOnly, %  LnkFile?(Init_Lnk_ReadOnly?1:0):0
	;msgbox % lLnkObj.hotkey
}

load_icon:
gui, submit, nohide
	Array := StrSplit(Lnk_Icon, ",")
	GuiControl, , pic, % Lnk_Target?((Array[1])? "*Icon" Array[2]+1 " " Array[1]  : "*Icon" Array[2]+1 " " Lnk_Target):""
return

GetLnkObj(LnkFile)
{
	WshShell := ComObjCreate("WScript.Shell")
	oShellLink := WshShell.CreateShortcut(LnkFile)
	return oShellLink
}

GetLnkAdmin(LnkFile)
{
	FileObj := FileOpen(LnkFile, "rw")
	FileObj.Seek(21, 0)
	num := FileObj.ReadUChar()
	Admin := (num>>5) & 1
	FileObj.Close()
	return Admin
}

SetLnkAdmin(LnkFile, OnOff:=1)
{
	FileObj := FileOpen(LnkFile, "rw")
	FileObj.Seek(21, 0)
	num := FileObj.ReadUChar()
	FileObj.Seek(21, 0)
	if OnOff
		FileObj.WriteUChar(num|0x20)
	else
		FileObj.WriteUChar(num&0x1F)
	FileObj.Close()
	return
}

; 热键设置只支持单字符热键
sethotkey:
Gui, submit, nohide
if !Lnk_Hotkey
return
if !instr(Lnk_Hotkey, "!^") && !instr(Lnk_Hotkey, "+^")
{
	;tooltip % Lnk_Hotkey
	Lnk_Hotkey := SubStr(Lnk_Hotkey, 0, 1)
	GuiControl, , Lnk_Hotkey, ^!%Lnk_Hotkey%
}
return

SaveLnk:
Gui, submit, nohide
if !Lnk_Path
return
SplitPath, Lnk_Path, LnkName, Lnk_Folder
if (LnkName != Lnk_Name) && InStr(Lnk_Name, ".lnk")
{
	Lnk_Path := Lnk_Folder "\" Lnk_Name
	lLnkObj := GetLnkObj(Lnk_Path)
	GuiControl, , Lnk_Path, %Lnk_Path%
}
if (Lnk_RunState = "普通窗口")
	lLnkObj.WindowStyle := 1
else if (Lnk_RunState = "最大化")
	lLnkObj.WindowStyle := 3
else
	lLnkObj.WindowStyle := 7
lLnkObj.TargetPath := Lnk_Target
lLnkObj.Arguments := Lnk_Args
lLnkObj.WorkingDirectory := Lnk_Dir
lLnkObj.Hotkey := AhkToHotkeyString(Lnk_Hotkey)
lLnkObj.Description := Lnk_Description
lLnkObj.IconLocation := Lnk_Icon
lLnkObj.Save()
LoadFolder(LnkFolder)
if (Lnk_Admin != Init_Lnk_Admin)
{
	SetLnkAdmin(Lnk_Path, Lnk_Admin)
}
if (Lnk_ReadOnly != Init_Lnk_ReadOnly)
{
	if Lnk_ReadOnly
		FileSetAttrib, +R, %Lnk_Path%
	else
		FileSetAttrib, -R, %Lnk_Path%
}
;msgbox % Lnk_Hotkey " - " AhkToHotkeyString(Lnk_Hotkey)
return

SelFolder:
oldLnkFolder := LnkFolder
FileSelectFolder, LnkFolder
if LnkFolder
{
	LoadFolder(LnkFolder)
	GuiControl, Choose, FavKey, 0
}
else
LnkFolder := oldLnkFolder
return

LoadFolder(hFolder)
{
	global ImageListID1
	sfi_size := A_PtrSize + 8 + (A_IsUnicode ? 680 : 340)
	VarSetCapacity(sfi, sfi_size)

	LV_Delete()
	GuiControl, -Redraw, LnkList
	Loop, Files, %hFolder%\*.lnk, R
	{
		if not DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W":"A"), "Str", A_LoopFilePath
            , "UInt", 0, "Ptr", &sfi, "UInt", sfi_size, "UInt", 0x101)
			IconNumber := 9999999
		else
		{
			hIcon := NumGet(sfi, 0)
			IconNumber := DllCall("ImageList_ReplaceIcon", "Ptr", ImageListID1, "Int", -1, "Ptr", hIcon) + 1
			DllCall("DestroyIcon", "Ptr", hIcon)
		}
		LV_Add("Icon" . IconNumber, A_LoopFileName, A_LoopFilePath)
	}
	GuiControl, +Redraw, LnkList 
	LV_ModifyCol(2, 0)
	LV_ModifyCol(1, 175)
	Gui, Show, w670 h550, Lnk文件编辑器 - %hFolder%
}

GuiEscape:
GuiClose:
MGA_CNameList:=""
StartMGHZ:=0
Gui, Destroy
exitapp
return

DelLnkFileFB:
Gui, submit, nohide
FileRecycle, %Lnk_Path%
LoadFolder(LnkFolder)
SetGuiValue()
return

SelFav:
Gui, submit, nohide
if (FavKey = "开始菜单")
	LnkFolder := A_StartMenuCommon
if (FavKey = "用户开始菜单")
	LnkFolder := A_StartMenu
if (FavKey = "桌面")
	LnkFolder := A_DesktopCommon
if (FavKey = "用户桌面")
	LnkFolder := A_Desktop
if (FavKey = "启动")
	LnkFolder := A_StartupCommon
if (FavKey = "用户启动")
	LnkFolder := A_Startup
if (FavKey = "发送到")
	LnkFolder := A_AppData "\Microsoft\Windows\SendTo"
if (FavKey = "快速启动栏")
	LnkFolder := A_AppData "\Microsoft\Internet Explorer\Quick Launch"
if (FavKey = "脚本收藏夹")
	LnkFolder := CF_GetParentPath(A_ScriptDir) "\Favorites"
LoadFolder(LnkFolder)
SetGuiValue()
return

OPenFav:
run %LnkFolder%
return

ReNameLnkFile:
Gui, submit, nohide
if StrLen(Lnk_Name)>4 && InStr(Lnk_Name, ".lnk")
	FileMove, %Lnk_Path%, % LnkPath := CF_GetParentPath(Lnk_Path) "\" Lnk_Name
if LnkFolder
	LoadFolder(LnkFolder)
SetGuiValue(LnkPath)
return

LnksChange:
Gui, submit, nohide
LnksChangePath(LnkFolder, OldStr, NewStr)
return

GuiDropFiles:
Loop, Parse, A_GuiEvent, `n
{
	if InStr(A_LoopField, ".lnk")
	{
		LnkPath := A_LoopField
		SplitPath, LnkPath, LnkName, LnkFolder
		LoadFolder(LnkFolder)
		SetGuiValue(LnkPath)
		break
	}
}
return

GuiContextMenu:
if (A_GuiControl = "LnkList")
Menu, MyListViewMenu, Show, %A_GuiX%, %A_GuiY%
return

dellnkfileFM:
Gui, submit, nohide
RF := LV_GetNext("F")
if RF
{
	LV_GetText(LnkPath, RF, 2)
	FileRecycle, %LnkPath%
	LV_Delete(RF)
	if (Lnk_Path = LnkPath)
		SetGuiValue()
}
return

openlnkfileFM:
Gui, submit, nohide
RF := LV_GetNext("F")
if RF
{
	LV_GetText(LnkPath, RF, 2)
	run, %LnkPath%
}
return

HotkeyStringToAhk(hHotkey)
{
	hHotkey := StrReplace(hHotkey, "+", "★")
	hHotkey := StrReplace(hHotkey, "Ctrl", "^")
	hHotkey := StrReplace(hHotkey, "Alt", "!")
	hHotkey := StrReplace(hHotkey, "Shift", "+")
	hHotkey := StrReplace(hHotkey, "★", "")
	return hHotkey
}

AhkToHotkeyString(hHotkey)
{
	hHotkey := StrReplace(hHotkey, "+", "Shift+")
	hHotkey := StrReplace(hHotkey, "^", "Ctrl+")
	hHotkey := StrReplace(hHotkey, "!", "Alt+")
	return hHotkey
}

#Include %A_ScriptDir%\..\Lib\CF.ahk
#Include %A_ScriptDir%\..\Lib\LnkChangePath.ahk