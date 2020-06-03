Cando_uc×ªMP3:   ; Íø**ÒôÀÖ»º´æ
File_Decodinguc(CandySel)
Return

File_Decodinguc(aFile)
{
	_hFile := FileOpen(aFile, "r")
	oFile := SubStr(aFile, 1, -4)

	_nBytes := _hFile.RawRead(_rawBytes, _hFile.length)
	_hFile.Close()

	loop % _nBytes
	{
		byte := Numget(_rawBytes, (A_Index - 1), "UChar")
		NumPut(byte ^ 0xa3, _rawBytes , A_Index - 1, "UChar")
	}

	_hFile := FileOpen(oFile, "w")
	_hFile.RawWrite(_rawBytes, _nBytes)
	_hFile.Close()
	_rawBytes := ""
}