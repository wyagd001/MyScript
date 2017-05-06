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
}

Unicode2Ansi(ByRef wString,ByRef sString,  CP = 0)
{
	    nSize:=DllCall("WideCharToMultiByte", "Uint", CP, "Uint", 0, "Uint", &wString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)

	VarSetCapacity(sString, nSize)
	DllCall("WideCharToMultiByte", "Uint", CP, "Uint", 0, "Uint", &wString, "int", -1, "str", sString, "int", nSize, "Uint", 0, "Uint", 0)
	Return	sString
}

; Unicode2Ansi pString → sString
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
; UrlEncode("伊東エリ", "cp20936")
; GB2312 GBK  936
; cp10002是MAC机上的big5编码，
; 950是ANSI的标准


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

/*
;2016/11/13  移除该函数
;运行.ahk  引用    水平垂直最大化 功能使用
 DecodeInteger( p_type, p_address, p_offset, p_hex=true )
 {
    old_FormatInteger := A_FormatInteger
    ifEqual, p_hex, 1, SetFormat, Integer, hex
    else, SetFormat, Integer, dec
    StringRight, size, p_type, 1
    loop, %size%
        value += *( ( p_address+p_offset )+( A_Index-1 ) ) << ( 8*( A_Index-1 ) )
    if ( size <= 4 and InStr( p_type, "u" ) != 1 and *( p_address+p_offset+( size-1 ) ) & 0x80 )
        value := -( ( ~value+1 ) & ( ( 2**( 8*size ) )-1 ) )
    SetFormat, Integer, %old_FormatInteger%
    return, value
  }
*/