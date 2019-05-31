File_CpTransform(aInFile, aOutCp := "", aOutFile := "")
{
	aInCp := File_GetEncoding(aInFile)
	if !aInCp
	{
		msgbox 不支持文件 %aInFile% 的编码类型 %aInCp%, 或文件不存在！
	return
	}

	if (aInCp = "CP1201")
	{
		_hFile := FileOpen(aInFile, "r")
		_hFile.Position := 2
		_hFile.RawRead(textvalue, _hFile.length)
		aInLen := _hFile.length - 2
		_hFile.Close()
	}
	else
	{
		FileEncoding, % aInCp
		FileRead, textvalue, %aInFile%
		FileEncoding
	}

	aSysCp := "CP" DllCall("GetACP")
	if !aOutCp or (aOutCp = "ansi")
		aOutCp := aSysCp

	if !aOutFile
		aOutFile := aInFile
	if !InStr(aOutFile, "\")
	{
		SplitPath, % aInFile, , aOutDir
		aOutFile := aOutDir "\" aOutFile
	}

	if (FileExist(aOutFile))
		FileRecycle, % aOutFile

	if (aOutCp = aSysCp)
	{
		if (aInCp = aSysCp) or (aInCp = "UTF-8") or (aInCp = "UTF-16")
		{
			FileAppend, %textvalue%, % aOutFile, % aOutCp
			textvalue := ""
		return
		}
		if (aInCp = "CP1201")
		{
			LCMAP_BYTEREV := 0x800
			cch:=DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,textvalue, UInt,-1, Str,0, UInt,0)
			VarSetCapacity(LE, cch * 2)
			DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,textvalue, UInt,cch, Str,LE, UInt,cch)
			FileAppend, %LE%, % aOutFile, % aOutCp
			textvalue := LE := ""
		return
		}
	}
	else if (aOutCp = "UTF-8") or (aOutCp = "CP65001")
	{
		if (aInCp = aSysCp) or (aInCp = "UTF-8") or (aInCp = "UTF-16")
		{
			FileAppend, %textvalue%, % aOutFile, % aOutCp
			textvalue := ""
		return
		}
		if (aInCp = "CP1201")
		{
			LCMAP_BYTEREV := 0x800
			cch:=DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,textvalue, UInt,-1, Str,0, UInt,0)
			VarSetCapacity(LE, cch * 2)
			DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,textvalue, UInt,cch, Str,LE, UInt,cch)
			FileAppend, %LE%, % aOutFile, % aOutCp
			textvalue := LE := ""
		return
		}
	}
	else if (aOutCp = "UTF-8-RAW")
	{
		if (aInCp = aSysCp) or (aInCp = "UTF-8") or (aInCp = "UTF-16")
		{
			FileAppend, %textvalue%, % aOutFile, % aOutCp
			textvalue := ""
		return
		}
		if (aInCp = "CP1201")
		{
			LCMAP_BYTEREV := 0x800
			cch:=DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,textvalue, UInt,-1, Str,0, UInt,0)
			VarSetCapacity(LE, cch * 2)
			DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,textvalue, UInt,cch, Str,LE, UInt,cch)
			FileAppend, %LE%, % aOutFile, % aOutCp
			textvalue := LE := ""
		return
		}
	}
	else if (aOutCp = "UTF-16")
	{
		if (aInCp = aSysCp) or (aInCp = "UTF-8") or (aInCp = "UTF-16")
		{
			FileAppend, %textvalue%, % aOutFile, % aOutCp
			textvalue := ""
		return
		}
		if (aInCp = "CP1201")
		{
			LCMAP_BYTEREV := 0x800
			cch:=DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,textvalue, UInt,-1, Str,0, UInt,0)
			VarSetCapacity(LE, cch * 2)
			DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,textvalue, UInt,cch, Str,LE, UInt,cch)
			FileAppend, %LE%, % aOutFile, % aOutCp
			textvalue := LE := ""
		return
		}
	}
	else if (aOutCp = "CP1201")
	{
		if (aInCp = aSysCp) or (aInCp = "UTF-8") or (aInCp = "UTF-16")
		{
			LCMAP_BYTEREV := 0x800
			cch:=DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,textvalue, UInt,-1, Str,0, UInt,0)
			VarSetCapacity(BE, cch * 2)
			DllCall( "LCMapStringW", UInt,0, UInt,LCMAP_BYTEREV, Str,textvalue, UInt,cch, Str,BE, UInt,cch)
			_hFile := FileOpen(aOutFile, "w")
			MCode(code, "FEFF")
			_hFile.RawWrite(code, 2)
			_hFile.RawWrite(BE, cch * 2-2)
			textvalue := BE := ""
		return
		}
		if (aInCp = "CP1201")
		{
			_hFile := FileOpen(aOutFile, "w")
			MCode(code, "FEFF")
			_hFile.RawWrite(code, 2)
			_hFile.RawWrite(textvalue, aInLen)
			textvalue := ""
		return
		}
	}
}