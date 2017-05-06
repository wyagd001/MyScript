Cando_字符编码查看:
	Gui,66:Default
	Gui,Destroy
	CandySel:="我爱你"

	Gosub,Encode
	Gui, add, text,x5 y5,中文:
	Gui,add,Edit,x120 y5 w255 h20 vCcharacter,%CandySel%
	Gui,add,button,x380 y5 w40 h20 gviewcode,查看

	Gui, add, text,x5 y35 ,系统默认编码(CP0):
	Gui,add,Edit,x120  y35 w300 h20 vcp0,% Trim(cp0)

	Gui, add, text,x5 y+10 ,GBK(CP936):
	Gui,add,Edit,x120 y65 w300 h20 vcp936,% Trim(cp936)

	Gui, add, text,x5 y+10 ,UTF-8(CP65001):
	Gui,add,Edit,x120 y95 w300 h20 vcp65001,% Trim(cp65001)

	Gui, add, text,x5 y+10 ,UTF-16(CP1200):
	Gui,add,Edit,x120 y125 w300 h20 vcp1200,% Trim(cp1200)

	Gui, add, text,x5 y+10 ,UTF-16(CP1201):
	Gui,add,Edit,x120 y155 w300 h20 vcp1201,% Trim(cp1201)

	Gui,show,,中文字符编码查看

Return

viewcode:
	Gui, Submit, NoHide
	if(Ccharacter=CandySel)
		Return
	Else
	{
		CandySel:=Ccharacter
		Gosub,Encode
		GuiControl, , cp0, % Trim(cp0)
		GuiControl, , cp936, % Trim(cp936)
		GuiControl, , cp65001, % Trim(cp65001)
		GuiControl, , cp1200, % Trim(cp1200)
		GuiControl, , cp1201, % Trim(cp1201)
	}
return

Encode:
	SetFormat, integer, H
	cp0:=Encode(CandySel, "cp0")
	cp936:=Encode(CandySel, "cp936")
	cp65001:=Encode(CandySel, "cp65001")
	cp1200:=Encode(CandySel, "cp1200")

	If RegExMatch(CandySel,"[^a-zA-Z0-9\.\?\-\!\s]")
	{
		If A_IsUnicode
			LE:=CandySel
		Else
		Ansi2Unicode(LE,CandySel,936)
		VarSetCapacity(BE, 2*cch:=VarSetCapacity(LE)//2), LCMAP_BYTEREV := 0x800
		DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,LE, UInt,cch, Str,BE, UInt,cch )
		If A_IsUnicode
			cp1201:=Encode(BE, "cp1200")
		Else
			cp1201:=Encode(BE, "cp0")
	}
	else
		cp1201:=Encode(CandySel, "cp1200")
	SetFormat, integer, D
Return

Encode2(Str, Encoding, Separator := " ")
{
	StrCap := StrPut(Str, Encoding)
	VarSetCapacity(ObjStr, StrCap * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1))
	StrPut(Str, &ObjStr, Encoding)
Loop, % StrCap * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1)
ObjCodes .= Separator . NumGet(ObjStr, A_Index - 1, "UChar")
Return, ObjCodes
}

Encode(Str, Encoding, Separator := " ")
{
	StrCap := StrPut(Str, Encoding)
	VarSetCapacity(ObjStr, StrCap * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1))
	StrPut(Str, &ObjStr, Encoding)
	If RegExMatch(Str,"[^a-zA-Z0-9\.\?\-\!\s]")
	{
		Loop, % StrCap * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) - ((encoding="utf-16"||encoding="cp1200") ? 2 : 1)   ; StrPut 返回的长度中包含末尾的字符串截止符 00 ,因此必须减 1。
			{
				If(encoding="utf-8"||encoding="cp65001")
				{
					If(Mod(A_Index , 3)= 0x1)
						ObjCodes .= Separator . SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)  ; 逐字节获取，去除开头的“0x”后连接起来。
					else
						ObjCodes .= SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)
				}
				else  
				{
					If(Mod(A_Index , 2) = 0x1  )
						ObjCodes .= Separator . SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)
					Else
						ObjCodes .= SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)
				}
			}
	}
	Else
	{
		Loop, % StrCap * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) - ((encoding="utf-16"||encoding="cp1200") ? 2 : 1)
     if(encoding="utf-16"||encoding="cp1200")
{
       If(Mod(A_Index , 2) = 0x1  )
			ObjCodes .= Separator . SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)
}
       else
ObjCodes .= Separator . SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)
}
Return, ObjCodes
}

;可参考链接：https://zhuanlan.zhihu.com/p/19712731

Ansi2Unicode(ByRef wString,ByRef sString,  CP = 0)      ;cp=65001 UTF-8   cp=0 default to ANSI code page
{
;该函数映射一个字符串MultiByteStr到一个宽字符（unicode）的字符串WideCharStr。由该函数映射的字符串没必要是多字节字符组。
     nSize := DllCall("MultiByteToWideChar"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &sString
      , "int",  -1
      , "Uint", 0
      , "int",  0)

   VarSetCapacity(wString, nSize * 2,0)

   DllCall("MultiByteToWideChar"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &sString
      , "int",  -1
      , "Uint", &wString
      , "int",  nSize)

Loop, % nSize * 2
    {
        ObjCodes .= SubStr(NumGet(&wString, A_Index - 1, "UChar"), 0)
    }
    Return, ObjCodes
}

Unicode2Ansi(ByRef wString, sString,  CP = 0)
{
	    nSize:=DllCall("kernel32\WideCharToMultiByte", "Uint", CP, "Uint", 0, "Uint", wString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)

	VarSetCapacity(sString, nSize)
	DllCall("kernel32\WideCharToMultiByte", "Uint", CP, "Uint", 0, "Uint", wString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
	Return	sString
}

