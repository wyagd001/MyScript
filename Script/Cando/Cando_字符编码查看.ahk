Cando_字符编码查看:
	Gui,66:Default
	Gui,Destroy
	;CandySel:="我不爱你开"

	Gosub,Encode
	Gui, add, text,x5 y5,中文:
	Gui,add,Edit,x120 y5 w255 h20 vCcharacter,%CandySel%
	Gui,add,button,x380 y5 w40 h20 gviewcode,查看

	Gui, add, text,x5 y35 ,系统默认编码(CP0):
	Gui,add,Edit,x120  y35 w300 h20 vcp0,% Trim(cp0)

	Gui, add, text,x5 y+10 ,GBK(CP936):
	Gui,add,Edit,x120 y65 w300 h20 vcp936,% Trim(cp936)

	Gui, add, text,x5 y+10 ,GBK(CP950):
	Gui,add,Edit,x120 y95 w300 h20 vcp950,% Trim(cp950)

	Gui, add, text,x5 y+10 ,UTF-8(CP65001):
	Gui,add,Edit,x120 y125 w300 h20 vcp65001,% Trim(cp65001)

	Gui, add, text,x5 y+10 ,UTF-16(CP1200):
	Gui,add,Edit,x120 y155 w300 h20 vcp1200,% Trim(cp1200)

	Gui, add, text,x5 y+10 ,UTF-16(CP1201):
	Gui,add,Edit,x120 y185 w300 h20 vcp1201,% Trim(cp1201)

	Gui, add, text,x5 y+10 ,繁体汉字:
	Gui,add,Edit,x120 y215 w300 h20 vtrc,% trc

	Gui,show,,中文字符编码查看
	SetFormat, integer, D
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
		GuiControl, , cp950, % Trim(cp950)
		GuiControl, , cp65001, % Trim(cp65001)
		GuiControl, , cp1200, % Trim(cp1200)
		GuiControl, , cp1201, % Trim(cp1201)
		GuiControl, , trc, % trc
	}
return

Encode:
	SetFormat, integer, H
	cp0:=Encode(CandySel, "cp0")
	cp936:=Encode(CandySel, "cp936")
	cp950:=Encode(CandySel, "cp950")
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
		if(strlen(cp1200) !=strlen(cp1201))
		{
			toHex(BE,o)
			cp1201:=o
		}
	}
	else
		cp1201:=Encode(CandySel, "cp1200")

		VarSetCapacity(trc1, 2*cch:=VarSetCapacity(LE)//2), LCMAP_TRADITIONAL_CHINESE := 0x4000000
		DllCall( "LCMapStringW", UInt,0x400, UInt,LCMAP_TRADITIONAL_CHINESE, Str,LE, UInt,cch, Str,trc1, UInt,cch )

		If A_IsUnicode
			trc :=trc1
		else
			Unicode2Ansi(trc1, trc,936)


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
				else If(encoding="cp950")
					ObjCodes .= SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)
				else  
				{
					h:=NumGet(ObjStr, A_Index - 1, "UChar")
					if(h=0x0)
						H:="00"
					else if (h<0x10) and  (h!=0x0)
						H:="0" SubStr(h:=NumGet(ObjStr, A_Index - 1, "UChar"), 3)
					else
						H:=SubStr(h:=NumGet(ObjStr, A_Index - 1, "UChar"), 3)
					If(Mod(A_Index , 2) = 0x1  )
						ObjCodes .= Separator . H
					Else
						ObjCodes .= H
				}
			}
	}
	Else
	{
		Loop, % StrCap * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) - ((encoding="utf-16"||encoding="cp1200") ? 2 : 1)
		{
			if(encoding="utf-16"||encoding="cp1200")
			{
				If(Mod(A_Index , 2) = 0x1  )
					ObjCodes .= Separator . SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)
			}
			else
				ObjCodes .= Separator . SubStr(NumGet(ObjStr, A_Index - 1, "UChar"), 3)
		}
	}
Return, ObjCodes
}

;可参考链接：https://zhuanlan.zhihu.com/p/19712731

toHex( ByRef V, ByRef H, dataSz:=0 )  { ; http://goo.gl/b2Az0W (by SKAN)
    P := ( &V-1 ), VarSetCapacity( H,(dataSz*2) ), Hex := "123456789ABCDEF0"
    Loop, % dataSz ? dataSz : VarSetCapacity( V )
        H  .=  SubStr(Hex, (*++P >> 4), 1) . SubStr(Hex, (*P & 15), 1)
}
