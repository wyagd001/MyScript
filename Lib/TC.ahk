#include *i LB.ahk

TC_Get(n) ; WM_USER+50 = 1074
{
	Return CF_SendMessage(1074, n, 0, , "Ahk_class TTOTAL_CMD")
}

TC_SendMsg(n)  ; WM_USER+51 = 1075
{
	Return CF_SendMessage(1075, n, 0, , "Ahk_class TTOTAL_CMD")
}

TC_PostMsg(n)
{
	Return CF_PostMessage(1075, n, 0, , "Ahk_class TTOTAL_CMD")
}

OpenWithTC(hpath, TcFile, IniFile)
{
	global Tc
	if !TcFile
		TcFile := Tc
	if WinExist("ahk_class TTOTAL_CMD")
	{
		TC_CD(hpath, "S")
	}
	else
	{
		if IniFile
			Run %TcFile% /i="%IniFile%" /O /S /L="%hpath%"
		else
			Run %TcFile% /O /S /L="%hpath%"
	}
}

ctl_CurrTPath() ; 返回当前激活的路径栏控件id
{
	Return TC_get(8+TC_get(1000))
}

; Num 1 左 2 右
ctl_TPath(Num:=1)   ; 返回指定路径栏控件 id
{
	Return TC_get(8+Num)
}

CtlText_CurrTPath() ; 返回当前激活的路径栏控件文本
{
	Return CF_ControlGetText(ctl_CurrTPath())
}

CtlText_TPath(Num:=1) ; 返回指定路径栏控件文本
{
	Return CF_ControlGetText(ctl_TPath(Num))
}

cm_CopyNamesToClip()
{
	TC_SendMsg(2017)
}

cm_CopyFullNamesToClip()
{
	TC_SendMsg(2018)
}

um_GetNamesFromClip(ChangeClip:=0) ; 返回选中文件的名称(可多选)
{
	BackUp_ClipBoard := ClipboardAll
	Clipboard := ""
	cm_CopyNamesToClip() ; 复制名称到剪贴板
	ClipWait 0.2
	if ChangeClip
	Return Clipboard
	else
	{
		ClipSel := Clipboard
		Clipboard := BackUp_ClipBoard
		Return ClipSel
	}
}

um_GetFullNamesFromClip(ChangeClip:=0) ; 返回选中文件的路径(可多选)
{
	Clipboard := ""
	cm_CopyFullNamesToClip()
	ClipWait 0.2
	if ChangeClip
	Return Clipboard
	else
	{
		ClipSel := Clipboard
		Clipboard := BackUp_ClipBoard
		Return ClipSel
	}
}

TC_CurrTPath() ; 返回当前路径栏控件文本
{
	DetectHiddenText, On
	WinGetText, TCWindowText, Ahk_class TTOTAL_CMD
	RegExMatch(TCWindowText, "(.*)>", TCPath)
	return TCPath1
}

TC_getTwoPath()
{
	DetectHiddenText, On
	WinGetText, TCWindowText, Ahk_class TTOTAL_CMD
	m := RegExMatchAll(TCWindowText, "m)(.*)\\\*\.\*", 1)
	return m
}

RegExMatchAll(ByRef Haystack, NeedleRegEx, SubPat="")
{
	arr := [], startPos := 1
	while ( pos := RegExMatch(Haystack, NeedleRegEx, match, startPos) )
	{
		arr.push(match%SubPat%)
		startPos := pos + StrLen(match)
	}
	return arr.MaxIndex() ? arr : ""
}

TC_SendCommand(xsTCCommand, xbWait=1)
{
	static COMMANDER_PATH
	if !COMMANDER_PATH
		WinGet, TOTALCMD_PATH, ProcessPath, Ahk_class TTOTAL_CMD
	SplitPath, TOTALCMD_PATH,, COMMANDER_PATH
	loop Read, %COMMANDER_PATH%\TOTALCMD.INC
	{
		StringSplit asCommands, A_LoopReadLine, =
		if (asCommands1 = xsTCCommand)
		{
			StringSplit asCommandsValues, asCommands2, `;
			Break
		}
	}

	if !(asCommandsValues1 > 0)
		return

	if (xbWait)
		SendMessage 1075, %asCommandsValues1%, 0, , ahk_class TTOTAL_CMD
	else
		PostMessage 1075, %asCommandsValues1%, 0, , ahk_class TTOTAL_CMD
	return
}

um_FileNameSrc() ; 来源：光标文件名
{
	Return arrFileCurrent(3)[1]
}

um_FileNameTrg()
{
	Return arrFileCurrent(4)[1]
}

; 获取光标文件的信息(arr)
; Src为3,Trg为4
arrFileCurrent(tp:=3)
{
	idx := TC_Get(1006+TC_Get(1000)) + 1 ; 因为前面有个返回上一级的行
	str := LB_QueryText(TC_Get(tp), idx)
	Return StrSplit(str, A_Tab)
}

; 发送内部命令或自定义命令
TC_EM(Command) ; string 
{
	If  Command <> 
	{
		if A_IsUnicode
		{
			BOM := Chr(0xFEFF)
			Command := BOM Command
		}
		dwData := Asc("E") + 256 * Asc("M") 
		cbData := StrPutVar(Command, Command, A_IsUnicode ? "UTF-8" : "CP0")

		VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; Set up the structure's memory area. 
		NumPut(dwData, CopyDataStruct, 0) 
		NumPut(cbData, CopyDataStruct, A_PtrSize)  ; OS requires that this be done. 
		NumPut(&Command, CopyDataStruct, 2*A_PtrSize)  ; Set lpData to point to the string itself. 
		SendMessage, 0x4a, 0, &CopyDataStruct,, ahk_class TTOTAL_CMD ; 0x4a is WM_COPYDATA. Must use Send not Post. 
	}
}

/*
路径不支持记事本(Ansi)保存后不能正常显示的字符, 例如 "เบิร์ด".
hpath:
pathA
pathA "`r" pathB
"`r" pathB

paras:
S: Interpret the paths as source/target instead of left/right
T: Open path(s) in new tabs
B: Open tabs in background (do not activate them)
L: Activate the left panel
R: Activate the right panel
A: Do not open archives as directories. Instead, open parent directory and place cursor on it.
TC accepts more then 2 parameters here, so sending e.g. STBL is legitimate.
*/
TC_CD(hpath, paras:="")
{
	BOM := A_IsUnicode ? Chr(0xFEFF) : ""
	if !Instr(hpath, "`r")
		hpath := BOM hpath "`r"
	else
	{
		hpath := BOM hpath
		hpath := StrReplace(hpath, "`r", "`r" BOM)
	}

	dwData := Asc("C") + 256 * Asc("D")
	Len := StrPutVar(hpath, ipath, A_IsUnicode ? "UTF-8" : "CP0", 5)
	cbData := Len + 5
	if paras
	{
		Loop, % strlen(paras)
		{
			NumPut(Asc(SubStr(paras, A_Index, 1)), ipath , Len+A_Index-1, "Char")
		}
	}

	VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
	NumPut(dwData, CopyDataStruct, 0)
	NumPut(cbData, CopyDataStruct, A_PtrSize)
	NumPut(&ipath, CopyDataStruct, 2*A_PtrSize)

	SendMessage, 0x4a, 0, &CopyDataStruct,, ahk_class TTOTAL_CMD
}

/*
Command:
; A  = Active Side
; LP = Left Path            RP = Right Path
; LC = Left List Count      RC = Right List Count
; LI = Left Caret Index     RI = Right Caret Index
; LN = Left Name Caret      RN = Right Name Caret

; SP = Source Path          TP = Target Path
; SC = Source List Count    TC = Target List Count
; SI = Source Caret Index   TI = Target Caret Index
; SN = Source Name Caret    TN = Target Name Caret
*/
TC_G(Command, CmdType="", msg="", hwnd="")
{
	OnMessage(0x4a, "TC_G")
	STATIC TC_ReceiveDataValue:="", TC_DataReceived:=""
	IF ((msg=0x4A) AND (hwnd=A_ScriptHwnd))
	{
		ee:=StrGet(NumGet(CmdType + A_PtrSize * 2))
		OnMessage(0x4a, "TC_G", 0)
		EXIT (TC_ReceiveDataValue:=ee, TC_DataReceived:="1")
	}
	VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0), TC_ReceiveDataValue:="", TC_DataReceived:=""
	CmdType:=(A_IsUnicode ? "GW" : "GA")
	dwData := Asc("G") + 256 * Asc(A_IsUnicode ? "W" : "A")
	cbData := StrPutVar(Command, Command, "cp0")

	NumPut(dwData, CopyDataStruct, 0)
	NumPut(cbData, CopyDataStruct, A_PtrSize)
  NumPut(&Command, CopyDataStruct, 2*A_PtrSize)
  SendMessage, 0x4a, %A_ScriptHwnd%, &CopyDataStruct,, ahk_class TTOTAL_CMD

   While (TC_ReceiveDataValue="") {
      IfEqual, TC_DataReceived,    1, Break
      IfGreaterOrEqual, A_Index, 500, Break
      Sleep,10
   }
   Return TC_ReceiveDataValue
}