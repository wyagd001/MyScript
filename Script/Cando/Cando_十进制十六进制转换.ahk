Cando_十进制十六进制转换:
	Gui,66:Default
	Gui,Destroy
	Gosub,NumCon
	Gui, add, text,x5 y5,数字:
	Gui,add,Edit,x70 y5 w300 h20 vNumSel,%CandySel%
	Gui,add,button,x380 y5 w60 h20  gNumSwap,数字交换

	Gui, add, text,x5 y35 ,十进制:
	Gui,add,Edit,x70  y35 w300 h20 vNumDec,% Trim(NumDec)
	Gui,add,button,x380 y35 w60 h20  gNumDectoHex,16 进制

	Gui, add, text,x5 y65 ,十六进制:
	Gui,add,Edit,x70 y65 w300 h20 vNumHex,% Trim(NumHex)
	Gui,add,button,x380 y65 w60 h20  gNumHextoDec,10 进制

	Gui,show,,十进制十六进制转换
Return

NumCon:
	If CandySel Is digit
	{
		NumDec:=CandySel
		NumHex:=dec2hex(CandySel)
	}
	Else If CandySel Is Xdigit
	{
		numtemp:=InStr(CandySel, "0x")?CandySel:"0x" CandySel
		NumDec:=hex2dec(numtemp)
		NumHex:=numtemp
	}
	numtemp=
Return

NumDectoHex:
	Gui, Submit, NoHide
	NumHex:=dec2hex(NumDec)
	GuiControl, , NumHex, % NumHex
	GuiControl, , NumSel
Return

NumHextoDec:
	Gui, Submit, NoHide
	numtemp:=InStr(NumHex, "0x")?NumHex:"0x" NumHex
	NumDec:=hex2dec(numtemp)
	GuiControl, , NumDec, % NumDec
	GuiControl, , NumSel
Return

NumSwap:
	Gui, Submit, NoHide
	GuiControl, , NumDec, % NumHex
	GuiControl, , NumHex, % NumDec
Return