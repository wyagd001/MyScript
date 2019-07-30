^`::
	if CHPITooltip
	{
		DCHPITooltip()
	return
	}
	WinGet, OutputWId, ID, A
	IniRead, CHPIF, %run_iniFile%, 常规, CHPIF   ; 剪贴板预览项目收藏夹(最多5个)
	CHPIFArray := StrSplit(CHPIF, ",")
	cliphistoryPIList := "剪贴板历史项目上屏`n----------------------------------------`n" 
	Loop, % CHPIFNo := CHPIFArray.Length()
	{
		temp_V := ""
		temp_V := SubStr(getFromTable("history", "data", "id=" CHPIFArray[A_index])[1], 1, 40)
		cliphistoryPIList .= A_index "." temp_V "`n"
	}
	Num := 9 - CHPIFNo
	ReadcliphistoryPI(Num)
	Loop, % Num
	{
		temp_V := ""
		temp_V := SubStr(cliphistoryPI[A_index], 1, 40)
		cliphistoryPIList .= A_index + CHPIFNo "." temp_V "`n"
	}
	ToolTip, % cliphistoryPIList, A_CaretX + 10, A_CaretY + 20
	CHPITooltip := 1
return

DCHPITooltip()
{
	global CHPITooltip
	ToolTip
	CHPITooltip := 0
	CHPIFArray := cliphistoryPIList := CHPIFNo :=cliphistoryPI := ""
return
}

#if CHPITooltip
Space::CHPI2Screen(1)
1::CHPI2Screen(1)
2::CHPI2Screen(2)
3::CHPI2Screen(3)
4::CHPI2Screen(4)
5::CHPI2Screen(5)
6::CHPI2Screen(6)
7::CHPI2Screen(7)
8::CHPI2Screen(8)
9::CHPI2Screen(9)
Esc::DCHPITooltip()
#if

CHPI2Screen(Num)
{
	global monitor, CHPIFNo, OutputWId, cliphistoryPI_ID, CHPIFArray
	Saved_ClipBoard := ClipboardAll    ; 备份剪贴板
	Clipboard := ""   ; 清空剪贴板
	if (A_ThisHotkey = "Space")
		Num := 1
	if (Num <= CHPIFNo)
	{
		Clipboard := getFromTable("history", "data", "id=" CHPIFArray[Num])[1]
	}
	else
	{
		Clipboard := getFromTable("history", "data", "id=" cliphistoryPI_ID[Num - CHPIFNo])[1]
	}
	WinActivate ahk_id %OutputWId%
	Send, ^{vk56}
	sleep 100
	Clipboard:=Saved_ClipBoard
	sleep 100
	monitor := 1
	DCHPITooltip()
return
}
