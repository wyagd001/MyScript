剪贴板最近的项目:
cliphistoryPI:
;!`::
	IfWinExist, 剪贴板最近的项目 ahk_class AutoHotkeyGUI
	{
		Gui,66:Destroy
		return
	}
refreshcliphistoryPI:
	Gui,66:Destroy
	Gui,66:Default
	IniRead, CHPIF, %run_iniFile%, 常规, CHPIF   ; 剪贴板收藏夹(最多5个)
	CHPIFArray := StrSplit(CHPIF, ",")
	CliphistoryPIF := []
	Loop, % CHPIFNo := CHPIFArray.Length()
	{
		button_y:=(A_index-1)*40+5
		button_y2:= button_y + 15
		Tmp_Val := ""
		Tmp_Pos := InStr(Tmp_V := getFromTable("history", "data", "id=" CHPIFArray[A_index])[1], "`n")
		cliphistoryPIF[A_index] := Tmp_V
		Tmp_Val := SubStr(Tmp_V, 1, Tmp_Pos=0?80:Tmp_Pos<80?Tmp_Pos-2:80) . (Tmp_Pos=0?StrLen(Tmp_V)<80?"":" ... ":" ... (多行文本)")

		Gui, Add, Button, x5 y%button_y% w400 h40 vCHPIF_%A_index% gcopycliphistoryPIF, % Tmp_Val
		Gui, Add, Text, Cyellow x410 y%button_y2% w20 h20 vDCHPIF_%A_index% gDCHPIF, ★
		Gui, Add, Text, Cred x440 y%button_y2% w20 h20 vDCHPI1_%A_index% gDCHPI1, ×
	}
	Num := 15 - CHPIFNo
	ReadcliphistoryPI(Num)
	Loop, % Num
	{
		button_y:=(A_index + CHPIFNo - 1)*40 + 5
		button_y2:= button_y + 15

		Tmp_V:=cliphistoryPI[A_index]
		Tmp_V:=LTrim(Tmp_V," `t`n`r")
		Tmp_Pos := InStr(Tmp_V, "`n")
		Tmp_Val := SubStr(Tmp_V, 1, Tmp_Pos=0?80:Tmp_Pos<80?Tmp_Pos-2:80) . (Tmp_Pos=0?StrLen(Tmp_V)<80?"":" ... ":" ... (多行文本)")
		Gui, Add, Button, x5 y%button_y% w400 h40 vCHPI_%A_index% gcopycliphistoryPI, % Tmp_Val
		Gui, Add, Text, x410 y%button_y2% w20 h20 vSCHPIF_%A_index% gSCHPIF, ☆
		Gui, Add, Text, Cred x440 y%button_y2% w20 h20 vDCHPI2_%A_index% gDCHPI2, ×
	}
	Gui,show,,剪贴板最近的项目
return

ReadcliphistoryPI(Num)  ; 从剪贴板数据库中读取最新的N个条目
{
	local result, Row
	q := "select * from history order by id desc limit " Num
	result := ""
	cliphistoryPI := []
	cliphistoryPI_ID :=[]
	if !DB.GetTable(q, result)
		msgbox error
	loop % result.RowCount
	{
		result.Next(Row)
		cliphistoryPI_ID[A_index]:= Row[1]
		cliphistoryPI[A_index]:= Row[2]
	}
return
}

copycliphistoryPIF:  ; 复制剪贴板最近的项目收藏夹中的条目到剪贴板
	WB_id := StrReplace(A_GuiControl , "CHPIF_", "")
	writecliphistory = 0
	try Clipboard := cliphistoryPIF[WB_id]
	sleep,300
return

copycliphistoryPI:  ; 复制剪贴板最近的项目中的条目到剪贴板
	WB_id := StrReplace(A_GuiControl , "CHPI_", "")
	writecliphistory = 0
	try Clipboard := cliphistoryPI[WB_id]
	sleep,300
return

DCHPIF:  ; 删除剪贴板收藏夹中的条目
	WB_id := StrReplace(A_GuiControl , "DCHPIF_", "")
	CHPIFArray.RemoveAt(WB_id)
	i:=""
	for k,v in CHPIFArray
		i .= v ","
	CHPIF :=  Trim(i, ",")
	IniWrite, % CHPIF, %run_iniFile%, 常规, CHPIF
	Gosub refreshcliphistoryPI
return

SCHPIF:  ; 添加到剪贴板收藏夹
	WB_id := StrReplace(A_GuiControl , "SCHPIF_", "")
	Loop, % CHPIFArray.Length()
	{
		if (CHPIFArray[A_index] = cliphistoryPI_ID[WB_id])
		{
			msgbox 你已经添加了该条目，请勿重复添加。
		return
		}
	}

	CHPIF := cliphistoryPI_ID[WB_id] "," CHPIF
	CHPIF :=  Trim(CHPIF, ",")
	CHPIFArray := StrSplit(CHPIF, ",")
	if (CHPIFArray.Length() > 5)
		CHPIF := CHPIFArray[1] "," CHPIFArray[2] "," CHPIFArray[3] "," CHPIFArray[4] "," CHPIFArray[5] 
	IniWrite, % CHPIF, %run_iniFile%, 常规, CHPIF
	Gosub refreshcliphistoryPI
return

DCHPI1:
	WB_id := StrReplace(A_GuiControl , "DCHPI1_", "")
	deleteHistoryById(CHPIFArray[WB_id])
	CHPIFArray.RemoveAt(WB_id)
	i:=""
	for k,v in CHPIFArray
		i .= v ","
	CHPIF :=  Trim(i, ",")
	IniWrite, % CHPIF, %run_iniFile%, 常规, CHPIF
	Gosub refreshcliphistoryPI
return

DCHPI2:
	cjdata := 0
	WB_id := StrReplace(A_GuiControl , "DCHPI2_", "")
	deleteHistoryById(cliphistoryPI_ID[WB_id])
	Loop, % CHPIFArray.Length()
	{
		if (CHPIFArray[A_index] = cliphistoryPI_ID[WB_id])
		{
			CHPIFArray.delete(A_index)
			cjdata:=1
		}
	}
	if cjdata
	{
		i:=""
		for k,v in CHPIFArray
			i .= v ","
		CHPIF :=  Trim(i, ",")
		IniWrite, % CHPIF, %run_iniFile%, 常规, CHPIF
	}
	Gosub refreshcliphistoryPI
return