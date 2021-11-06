defaultSet =
	( LTrim
		动作_名称=动作管理
		动作_轨迹=下左
		动作_提示=动作管理
		动作_条件模式=通用
		动作_生效条件=
		动作_模式=标签
		动作_命令=鼠标手势动作管理
		动作_启用=1
	)
SplitPath, A_ScriptFullPath,,,,SecName
MG_WriteIni(SecName, defaultSet)
ExitApp
return

鼠标手势动作管理:
Gui,2: Destroy
MGA_CNameList:=""
Gui,2: Default
Gui,2: Add, ListView, x8 y24 w160 h426 vpluginsList gloadset, 动作列表
Gui,2: Add, Text, x180 y20 w65 h30 +0x200, 动作名称:
Gui,2: Add, Button, x590 y20 w60 h32 gDelMGA, 删除动作
Gui,2: Add, Edit, x280 y20 w300 h27 vMGA_Name, 
Gui,2: Add, Text, x180 y60 w65 h30 +0x200, 动作轨迹:
Gui,2: Add, Edit, x280 y60 w300 h27 vMGA_GJ,
Gui,2: Add, Button, x590 y60 w60 h32 vStartMGHZ gStartMGHZ, 开始绘制
Gui,2: Add, Text, x180 y100 w87 h30 +0x200, 动作提示文本:
Gui,2: Add, Edit, x280 y100 w300 h27 vMGA_Tip, 
Gui,2: Add, Text, x180 y140 w85 h30 +0x200, 动作生效模式:
Gui,2: Add, DropDownList, x280 y140 w163 vMGA_Mode, 特定窗口|非特定窗口|通用
Gui,2: Add, Text, x180 y180 w85 h30 +0x200, 动作生效条件:
Gui,2: Add, Edit, x280 y180 w300 h27 vMGA_TJ, 
Gui,2: Add, Picture, x590 y180 w32 h32 gGetWClass vPic, % A_ScriptDir "\鼠标手势动作\Full.ico"
Gui,2: Add, Text, x180 y220 w85 h30 +0x200, 动作调用模式:
Gui,2: Add, DropDownList, x280 y220 w163 vMGA_CType, 标签|函数
Gui,2: Add, Text, x180 y260 w85 h30 +0x200, 动作调用命令:
Gui,2: Add, ComboBox, x280 y260 w300 h140 vMGA_CName,
Gui,2: Add, Button, x544 y416 w77 h36 gsaveaction, 保存
Gui,2: Add, Button, x440 y416 w77 h36 g2GuiClose, 取消

 for k in 鼠标手势设置对象
{
	if k
	{
		动作项目:= k MGA_Name2箭头(鼠标手势设置对象[k].动作_轨迹)
		LV_Add("", 动作项目)
		if !(ipos := instr(鼠标手势设置对象[k].动作_命令, "|"))
			MGA_CNameList .= 鼠标手势设置对象[k].动作_命令 "|"
		else
			MGA_CNameList .= SubStr(鼠标手势设置对象[k].动作_命令, 1, iPos-1) "|"
	}
}
Sort, MGA_CNameList, U D|
Gui,2: Show, w654 h470, 动作管理
GuiControl, , MGA_CName, |%MGA_CNameList%
Return

MGA_Name2箭头(Str)
{
	Str := StrReplace(Str, "上", "↑")
	Str := StrReplace(Str, "下", "↓")
	Str := StrReplace(Str, "左", "←")
	Str := StrReplace(Str, "右", "→")
	Return "【" Str "】"
}

loadset:
Gui,2: submit, nohide
Gui,2:Default
if A_GuiEvent = DoubleClick
{
	RF:=LV_GetNext("F")
	if RF
	{
		LV_GetText(C1,RF,1)
		ipos := instr(C1, "【")
		C1 := SubStr(C1, 1, iPos-1)
		GuiControl, , MGA_Name, % 鼠标手势设置对象[C1].动作_名称
		GuiControl, , MGA_GJ, % 鼠标手势设置对象[C1].动作_轨迹
		GuiControl, , MGA_Tip, % 鼠标手势设置对象[C1].动作_提示
		GuiControl, , MGA_TJ, % 鼠标手势设置对象[C1].动作_生效条件
		GuiControl, Text, MGA_CName, % 鼠标手势设置对象[C1].动作_命令
		GuiControl, ChooseString, MGA_Mode, % 鼠标手势设置对象[C1].动作_条件模式
		GuiControl, ChooseString, MGA_CType, % 鼠标手势设置对象[C1].动作_模式
	}
}
return

2GuiEscape:
2GuiClose:
MGA_CNameList:=""
StartMGHZ:=0
Gui,2: Destroy
return

GetWClass:
GuiControl,,Pic, % A_ScriptDir "\鼠标手势动作\Null.ico"
CursorHandle := DllCall( "LoadCursorFromFile", Str,A_ScriptDir "\鼠标手势动作\Cross.CUR" )
DllCall( "SetSystemCursor", Uint,CursorHandle, Int,32512 )
SetTimer,GetPos,300
KeyWait,LButton
DllCall( "SystemParametersInfo", UInt,0x57, UInt,0, UInt,0, UInt,0 )
SetTimer,GetPos,Off
Gui,2:Default
GuiControlGet, OutputVar,, MGA_TJ
OutputVar := trim(OutputVar,";")
GuiControl, , MGA_TJ, % OutputVar ";" OutWin2
GuiControl,,Pic, % A_ScriptDir "\鼠标手势动作\Full.ico"
return

GetPos:
MouseGetPos,,,OutWin3
WinGetClass, OutWin2, ahk_id %OutWin3%
return

DelMGA:
Gui,2: submit, nohide
if MGA_Name and (MGA_Name != " ")
IniDelete, % MG_settingFile, % MGA_Name
RowNumber := 0
loop
{
	LV_GetText(C1, RowNumber)
	ipos := instr(C1, "【")
	C1 := SubStr(C1, 1, iPos-1)
	if (C1 = MGA_Name)
	{
		LV_Delete(RowNumber)
		鼠标手势设置对象.Delete(MGA_Name)
		break
	}
	RowNumber+=1
}
return

StartMGHZ:
StartMGHZ:=1
GuiControl,, StartMGHZ, 绘制中
return

saveaction:
Gui,2: submit, nohide
if MGA_Name and (MGA_Name != " ")
{
/*
	IniWrite, % MGA_Name, % MG_settingFile, % MGA_Name, 动作_名称
	IniWrite, % MGA_GJ, % MG_settingFile, % MGA_Name, 动作_轨迹
	IniWrite, % MGA_Tip, % MG_settingFile, % MGA_Name, 动作_提示
	IniWrite, % MGA_Mode, % MG_settingFile, % MGA_Name, 动作_条件模式
	IniWrite, % MGA_TJ, % MG_settingFile, % MGA_Name, 动作_生效条件
	IniWrite, % MGA_CType, % MG_settingFile, % MGA_Name, 动作_模式
	IniWrite, % MGA_CName, % MG_settingFile, % MGA_Name, 动作_命令
*/
	if !isobject(鼠标手势设置对象[MGA_Name])
	{
		LV_Add("", MGA_Name MGA_Name2箭头(MGA_GJ))
		鼠标手势设置对象[MGA_Name]:={}
	}
	鼠标手势设置对象[MGA_Name].动作_名称:=MGA_Name
	鼠标手势设置对象[MGA_Name].动作_轨迹:=MGA_GJ
	鼠标手势设置对象[MGA_Name].动作_提示:=MGA_Tip
	鼠标手势设置对象[MGA_Name].动作_条件模式:=MGA_Mode
	鼠标手势设置对象[MGA_Name].动作_生效条件:=MGA_TJ
	鼠标手势设置对象[MGA_Name].动作_模式:=MGA_CType
	鼠标手势设置对象[MGA_Name].动作_命令:=MGA_CName
	obj2ini(鼠标手势设置对象, MG_settingFile, MGA_Name)
}
return