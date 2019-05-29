/*!
	函数: File_GetEncoding
		类似 chardet Py库, 检测文件的代码页.

	参数:
		aFile - 要分析的外部文件路径.

	备注:
			> 注意:
			> ANSI 文档为全英文时, 默认返回 UTF-8.

	返回值:
		字符串
		0      - 错误, 文件不存在
		CP936  - ANSI (CP936), 必须带有中文字符串, 才能和 UTF-8 无签名 区分开.
		UTF-16 - text Utf-16 LE File
		CP1201 - text Utf-16 BE File
		UTF-32 - text Utf-32 BE/LE File
		UTF-8  - 检验的文件太小, 不足以检查. 默认返回 UTF-8.
		UTF-8  - text Utf-8 File (UTF-8 + BOM)
		UTF-8  - UTF-8 无签名, 必须带有中文字符串, 才能和 CP936 区分开.
*/

; isBinFile
; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=144&start=20

/*
; 示例
Loop, Files, *.txt
msgbox % A_LoopFileName " - " File_GetEncoding(A_LoopFileLongPath)
*/

File_GetEncoding(aFile, aNumBytes = 100, aMinimum = 4)
{
	if !FileExist(aFile)
		return 0
	_rawBytes := ""
	_hFile := FileOpen(aFile, "r")
	;force position to 0 (zero)
	_hFile.Position := 0

	;~ aNumBytes = 0 或为负数,则读取整个文件
	_nBytes := (aNumBytes > 0) ? (_hFile.RawRead(_rawBytes, aNumBytes)) : (_hFile.RawRead(_rawBytes, _hFile.length))

	_hFile.Close()

	; 为了 unicode 检测, 推荐 aMinimum 为 4  (4个字节以下的文件无法判断类型)
	if (_nBytes < aMinimum)
	{
		; 如果文本太短，返回编码"UTF-8"
		return "UTF-8"
	}

	;Initialize vars
	_t := 0, _i := 0, _bytesArr := []

	loop % _nBytes ;create c-style _bytesArr array
		_bytesArr[(A_Index - 1)] := Numget(&_rawBytes, (A_Index - 1), "UChar")

	;determine BOM if possible/existant
	if ((_bytesArr[0]=0xFE) && (_bytesArr[1]=0xFF))
	{
		;text Utf-16 BE File
		return "CP1201"
	}
	if ((_bytesArr[0]=0xFF) && (_bytesArr[1]=0xFE))
	{
		;text Utf-16 LE File
		return "UTF-16"
	}
	if ((_bytesArr[0]=0xEF)	&& (_bytesArr[1]=0xBB) && (_bytesArr[2]=0xBF))
	{
		;text Utf-8 File
		return "UTF-8"
	}
	if ((_bytesArr[0]=0x00)	&& (_bytesArr[1]=0x00) && (_bytesArr[2]=0xFE) && (_bytesArr[3]=0xFF))
	|| ((_bytesArr[0]=0xFF)	&& (_bytesArr[1]=0xFE) && (_bytesArr[2]=0x00) && (_bytesArr[3]=0x00))
	{
		;text Utf-32 BE/LE File
		return "UTF-32"
	}

		while(_i < _nBytes)
		{
			;// ASCII
			if (_bytesArr[_i] == 0x09)
			|| (_bytesArr[_i] == 0x0A)
			|| (_bytesArr[_i] == 0x0D)
			|| ((0x20 <= _bytesArr[_i]) && (_bytesArr[_i] <= 0x7E))
			{
				_i += 1
				continue
			}

			;// non-overlong 2-byte
			if (0xC2 <= _bytesArr[_i])
			&& (_bytesArr[_i] <= 0xDF)
			&& (0x80 <= _bytesArr[_i + 1])
			&& (_bytesArr[_i + 1] <= 0xBF)
			{
				_i += 2
				continue
			}

			;// excluding overlongs, straight 3-byte, excluding surrogates
			if (((_bytesArr[_i] == 0xE0)
			&& ((0xA0 <= _bytesArr[_i + 1])
			&& (_bytesArr[_i + 1] <= 0xBF))
			&& ((0x80 <= _bytesArr[_i + 2])
			&& (_bytesArr[_i + 2] <= 0xBF)))
			|| ((((0xE1 <= _bytesArr[_i])
			&& (_bytesArr[_i] <= 0xEC))
			|| (_bytesArr[_i] == 0xEE)
			|| (_bytesArr[_i] == 0xEF))
			&& ((0x80 <= _bytesArr[_i + 1])
			&& (_bytesArr[_i + 1] <= 0xBF))
			&& ((0x80 <= _bytesArr[_i + 2])
			&& (_bytesArr[_i + 2] <= 0xBF)))
			|| ((_bytesArr[_i] == 0xED)
			&& ((0x80 <= _bytesArr[_i + 1])
			&& (_bytesArr[_i + 1] <= 0x9F))
			&& ((0x80 <= _bytesArr[_i + 2])
			&& (_bytesArr[_i + 2] <= 0xBF))))
			{
				_i += 3
				continue
			}
			;// planes 1-3, planes 4-15, plane 16
			if (((_bytesArr[_i] == 0xF0)
			&& ((0x90 <= _bytesArr[_i + 1])
			&& (_bytesArr[_i + 1] <= 0xBF))
			&& ((0x80 <= _bytesArr[_i + 2])
			&& (_bytesArr[_i + 2] <= 0xBF))
			&& ((0x80 <= _bytesArr[_i + 3])
			&& (_bytesArr[_i + 3] <= 0xBF)))
			|| (((0xF1 <= _bytesArr[_i])
			&& (_bytesArr[_i] <= 0xF3))
			&& ((0x80 <= _bytesArr[_i + 1])
			&& (_bytesArr[_i + 1] <= 0xBF))
			&& ((0x80 <= _bytesArr[_i + 2])
			&& (_bytesArr[_i + 2] <= 0xBF))
			&& ((0x80 <= _bytesArr[_i + 3])
			&& (_bytesArr[_i + 3] <= 0xBF)))
			|| ((_bytesArr[_i] == 0xF4)
			&& ((0x80 <= _bytesArr[_i + 1])
			&& (_bytesArr[_i + 1] <= 0x8F))
			&& ((0x80 <= _bytesArr[_i + 2])
			&& (_bytesArr[_i + 2] <= 0xBF))
			&& ((0x80 <= _bytesArr[_i + 3])
			&& (_bytesArr[_i + 3] <= 0xBF))))
			{
				_i += 4
				continue
			}
			_t := 1
			break
		}

		; while 循环没有失败，然后确认为utf-8
		if (_t = 0)
		{
			return "UTF-8"
		}

	loop, %_nBytes%
	{
		if ((_bytesArr[(A_Index - 1)] < 160) && (_bytesArr[(A_Index - 1)] > 127))
		{
			return "CP936"
		}
	}
  return "CP" DllCall("GetACP")  ; 返回系统默认 ansi 内码 简体中文  默认返回的是 CP936
}  