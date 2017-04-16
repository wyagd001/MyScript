;方法来自官网，需要gdip支持
Cando_提取图标:
	ptr := A_PtrSize =8 ? "ptr" : "uint"   ;for AHK Basic
	FileName := CandySel
	hIcon := DllCall("Shell32\ExtractAssociatedIcon" (A_IsUnicode ? "W" : "A")
		, ptr, DllCall("GetModuleHandle", ptr, 0, ptr)
		, str, FileName
		, "ushort*", lpiIcon
		, ptr)   ;only supports 32x32
	SavehIconAsBMP(hIcon, CandySel_ParentPath "\" CandySel_FileNameNoExt ".png")
	return

SavehIconAsBMP(hIcon, sFile)
{
	if pToken := Gdip_Startup()
	{
		pBitmap := Gdip_CreateBitmapFromHICON(hIcon)
		Gdip_SaveBitmapToFile(pBitmap, sFile)
		Gdip_DisposeImage(pBitmap)
		Gdip_Shutdown(pToken)
		return true
	}
	return false
}