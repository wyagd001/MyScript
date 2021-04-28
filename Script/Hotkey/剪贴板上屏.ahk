剪贴板上屏:
;^`::
	if CHPITooltip
	{
		DCHPITooltip()
	return
	}
	WinGet, h_ClipToWin_id, ID, A
	IniRead, CHPIF, %run_iniFile%, 常规, CHPIF   ; 剪贴板预览项目收藏夹(最多5个)
	CHPIFArray := StrSplit(CHPIF, ",")
	CliphistoryPIF := []
	CHPIPage := 1
	cliphistoryPIList := "剪贴板历史项目上屏 - " CHPIPage "/4`n----------------------------------------`n" 
	Loop, % CHPIFNo := CHPIFArray.Length()
	{
		Tmp_Val := ""
		Tmp_Pos := InStr(Tmp_V := getFromTable("history", "data", "id=" CHPIFArray[A_index])[1], "`n")
		cliphistoryPIF[A_index] := Tmp_V
		Tmp_Val := SubStr(Tmp_V, 1, Tmp_Pos=0?50:Tmp_Pos<50?Tmp_Pos-2:50) . (Tmp_Pos=0?StrLen(Tmp_V)<50?"":" ... ":" ... (多行)")
		cliphistoryPIList .= A_index ". " Tmp_Val "`n"
	}
	Num := 9 - CHPIFNo
	ReadcliphistoryPI(36-CHPIFNo)
	Loop, % Num
	{
		Tmp_Val := ""
		Tmp_V := cliphistoryPI[A_index]
		Tmp_V:=LTrim(Tmp_V," `t`n`r")
		Tmp_Pos := InStr(Tmp_V, "`n")
		Tmp_Val := SubStr(Tmp_V, 1, Tmp_Pos=0?50:Tmp_Pos<50?Tmp_Pos-2:50) . (Tmp_Pos=0?StrLen(Tmp_V)<50?"":" ... ":" ... (多行)")
		cliphistoryPIList .= A_index + CHPIFNo ". " Tmp_Val "`n"
	}
	CoordMode, ToolTip
	CoordMode, Caret
	CHPITT_x := A_CaretX + 10, CHPITT_y := A_CaretY + 20
	ToolTip, % cliphistoryPIList, % CHPITT_x, % CHPITT_y
	WinActivate, ahk_class tooltips_class32
	CHPITooltip := 1
	settimer DCHPITooltip, -10000
return

#if CHPITooltip
Space::CHPI2Screen(1)
1::CHPI2Screen()
2::CHPI2Screen()
3::CHPI2Screen()
4::CHPI2Screen()
5::CHPI2Screen()
6::CHPI2Screen()
7::CHPI2Screen()
8::CHPI2Screen()
9::CHPI2Screen()
=::Gosub nextCHPITooltip
-::Gosub prevCHPITooltip
Esc::DCHPITooltip()
~LButton::Gosub MenuClick
#if

nextCHPITooltip:
CHPIPage += 1
if (CHPIPage = 5)
{
	DCHPITooltip()
return
}

cliphistoryPIList := ""
cliphistoryPIList := "剪贴板历史项目上屏 - " CHPIPage "/4`n----------------------------------------`n"
Loop, 9
{
	Tmp_Val := ""
	Tmp_V := cliphistoryPI[(A_index - CHPIFNo + (CHPIPage - 1) * 9)]
	Tmp_V := LTrim(Tmp_V," `t`n`r")
	Tmp_Pos := InStr(Tmp_V, "`n")
	Tmp_Val := SubStr(Tmp_V, 1, Tmp_Pos=0?50:Tmp_Pos<50?Tmp_Pos-2:50) . (Tmp_Pos=0?StrLen(Tmp_V)<50?"":" ... ":" ... (多行)")
	cliphistoryPIList .= A_index ". " Tmp_Val "`n"
}
CoordMode, ToolTip
ToolTip, % cliphistoryPIList, % CHPITT_x, % CHPITT_y
WinActivate, ahk_class tooltips_class32
settimer DCHPITooltip, -10000
return

prevCHPITooltip:
CHPIPage -= 1
if (CHPIPage = 0)
{
	DCHPITooltip()
return
}
cliphistoryPIList := ""
cliphistoryPIList := "剪贴板历史项目上屏 - " CHPIPage "/4`n----------------------------------------`n"
if (CHPIPage = 1)
{
	Loop, % CHPIFNo
	{
		Tmp_Val := ""
		Tmp_Pos := InStr(Tmp_V := CliphistoryPIF[A_index], "`n")
		Tmp_Val := SubStr(Tmp_V, 1, Tmp_Pos=0?50:Tmp_Pos<50?Tmp_Pos-2:50) . (Tmp_Pos=0?StrLen(Tmp_V)<50?"":" ... ":" ... (多行)")
		cliphistoryPIList .= A_index ". " Tmp_Val "`n"
	}
	Loop, % Num
	{
		Tmp_Val := ""
		Tmp_V := cliphistoryPI[A_index]
		Tmp_V := LTrim(Tmp_V, " `t`n`r")
		Tmp_Pos := InStr(Tmp_V, "`n")
		Tmp_Val := SubStr(Tmp_V, 1, Tmp_Pos=0?50:Tmp_Pos<50?Tmp_Pos-2:50) . (Tmp_Pos=0?StrLen(Tmp_V)<50?"":" ... ":" ... (多行)")
		cliphistoryPIList .= A_index + CHPIFNo ". " Tmp_Val "`n"
	}
}
else
{
	Loop, 9
	{
		Tmp_Val := ""
		Tmp_V := cliphistoryPI[(A_index - CHPIFNo + (CHPIPage - 1) * 9)]
		Tmp_V:=LTrim(Tmp_V," `t`n`r")
		Tmp_Pos := InStr(Tmp_V, "`n")
		Tmp_Val := SubStr(Tmp_V, 1, Tmp_Pos=0?50:Tmp_Pos<50?Tmp_Pos-2:50) . (Tmp_Pos=0?StrLen(Tmp_V)<50?"":" ... ":" ... (多行)")
		cliphistoryPIList .= A_index ". " Tmp_Val "`n"
	}
}
CoordMode, ToolTip
ToolTip, % cliphistoryPIList, % CHPITT_x, % CHPITT_y
WinActivate, ahk_class tooltips_class32
settimer DCHPITooltip, -10000
return

CHPI2Screen(Num:=0)
{
	global clipmonitor, CHPIPage, CHPIFNo, h_ClipToWin_id, CliphistoryPIF, cliphistoryPI, cliphistoryPI_ID, CHPIFArray
	BackUp_ClipBoard := ClipboardAll    ; 备份剪贴板
	clipmonitor := 0
	sleep 10
	Clipboard := ""   ; 清空剪贴板

	if Num
		KeyNum := Num
	else
		KeyNum := A_ThisHotkey + 0
	if (CHPIPage = 1) && (KeyNum <= CHPIFNo)
		Clipboard := CliphistoryPIF[KeyNum]
	else
		Clipboard := cliphistoryPI[(KeyNum - CHPIFNo + (CHPIPage - 1) * 9)]

	WinActivate ahk_id %h_ClipToWin_id%
	WinGetClass, h_class, ahk_id %h_ClipToWin_id%
	if(h_class="ConsoleWindowClass")
		send, % Clipboard
	else
		Send, ^{vk56}
	sleep 10
	Clipboard := BackUp_ClipBoard
	sleep 10
	clipmonitor := 1
	DCHPITooltip()
return
}

DCHPITooltip()
{
	global CHPITooltip
	ToolTip
	settimer DCHPITooltip, Off
	CoordMode, Mouse, Screen
	CHPITooltip := 0, cliphistoryPIList := CHPIFNo := h_ClipToWin_id := CliphistoryPIF := cliphistoryPI := cliphistoryPI_ID := CHPIFArray := ""
return
}

MenuClick:
	IfWinNotActive, ahk_class tooltips_class32
	{
		DCHPITooltip()
	Return
	}
	CoordMode, Mouse, Relative
	MouseGetPos, , mY
	mY -= 38
	IfLess, mY, 1, Return
	mY /= 17
	CHPI2Screen(mY+1)
	DCHPITooltip()
return