; wString		转换后得到的unicode字串
; sString		待转换字串
; CP				待转换字串sString的代码页
; 返回值		转换后得到的unicode字串,wString的地址
; 该函数映射一个字符串 (MultiByteStr) 到一个宽字符 (unicode UTF-16) 的字符串 (WideCharStr)。
; 由该函数映射的字符串没必要是多字节字符组。
; &sString 传入的是地址，所以 sString 变量不能直接传入地址
/* 
; A版运行例子
pp=中文
Ansi2Unicode(qq,pp,936) ; 正确
Ansi2Unicode(qq,&pp,936) ; 错误
*/
;cp=65001 UTF-8   cp=0 default to ANSI code page
Ansi2Unicode(ByRef wString, ByRef sString,  CP = 0)
{
	nSize := DllCall("MultiByteToWideChar", "Uint", CP, "Uint", 0, "Uint", &sString, "int",  -1, "Uint", 0, "int", 0)
	VarSetCapacity(wString, nSize * 2,0)
	DllCall("MultiByteToWideChar", "Uint", CP, "Uint", 0, "Uint", &sString, "int",  -1, "Uint", &wString, "int", nSize)
Return	&wString
}

; wString		待转换的unicode字串  
; sString		转换后得到的字串
; CP				转换后得到的字串sString的代码页，例如 CP=65001，转换得到的字串就是UTF8的字符串
; 返回值		转换后得到的字串sString
; 该函数映射一个宽字符串 (unicode UTF-16) 到一个新的字符串
; 把宽字符串 (unicode UTF-16) 转换成指定代码页的新字符串
; &wString 传入的是地址，所以wString变量不能直接传入地址
/* 
; U版运行例子
qq=中文
Unicode2Ansi(qq,pp,936) ; 正确
Unicode2Ansi(&qq,pp,936) ; 错误
*/
Unicode2Ansi(ByRef wString,ByRef sString,  CP = 0)
{
	nSize := DllCall("WideCharToMultiByte", "Uint", CP, "Uint", 0, "Uint", &wString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	VarSetCapacity(sString, nSize)
	DllCall("WideCharToMultiByte", "Uint", CP, "Uint", 0, "Uint", &wString, "int", -1, "str", sString, "int", nSize, "Uint", 0, "Uint", 0)
	Return	sString
}

; Unicode2Ansi pString → sString
; pString 是地址变量，需直接传入地址
/* 
; 例
pp=中文
Ansi4Unicode(&pp)
*/
Ansi4Unicode(pString, nSize = "")
{
	If (nSize = "")
		nSize:=DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
	VarSetCapacity(sString, nSize)
	DllCall("kernel32\WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", pString, "int", -1, "str", sString, "int", nSize + 1, "Uint", 0, "Uint", 0)
Return	sString
}

; Ansi2Unicode  sString → wString
Unicode4Ansi(ByRef wString, sString, nSize = "")
{
	If (nSize = "")
		nSize:=DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wString, nSize * 2 + 1)
	DllCall("kernel32\MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wString, "int", nSize + 1)
Return	&wString
}

; UrlEncode("伊東エリ", "cp20936")
; cp936			简体中文 GBK GB2312
; cp10002		MAC机上的big5编码，
; cp950			繁体中文 big5
UrlEncode(Url, Enc = "UTF-8")
{
	StrPutVar(Url, Var, Enc)
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	Loop
	{
		Code := NumGet(Var, A_Index - 1, "UChar")
		If (!Code)
			Break
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
		|| Code >= 0x41 && Code <= 0x5A ; A-Z
		|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
		Else
			Res .= "%" . SubStr(Code + 0x100, -1)
	}
	SetFormat, IntegerFast, %f%
Return, Res
}

SkSub_UrlEncode(str, enc="UTF-8")       ;From Ahk Forum
{
    enc:=trim(enc)
    If enc=
        Return str
   hex := "00", func := "msvcrt\" . (A_IsUnicode ? "swprintf" : "sprintf")
   VarSetCapacity(buff, size:=StrPut(str, enc)), StrPut(str, &buff, enc)
   While (code := NumGet(buff, A_Index - 1, "UChar")) && DllCall(func, "Str", hex, "Str", "%%%02X", "UChar", code, "Cdecl")
   encoded .= hex
   Return encoded
}

UrlDecode(Url, Enc = "UTF-8")
{
	Pos := 1
	Loop
	{
		Pos := RegExMatch(Url, "i)(?:%[\da-f]{2})+", Code, Pos++)
		If (Pos = 0)
			Break
		VarSetCapacity(Var, StrLen(Code) // 3, 0)
		StringTrimLeft, Code, Code, 1
		Loop, Parse, Code, `%
			NumPut("0x" . A_LoopField, Var, A_Index - 1, "UChar")
		StringReplace, Url, Url, `%%Code%, % StrGet(&Var, Enc), All
	}
Return, Url
}

StrPutVar(Str, ByRef Var, Enc = "")
{
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
Return, StrPut(Str, &Var, Enc),VarSetCapacity(var,-1)
}

; http://ahkcn.net/thread-1927.html
UnicodeDecode(text)
{
    while pos := RegExMatch(text, "\\u\w{4}")
    {
        tmp := UrlEncodeEscape(SubStr(text, pos + 2, 4))
        text := RegExReplace(text, "\\u\w{4}", tmp, "", 1)
    }
    return text
}

; http://ahkcn.net/thread-1927.html
UrlEncodeEscape(text)
{
    text := "0x" . text
    VarSetCapacity(LE, 2, "UShort")
    NumPut(text, LE)
    return StrGet(&LE, 2)
}

; 发送中文，避免输入法影响 （备份，已用 SendStr 代替）
_SendRaw(Keys)
{
	Len := StrLen(Keys) ; 得到字符串的长度，注意一个中文字符的长度是2
	KeysInUnicode := "" ; 将要发送的字符序列
	Char1 := "" ; 暂存字符1
	Code1 := 0 ; 字符1的ASCII码，值介于 0x0-0xFF (即1~255)
	Char2 := "" ; 暂存字符2
	Index := 1 ; 用于循环
	Loop
	{
		Code2 := 0 ; 字符2的ASCII码
		Char1 := SubStr(Keys, Index, 1) ; 第一个字符
		Code1 := Asc(Char1) ; 得到其ASCII值
		if(Code1 >= 129 And Code1 <= 254 And Index < Len) ; 判断是否中文字符的第一个字符
		{
			Char2 := SubStr(Keys, Index+1, 1) ; 第二个字符
			Code2 := Asc(Char2) ; 得到其ASCII值
			if(Code2 >= 64 And Code2 <= 254) ; 若条件成立则说明是中文字符
			{
				Code1 <<= 8 ; 第一个字符应放到高8位上
				Code1 += Code2 ; 第二个字符放在低8位上
			}
			Index++
		}
		if(Code1 <= 255) ; 如果此值仍<=255则说明是非中文字符，否则经过上面的处理必然大于255
			Code1 := "0" . Code1
		KeysInUnicode .= "{ASC " . Code1 . "}"
		if(Code2 > 0 And Code2 < 64)
		{
			Code2 := "0" . Code2
			KeysInUnicode .= "{ASC " . Code2 . "}"
		}
		Index++
		if(Index > Len)
			Break
	}
	Send % KeysInUnicode
}

; http://ahk8.com/thread-5385.html
; 发送中文，避免输入法影响
SendStr(String)
{
	if(A_IsUnicode)
	{
		Loop, Parse, String
			ascString .= (Asc(A_loopfield)>127 )? A_LoopField : "{ASC 0" . Asc(A_loopfield) . "}"
	}
	else     ;如果非Unicode
	{
		z:=0
		Loop,parse,String
		{
			if RegExMatch(A_LoopField, "[^x00-xff]")
			{
				if (z=1)
				{
					x<<= 8
					x+=Asc(A_loopfield)
					z:=0
					ascString .="{ASC 0" . x . "}"
				}
				else
				{
					x:=asc(A_loopfield)
					z:=1
				}
			}
			else
			{
				ascString .="{ASC 0" . Asc(A_loopfield) . "}"
			}
		}
	}
	SendInput %ascString%
}

; 繁 → 简
fzj(trc)
{
	tmp1:= A_IsUnicode ? trc : Ansi2Unicode(tmp1, trc, 936)
	VarSetCapacity(tmp2, 2*cch:=VarSetCapacity(tmp1)//2), LCMAP_SIMPLIFIED_CHINESE:=0x02000000 
	DllCall( "LCMapStringW", UInt,0x400, UInt,LCMAP_SIMPLIFIED_CHINESE, Str,tmp1, UInt,cch, Str,tmp2, UInt,cch )
return A_IsUnicode ? tmp2 : Unicode2Ansi(tmp2, spc, 936)
}

; 简 → 繁
jzf(spc)
{
	tmp1:= A_IsUnicode ? spc : Ansi2Unicode(tmp1, spc, 936)
	VarSetCapacity(tmp2, 2*cch:=VarSetCapacity(tmp1)//2), LCMAP_TRADITIONAL_CHINESE := 0x4000000
	DllCall( "LCMapStringW", UInt,0x400, UInt,LCMAP_TRADITIONAL_CHINESE, Str,tmp1, UInt,cch, Str,tmp2, UInt,cch )
return A_IsUnicode ? tmp2 : Unicode2Ansi(tmp2, trc,936)
}

; 根据字节取子字符串，如果多删了一个字节，补一个空格
SubStrByByte(text, length)
{
    textForCalc := RegExReplace(text, "[^\x00-\xff]", "`t`t")
    textLength := 0
    realRealLength := 0

    Loop, Parse, textForCalc
    {
        if (A_LoopField != "`t")
        {
            textLength++
            textRealLength++
        }
        else
        {
            textLength += 0.5
            textRealLength++
        }

        if (textRealLength >= length)
        {
            break
        }
    }

    result := SubStr(text, 1, round(textLength - 0.5))

    ; 删掉一个汉字，补一个空格
    if (round(textLength - 0.5) != round(textLength))
        result .= " "

    return result
}

; https://autohotkey.com/board/topic/33510-functionstringcheck/
InStrW(String, Text0)
{
	RegExReplace(Asc(SubStr(String, Pos0 := InStr(String, Text0), 1)) > 127 ? SubStr(String, 1, Pos0+1) : SubStr(String, 1, Pos0), "(?:[^[:ascii:]]{2}|[[:ascii:]])", "", ErrorLevel)
return ErrorLevel
}

SubStrW(String, Pos0, Len0 = 360)
{
	RegExMatch(String, "(?:[^[:ascii:]]{2}|[[:ascii:]]){" (Pos0 > 0 ? Pos0-1 : -Pos0 < (StrLenW := StrLenW(String)) ? StrLenW+Pos0-1 : 0) "}((?:[^[:ascii:]]{2}|[[:ascii:]]){0," Len0 "})", SubStrW)
return SubStrW1
}

StrLenW(String)
{
	RegExReplace(String, "(?:[^[:ascii:]]{2}|[[:ascii:]])", "", ErrorLevel)
return ErrorLevel
}

SubStr0(String, Pos0, Len0 = 360, StrCheck = 3)
{
	If (Pos0 <> 1 && Pos0+StrLen(String) <> 1 && StrLenW(String0 := SubStr(String, 1, Pos0 > 0 ? Pos0-1 : StrLen(String) + Pos0 - 1)) = StrLenW(SubStr(String0, 1, StrLen(String0)-1)))
		Len0 := Mod(StrCheck, 2) = 1 ? Len0 + 1 : Pos0 = 0 ? 0 : Len0 - 1, Pos0 := Mod(StrCheck, 2) = 1 ? Pos0 - 1 : Pos0 + 1
return SubStr(String, Pos0, (StrLenW(SubStr(String, Pos0, Len0-1)) = StrLenW(SubStr(String, Pos0, Len0))) ? StrCheck // 2 = 1 ? Len0+1 : Len0-1 : Len0)
}

StrCheck(String)
{
return RegExReplace(String, "^[^[:ascii:]]?((?:[^[:ascii:]]{2})*(?:[[:ascii:]].*[[:ascii:]]|[[:ascii:]])(?:[^[:ascii:]]{2})*)[^[:ascii:]]?$", "$1")
}

/*
Original script author: ahklerner
autohotkey.com/board/topic/15831-convert-string-to-hex/?p=102873
*/
StringToHex(String)
{
	formatInteger := A_FormatInteger 	;Save the current Integer format
	SetFormat, Integer, Hex ; Set the format of integers to their Hex value
	
	;Parse the String
	Loop, Parse, String 
	{
		CharHex := Asc(A_LoopField) ; Get the ASCII value of the Character (will be converted to the Hex value by the SetFormat Line above)
		StringTrimLeft, CharHex, CharHex, 2 ; Comment out the following line to leave the '0x' intact
		HexString .= CharHex ;. " "     ; Build the return string
	}
	SetFormat, Integer,% formatInteger ; Set the integer format to what is was prior to the call
	
	HexString = %HexString% ; Remove blankspaces	
Return HexString
}

toHex( ByRef V, ByRef H, dataSz:=0 )
{ ; http://goo.gl/b2Az0W (by SKAN)
	P := ( &V-1 ), VarSetCapacity( H,(dataSz*2) ), Hex := "123456789ABCDEF0"
	Loop, % dataSz ? dataSz : VarSetCapacity( V )
		H  .=  SubStr(Hex, (*++P >> 4), 1) . SubStr(Hex, (*P & 15), 1)
}

ZTrim( N := "" )
{ ; SKAN /  CD:01-Jul-2017 | LM:03-Jul-2017 | Topic: goo.gl/TgWDb5
	Local    V  := StrSplit( N, ".", A_Space ) 
	Local    V0 := SubStr( V.1,1,1 ),   V1 := Abs( V.1 ),      V2 :=  RTrim( V.2, "0" )
Return ( V0 = "-" ? "-" : ""   )  ( V1 = "" ? 0 : V1 )   ( V2 <> "" ? "." V2 : "" )
}