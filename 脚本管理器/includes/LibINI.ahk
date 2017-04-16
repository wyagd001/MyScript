/*
		Title: INI Library

		A set of functions for modifying INI files in memory and writing them later to file.
		Useful for parsing a large data sets with minimal disk reads.

		License:
			- Version 1.08 by Titan <http://www.autohotkey.net/~Titan/#ini>
			- zlib License <http://www.autohotkey.net/~Titan/zlib.txt>
*/

/*

		Function: ini_Read
			Get the value of a key within a specifed section.

		Parameters:
			var - ini object
			sec - name of section to look under
			key - key name
			default - (optional) value to return if key was not found

		Returns:
			Key value.

		Example:

> ini_Load(phpconfig, ProgramFiles . "\PHP\php.ini") ; load INI file
> ; read variable under section named "MySQL":
> links := ini_Read(phpconfig, "MySQL", "mysql.max_links")
> MsgBox, %links%

*/
ini_Read(ByRef var, sec, key, default = "") {
	NumPut(160, var, 0, "UChar")
	f = `n%sec%/%key%=
	StringGetPos, p, var, %f%
	If ErrorLevel = 0
	{
		StringGetPos, p, var, =, , %p%
		StringMid, v, var, p += 2, InStr(var, "`n", "", p) - p
	}
	NumPut(0, var, 0, "UChar")
	Return, v == "" ? default : _ini_unescape(v)
}

/*

		Function: ini_Delete
			Removes a key within a specifed section.

		Parameters:
			var - ini object
			sec - name of section to
			look under
			key - key name

*/
ini_Delete(ByRef var, sec, key) {
	NumPut(160, var, 0, "UChar")
	f = `n%sec%/%key%=
	StringGetPos, p, var, %f%
	If ErrorLevel = 0
		var := SubStr(var, 1, p) . SubStr(var, 1 + InStr(var, "`n", "", p + 2))
	NumPut(0, var, 0, "UChar")
	Return, true
}

/*

		Function: ini_Write
			Change the value of a key within a section or create one if it does not exist.

		Parameters:
			var - ini object
			sec - name of section to look under
			key - key name
			value - a string to store as the keys content

		Returns:
			Key value.

*/
ini_Write(ByRef var, sec, key, value = "") {
	NumPut(160, var, 0, "UChar")
	f = `n%sec%/%key%=
	l := _ini_escape(value)
	StringGetPos, p, var, %f%
	If ErrorLevel = 1
	{
		var = %var%%f%%l%`n
		NumPut(0, var, 0, "UChar")
		Return, false
	}
	p += StrLen(f) + 1
	StringGetPos, p1, var, `n, , p
	StringLeft, d1, var, p - 1
	StringTrimLeft, d2, var, p1
	var = %d1%%l%%d2%
	NumPut(0, var, 0, "UChar")
	Return, true
}

/*

		Function: ini_MoveKey
			Copies or moves a key and its value from one section to another.

		Parameters:
			var - ini object
			from - name of parent section to the specified key
			to - section to inherit the new key
			copy - true to remove the old key, false otherwise

		Returns:
			True if the key was found and moved.

*/
ini_MoveKey(ByRef var, from, to, key, copy = false) {
	NumPut(160, var, 0, "UChar")
	to := SubStr(var, InStr(var, "`n" . to . "/") + 1, StrLen(to))
	f = `n%from%/%key%
	StringGetPos, p, var, %f%
	If ErrorLevel = 1
	{
		NumPut(0, var, 0, "UChar")
		Return, false
	}
	p++
	StringGetPos, p1, var, `n, , p
	StringMid, e, var, p, p1 - p + 2
	v := SubStr(e, InStr(e, "=") + 1, -1)
	StringGetPos, p, var, `n%to%/%key%=
	If ErrorLevel = 0
	{
		p++
		StringGetPos, p1, var, `n, , p
		StringMid, r, var, p, p1 - p + 2
		StringReplace, var, var, %r%, `n%to%/%key%=%v%`n
	}
	Else var = %var%`n%to%/%key%=%v%
	If (!copy)
		StringReplace, var, var, %e%
	NumPut(0, var, 0, "UChar")
	Return, true
}

/*

		Function: ini_FindKeysRE
			Get a list of key names for a section from a regular expression.

		Parameters:
			var - ini object
			sec - name of section to look under
			exp - regular expression for key name

		Returns:
			List of `n (LF) delimited key names.

*/
ini_FindKeysRE(ByRef var, sec, exp) {
	NumPut(160, var, 0, "UChar")
	s = %sec%/
	StringLen, b, s
	b++
	Loop, Parse, var, `n
	{
		If A_LoopField =
			Continue
		StringMid, k, A_LoopField, b, InStr(A_LoopField, "=") - b
		If (InStr(A_LoopField, s) == 1 and RegExMatch(k, exp))
			l = %l%%k%`n
	}
	NumPut(0, var, 0, "UChar")
	Return, l
}

/*

		Function: ini_GetKeys
			Get a list of key names for a section.

		Parameters:
			var - ini object
			sec - name of section to look under

		Returns:
			List of `n (LF) delimited key names.

*/
ini_GetKeys(ByRef var, sec = "") {
	NumPut(160, var, 0, "UChar")
	p = 0
	Loop {
		StringGetPos, p, var, `n%sec%/, , p
		If ErrorLevel = 1
			Break
		StringGetPos, p1, var, /, , p
		StringGetPos, p2, var, =, , p
		p1 += 2
		StringMid, n, var, p1, p2 - p1 + 1
		l = %l%%n%`n
		p++
	}
	NumPut(0, var, 0, "UChar")
	l:=RegExReplace(l,"(^\s*|\s*$)")
	Return, l
}

/*

		Function: ini_FindSectionsRE
			Get a list of section names that match a regular expression.

		Parameters:
			var - ini object
			exp - regular expression for section names

		Returns:
			List of `n (LF) delimited section names.

*/
ini_FindSectionsRE(ByRef var, exp) {
	NumPut(160, var, 0, "UChar")
	Loop, Parse, var, `n
	{
		If A_LoopField =
			Continue
		StringLeft, s, A_LoopField, InStr(A_LoopField, "/") - 1
		If (RegExMatch(s, exp) and !InStr(l, s . "`n"))
			l = %l%%s%`n
	}
	NumPut(0, var, 0, "UChar")
	Return, l
}

/*

		Function: ini_GetSections
			Get the complete list of sections.

		Parameters:
			var - ini object

		Returns:
			List of `n (LF) delimited section names.

*/
ini_GetSections(ByRef var) {
	NumPut(160, var, 0, "UChar")
	Loop, Parse, var, `n
	{
		StringGetPos, p, A_LoopField, /
		StringLeft, n, A_LoopField, p
		n = %n%`n
		If (!InStr(s, n))
			s = %s%%n%
	}
	NumPut(0, var, 0, "UChar")
	s:=RegExReplace(s,"(^\s*|\s*$)")
	Return, s
}

/*

		Function: ini_MergeSections
			Merges two sections.

		Parameters:
			var - ini object
			from - section to move
			to - section to inherit new keys
			replace - true to replace existing keys from the destination section

		Returns:
			Number of keys moved.

*/
ini_MergeSections(ByRef var, from, to, replace = true) {
	NumPut(160, var, 0, "UChar")
	f = %from%/
	t = %to%/
	StringGetPos, p, var, %t%
	StringMid, t, var, p + 1, StrLen(t)
	StringLen, l, f
	Loop, Parse, var, `n
	{
		If A_LoopField =
			Continue
		If (InStr(A_LoopField, f) == 1) {
			StringGetPos, p, A_LoopField, =
			StringMid, k, A_LoopField, l + 1, p - l
			StringMid, v, A_LoopField, p + 2
			e = `n%t%%k%=%v%`n
			StringGetPos, p, var, `n%t%%k%=
			If ErrorLevel = 0
			{
				If replace
				{
					p++
					StringGetPos, p1, var, `n, , p
					StringMid, x, var, p, p1 - p + 2
					StringReplace, var, var, %x%, %e%
				}
			}
			Else var = %var%%e%
			StringReplace, var, var, `n%f%%k%=%v%`n
			c++
		}
	}
	NumPut(0, var, 0, "UChar")
	Return, c
}

/*

		Function: ini_DeleteSection
			Get the complete list of sections.

		Parameters:
			var - ini object
			sec - name of section

		Returns:
			Number of child keys removed.

*/
ini_DeleteSection(ByRef var, sec) {
	NumPut(160, var, 0, "UChar")
	n = %sec%/
	Loop, Parse, var, `n
	{
		If A_LoopField =
			Continue
		If (InStr(A_LoopField, n) == 1) {
			StringReplace, var, var, `n%A_LoopField%`n
			c++
		}
	}
	NumPut(0, var, 0, "UChar")
	Return, c
}


/*

		Function: ini_Duplicate
			Copies the INI variable to another.

		Parameters:
			var - ini object
			newVar - new ini object

		Returns:
			True if data was copied successfully, flase otherwise.

*/
ini_Duplicate(ByRef var, ByRef newVar) {
	NumPut(160, var, 0, "UChar")
	newVar := var
	NumPut(0, newVar, 0, "UChar")
	NumPut(0, var, 0, "UChar")
	Return, VarSetCapacity(var) == VarSetCapacity(newVar)
}

/*

		Function: ini_ToXML
			Converts the INI structure to XML.

		Parameters:
			var - ini object
			ind - (optional) tag indentation character(s) (default: two spaces ("  "))
			root - (optional) root element (default: ini)

		Remarks:
			Empty key nodes are automatically fused.

		Returns:
			An XML document.

		Example:

> ini_Load(phpconfig, ProgramFiles . "\PHP\php.ini")
> xmlsource := ini_ToXML(phpconfig)
>
> ; the following requires the xpath library:
> xpath_load(xmldata, xmlsource)
> MsgBox, % xpath(xmldata, "/ini/PHP/*[3]")

*/
ini_ToXML(ByRef var, ind = "  ", root = "ini") {
	NumPut(160, var, 0, "UChar")
	VarSetCapacity(x, StrLen(var) * 1.5)
	x = <?xml version="1.0" encoding="iso-8859-1"?>`n<%root%>
	Loop, Parse, var, `n,  
	{
		If A_LoopField =
			Continue
		StringLeft, s, A_LoopField, b := InStr(A_LoopField, "/") - 1
		StringMid, k, A_LoopField, b += 2, InStr(A_LoopField, "=") - b
		StringTrimLeft, v, A_LoopField, InStr(A_LoopField, "=")
		If s != %ls%
		{
			If ls !=
				x = %x%`n%ind%</%ls%>
			x = %x%`n%ind%<%s%>
			ls = %s%
		}
		x = %x%`n%ind%%ind%<%k%>%v%</%k%>
	}
	NumPut(0, var, 0, "UChar")
	Return, RegExReplace(x . "`n" . ind . "</" . ls . ">`n</" . root . ">"
		, "<([\w:]+)([^>]*)>\s*<\/\1>", "<$1$2 />")
}

/*

		Function: ini_Save
			Save the INI content to a file,
			preserving the positions of previously existing sections and their keys.

		Parameters:
			var - ini object
			src - (optional) path to a file or source as text

		Returns:
			The output source if src is not a file path,
			otherwise a boolean indicating file write success or failure.

*/
ini_Save(ByRef var, src = "") {
	NumPut(160, var, 0, "UChar")
	IfExist, %src%
	{
		src_file = 1
		FileRead, src, %src%
	}
	StringReplace, src, src, `r`n, `n, All
	StringReplace, src, src, `r, `n, All
	ls := ini_GetSections(var)
	_at = %A_LoopField%
	AutoTrim, On
	s =
	z =
	x = 1
	Loop, Parse, src, `n
	{
		l = %A_LoopField%
		If (InStr(l, "[") == 1) {
			StringReplace, ls, ls, %s%`n
			Loop, Parse, z, `n
				If A_LoopField
					d .= A_LoopField . " = " . ini_Read(var, s, A_LoopField) . "`n"
			s := SubStr(l, 2, -2), x := InStr(ls, s . "`n"), z := ini_GetKeys(var, s)
			If x
				d = %d%%l%`n
			Continue
		}
		If x
		{
			StringGetPos, p, l, =
			StringLeft, k, l, p
			k = %k%
			If k !=
				If k not contains /,`t, , ,#
					If (InStr(z, k . "`n")) {
						d .= k . " = " . ini_Read(var, s, k) . "`n"
						StringReplace, z, z, %k%`n
						Continue
					}
			d = %d%%l%`n
		}
	}
	Loop, Parse, ls, `n
	{
		s = %A_LoopField%
		If s !=
			d = %d%`n[%s%]`n
		z := ini_GetKeys(var, s)
		Loop, Parse, z, `n
			If A_LoopField !=
				d .= A_LoopField . " = " . ini_Read(var, s, A_LoopField) . "`n"
	}
	AutoTrim, %_at%
	NumPut(0, var, 0, "UChar")
	If (InStr(d, "`n") == 1)
		StringTrimLeft, d, d, 1
	StringTrimRight, d, d, 1
	If src_file = 1
	{
		FileDelete, %file%
		FileAppend, %d%, %file%
		Return, !ErrorLevel
	}
	Return, d
}

/*

		Function: ini_Load
			Load an INI file into memory so that it may be used with all the other functions in this library.

		Parameters:
			var - a reference to the loaded INI file as a variable (use for all other functions requiring this parameter)
			file - path to a file or source as text

		Returns:
			True if the file loaded successfully, false otherwise.

*/
ini_Load(ByRef var, src) {
	IfExist, %src%
		FileRead, src, %src%
	If src =
		Return
	StringReplace, src, src, `r`n, `n, All
	StringReplace, src, src, `r, `n, All
	_at = %A_AutoTrim%
	AutoTrim, On
	Loop, Parse, src, `n
	{
		l = %A_LoopField%
		If (InStr(l, ";") == 1)
			Continue
		StringGetPos, p, l, `;
		If ErrorLevel = 0
			StringLeft, l, l, p
		If (InStr(l, "[") == 1) {
			s := SubStr(l, 2, -1)
			Continue
		}
		StringGetPos, p, l, =
		If pe = 0
			Continue

		StringLeft, k, l, p
		k = %k%
		If k =
			Continue

;~ 		MsgBox % A_LoopField
;~ 		If k contains /,`t, , ,#
;~ 			Continue

		StringTrimLeft, v, l, p + 1
		v = %v%
		StringLeft, a0, v, 1
		If a0 in ",'
		{
			StringRight, a1, v, 1
			If a0 = %a1%
			{
				StringTrimLeft, v, v, 1
				StringTrimRight, v, v, 1
			}
		}
		e = `n%s%/%k%=
		StringGetPos, p, d, %e%
		If ErrorLevel = 1
			d = %d%%e%%v%`n
		Else {
			StringGetPos, p1, d, =, , p
			StringGetPos, p2, d, `n, , p + 1
			d := SubStr(d, 1, p1 + 1) . v . SubStr(d, p2 + 1)
		}
	}
	AutoTrim, %_at%
	NumPut(0, var := " " . d, 0, "UChar")
	Return, true
}



_ini_escape(val) {
	StringReplace, val, val, \, \\, All
	StringReplace, val, val, `r, \r, All
	StringReplace, val, val, `n, \n, All
	Return, val
}

_ini_unescape(val) {
	StringReplace, val, val, \\, \, All
	StringReplace, val, val, \r, `r, All
	StringReplace, val, val, \n, `n, All
	Return, val
}
