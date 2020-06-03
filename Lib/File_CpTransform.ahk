File_CpTransform(aInFile, aOutCp := "", aInCp := "", aOutFile := "")
{
	aInCp := !aInCp ? File_GetEncoding(aInFile) : aInCp
	if !aInCp
	{
		msgbox 未能获得文件 %aInFile% 的编码类型, 或文件不存在！
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
		if (InStr(aInCp, "CP")) or (aInCp = "UTF-8-RAW")   ;  例如  CP936、CP1252、UTF-8-RAW
		{
			FileReadLine, LineVar, % aInFile, 1
			MsgBox, 36, 选择源文件的编码, 文件第一行内容: %LineVar%`n当前使用编码为: %aInCp%`n文本正常显示点击"是"，否则点击"否"。
			IfMsgBox, No
			{
				aInCp := (aInCp = "CP936") ? "UTF-8" : "CP936"
				FileEncoding, % aInCp
				FileReadLine, LineVar, % aInFile, 1
				MsgBox, 1, 确定源文件的编码, 文件第一行内容: %LineVar%`n当前使用编码为: %aInCp%`n继续转换点击"确定"，放弃点击"取消"。
				IfMsgBox, Cancel
					return
			}
		}
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
		else
		{
			FileAppend, %textvalue%, % aOutFile, % aOutCp
			textvalue := ""
		return
		}
	}
	else if (aOutCp = "UTF-8") or (aOutCp = "CP65001")
	{
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
		else
		{
			FileAppend, %textvalue%, % aOutFile, % aOutCp
			textvalue := ""
		return
		}
	}
	else if (aOutCp = "UTF-8-RAW")
	{
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
		else
		{
			FileAppend, %textvalue%, % aOutFile, % aOutCp
			textvalue := ""
		return
		}
	}
	else if (aOutCp = "UTF-16")
	{
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
		else
		{
			FileAppend, %textvalue%, % aOutFile, % aOutCp
			textvalue := ""
		return
		}
	}
	else if (aOutCp = "CP1201")
	{
		if (aInCp = "CP1201")
		{
			_hFile := FileOpen(aOutFile, "w")
			MCode(code, "FEFF")
			_hFile.RawWrite(code, 2)
			_hFile.RawWrite(textvalue, aInLen)
			textvalue := ""
		return
		}
		else
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
	}
}