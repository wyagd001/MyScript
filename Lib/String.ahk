; wString	转换后得到的unicode字串
; sString		待转换字串
; CP					待转换字串sString的代码页
; 返回值		转换后得到的unicode字串,wString的地址
Ansi2Unicode(ByRef wString,ByRef sString,  CP = 0)
;cp=65001 UTF-8   cp=0 default to ANSI code page
{
; 该函数映射一个字符串 (MultiByteStr) 到一个宽字符 (unicode UTF-16) 的字符串 (WideCharStr)。
; 由该函数映射的字符串没必要是多字节字符组。
; &sString 传入的是地址，所以 sString 变量不能直接传入地址
/* 
; A版运行例子
pp=中文
Ansi2Unicode(qq,pp,936) ; 正确
Ansi2Unicode(qq,&pp,936) ; 错误
*/
     nSize := DllCall("MultiByteToWideChar"
      , "Uint", CP
      , "Uint", 0
      , "Uint", &sString   ; 传入的是字串的地址
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
Return	&wString
}

; wString	待转换的unicode字串  
; sString		转换后得到的字串
; CP					转换后得到的字串sString的代码页，例如 CP=65001，转换得到的字串就是UTF8的字符串
; 返回值		转换后得到的字串sString
Unicode2Ansi(ByRef wString,ByRef sString,  CP = 0)
{
; 该函数映射一个宽字符串 (unicode UTF-16) 到一个新的字符串
; 把宽字符串 (unicode UTF-16) 转换成指定代码页的新字符串
; &wString 传入的是地址，所以wString变量不能直接传入地址
/* 
; U版运行例子
qq=中文
Unicode2Ansi(qq,pp,936) ; 正确
Unicode2Ansi(&qq,pp,936) ; 错误
*/
	nSize:=DllCall("WideCharToMultiByte", "Uint", CP, "Uint", 0, "Uint", &wString, "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)

	VarSetCapacity(sString, nSize)
	DllCall("WideCharToMultiByte", "Uint", CP, "Uint", 0, "Uint", &wString, "int", -1, "str", sString, "int", nSize, "Uint", 0, "Uint", 0)
	Return	sString
}

; Unicode2Ansi pString → sString
Ansi4Unicode(pString, nSize = "")
{
; pString 是地址变量，需直接传入地址
/* 
; 例
pp=中文
Ansi4Unicode(&pp)
*/
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

; ; 发送中文，避免输入法影响
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