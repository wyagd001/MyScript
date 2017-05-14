SaveScreen(Size,Type,filepath,filename,FileType)
{
	global ffw ,fh
	pToken:=Gdip_Startup()
	WinGetPos, X, Y, W, H, A
	If (Type = "Window") 
	{
		pBitmap := Gdip_BitmapFromScreen(X "|" Y "|" W "|" H)
		FileName :=FileName?FileName:"Window_" A_Now
	}
	Else 
	{
		pBitmap := Gdip_BitmapFromScreen()
		FileName := FileName?FileName:"Screen_" A_Now
	}
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
	If Size
	{
		PBitmapResized := Gdip_CreateBitmap(Round(Width*Size), Round(Height*Size)),G := Gdip_GraphicsFromImage(pBitmapResized)
		Gdip_SetInterpolationMode(G, 7)
		Gdip_DrawImage(G, pBitmap, 0, 0, Round(Width*Size), Round(Height*Size), 0, 0, Width, Height)
	}
	Else
	{
		PBitmapResized := Gdip_CreateBitmap(ffw, fh),G := Gdip_GraphicsFromImage(pBitmapResized)
		Gdip_SetInterpolationMode(G, 7)
		Gdip_DrawImage(G, pBitmap, 0, 0, ffw, fh, 0, 0, Width, Height)
	}

	Gdip_SaveBitmapToFile(PBitmapResized, filepath "\" FileName "." FileType)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapResized)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
Return (FileName)
}

;¿˚”√PrintWindowΩÿÕº
SaveScreen2(hwnd,filepath,filename,FileType)
{
	global ffw ,fh
	pToken:=Gdip_Startup()
	pBitmap := Gdip_BitmapFromHWND(hwnd)
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)

	PBitmapResized := Gdip_CreateBitmap(ffw, fh),G := Gdip_GraphicsFromImage(pBitmapResized)
	Gdip_SetInterpolationMode(G, 7)
	Gdip_DrawImage(G, pBitmap, 0, 0, ffw, fh, 0, 0, Width, Height)

	Gdip_SaveBitmapToFile(PBitmapResized, filepath "\" FileName "." FileType)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmapResized)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
Return (FileName)
}