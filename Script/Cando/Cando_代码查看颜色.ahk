Cando_颜色查看:
	Gui,66:Default
	Gui,Destroy
	Gui,+Lastfound +AlwaysOnTop
	IfInString, CandySel,`,
	{
		IfInString, CandySel,rgb
			RegExMatch(CandySel,"i)rgb\(?(\s*\d+\s*),(\s*\d+\s*),(\s*\d+\s*)\)",m)
		else
			RegExMatch(CandySel,"i)(\s*\d+\s*),(\s*\d+\s*),(\s*\d+\s*)",m)
		SetFormat, Integer, % (f := A_FormatInteger) = "D" ? "H" : f 
		StringReplace, Color_Hex, CandySel, %m%, %	RegExReplace(RegExReplace(m1+0 m2+0 m3+0,"0x(.)(?=$|0x)", "0$1"), "0x") 
		SetFormat, Integer, %f%
		Color_RGB := CandySel
	}
	else
	{
		RegExMatch(CandySel, "([a-fA-F\d]){6}",Color_Hex)
		Color_RGB := Hex2RGB(Color_Hex)
		Color_RGB := "RGB(" Color_RGB ")"
	}

	Gui, add, text,x7 ,颜色代码(Hex):
	Gui, Add, edit, x+10 readonly w120,%Color_Hex%
	Gui, add, text,x7 ,颜色代码(RGB):
	Gui, Add, edit, x+10 readonly w120,%Color_RGB%
	Gui, add, text,x7 ,颜色:
	Gui, Add, Progress, x+10 c%Color_Hex% w170 h170,100
	Gui,Show, w230 h230,颜色查看
Return

Cando_ColorPicker:
	if RegExMatch(CandySel, "([a-fA-F\d]){6}",mCol)
		Run,% A_ScriptDir "\Bin\ColorPicker.exe " . mCol . "ff"

	else if RegExMatch(CandySel, "\((?P<col1>25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\,(?P<col2>25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\,(?P<col3>25[0-5]|2[0-4]\d|[0-1]\d{2}|[1-9]?\d)\)",mCol){
		mCol :=A_ScriptDir "\Bin\ColorPicker.exe " . (color_dec2hex(mColcol1)color_dec2hex(mColcol2)color_dec2hex(mColcol3)) . "ff"
		Run, % mCol
	}
Return

Hex2RGB(_hexRGB, _delimiter="")
{
	local color, r, g, b, decimalRGB

	If _delimiter =
		_delimiter = ,
	color += "0x" . _hexRGB
	b := color & 0xFF
	g := (color & 0xFF00) >> 8
	r := (color & 0xFF0000) >> 16
	decimalRGB := r _delimiter g _delimiter b
	Return decimalRGB
}

RGB2Hex(_decimalRGB, _delimiter="")
{
	local weight, color, hexRGB

	If _delimiter =
		_delimiter = ,
	weight = 16
	SetFormat Integer, Hex
	color := 0x1000000
	Loop Parse, _decimalRGB, %_delimiter%
	{
		color += A_LoopField << weight
		weight -= 8
	}
	StringTrimLeft hexRGB, color, 3
	SetFormat Integer, D
	Return hexRGB
}

;十进制转换为十六进制的函数，参数为10进制数整数.
color_dec2hex(d)
{
SetFormat, integer, hex
h :=d+0
SetFormat, integer, dec ;恢复至正常的10进制计算习惯
h := substr(h,3)  ; 去掉十六进制前面的 0x
h :="0" . h
h := substr(h,-1)
return h
}