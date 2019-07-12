cliphistoryPI:
^`::
Gui,66:Destroy
Gui,66:Default
IniRead, CHPIF, %run_iniFile%, 常规, CHPIF
CHPIFArray := StrSplit(CHPIF, ",")
Loop, % CHPIFNo := CHPIFArray.Length()
{
button_y:=(A_index-1)*40+5
button_y2:= button_y + 15
Gui, Add, Button, x5 y%button_y% w200 h40 vCHPIF_%A_index% gcopycliphistoryPIF, % getFromTable("history", "data", "id=" CHPIFArray[A_index])[1]
Gui, Add, Text, Cyellow x210 y%button_y2% w20 vDCHPIF_%A_index% h20 gDCHPIF, ★
}
Num := 15 - CHPIFNo
ReadcliphistoryPI(Num)
Loop, % Num
{
button_y:=(A_index + CHPIFNo - 1)*40 + 5
button_y2:= button_y + 15
Gui, Add, Button, x5 y%button_y% w200 h40 vCHPI_%A_index% gcopycliphistoryPI, % cliphistoryPI[A_index]
Gui, Add, Text, x210 y%button_y2% w20 h20 vSCHPIF_%A_index% gSCHPIF, ☆
}
Gui,show,,剪贴板最近的项目
return

ReadcliphistoryPI(Num)
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

copycliphistoryPIF:
WB_id := StrReplace(A_GuiControl , "CHPIF_", "")
		temp_read := getFromTable("history", "data", "id=" CHPIFArray[WB_id])[1]
		try Clipboard := temp_Read
return

copycliphistoryPI:
WB_id := StrReplace(A_GuiControl , "CHPI_", "")
		temp_read := getFromTable("history", "data", "id=" cliphistoryPI_ID[WB_id])[1]
		try Clipboard := temp_Read
return

DCHPIF:
WB_id := StrReplace(A_GuiControl , "DCHPIF_", "")
CHPIFArray.RemoveAt(WB_id)
i:=""
for k,v in CHPIFArray
i .= v ","
CHPIF :=  Trim(i, ",")
IniWrite, % CHPIF, %run_iniFile%, 常规, CHPIF
Gosub cliphistoryPI
return

SCHPIF:
WB_id := StrReplace(A_GuiControl , "SCHPIF_", "")
CHPIF := cliphistoryPI_ID[WB_id] "," CHPIF
CHPIF :=  Trim(CHPIF, ",")
CHPIFArray := StrSplit(CHPIF, ",")
if (CHPIFArray.Length() > 5)
CHPIF := CHPIFArray[1] "," CHPIFArray[2] "," CHPIFArray[3] "," CHPIFArray[4] "," CHPIFArray[5] 
IniWrite, % CHPIF, %run_iniFile%, 常规, CHPIF
Gosub cliphistoryPI
return