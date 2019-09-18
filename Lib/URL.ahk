; Modified by GeekDude from http://goo.gl/0a0iJq
class URL {
	Encode(Url) { ; keep ":/;?@,&=+$#."
		return this.UriEncode(Url, "[0-9a-zA-Z:/;?@,&=+$#.]")
	}
	Decode(url) {
		return this.UriDecode(url)
	}
	
	
	UriEncode(Uri, RE="[0-9A-Za-z]") {
		VarSetCapacity(Var, StrPut(Uri, "UTF-8"), 0), StrPut(Uri, &Var, "UTF-8")
		While Code := NumGet(Var, A_Index - 1, "UChar")
			Res .= (Chr:=Chr(Code)) ~= RE ? Chr : Format("%{:02X}", Code)
		Return, Res
	}

	UriDecode(Uri) {
		Pos := 1
		While Pos := RegExMatch(Uri, "i)(%[\da-f]{2})+", Code, Pos)
		{
			VarSetCapacity(Var, StrLen(Code) // 3, 0), Code := SubStr(Code,2)
			Loop, Parse, Code, `%
				NumPut("0x" A_LoopField, Var, A_Index-1, "UChar")
			Decoded := StrGet(&Var, "UTF-8")
			Uri := SubStr(Uri, 1, Pos-1) . Decoded . SubStr(Uri, Pos+StrLen(Code)+1)
			Pos += StrLen(Decoded)+1
		}
		Return, Uri
	}
}