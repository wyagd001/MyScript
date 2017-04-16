Cando_Í¼ÏñÎÄ¼þ·Å½ø¼ôÌù°å:
pToken:=Gdip_Startup()
pbitmap :=Gdip_CreateBitmapFromFile(CandySel)
Gdip_SetBitmapToClipboard(pBitmap)
Gdip_DisposeImage(pBitmap)
Gdip_Shutdown(pToken)
Return

Cando_Í¼Ïñ³ß´çËõÐ¡:
Output:=CandySel_ParentPath . "\" . CandySel_FileNamenoExt . "_0.5." . CandySel_Ext
ConvertImage(CandySel,Output,"50","50","Percent")
IfNotExist %Output%
	TrayTip,Í¼Ïñ×ª»»Ê§°Ü,%Output%,3000
Return

ConvertImage(sInput, sOutput, sWidth="", sHeight="", Method="Percent")
{
	pToken:=Gdip_Startup()
	pBitmap := Gdip_CreateBitmapFromFile(sInput)
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)

	If (Method = "Percent")
	{
		Width := (Width = -1) ? Height : Width, Height := (Height = -1) ? Width : Height
		dWidth := Round(Width*(sWidth/100)), dHeight := Round(Height*(sHeight/100))
	}
	else If (Method = "Pixels")
	{
		if (Width = -1)
		dWidth := Round((sHeight/Height)*Width), dHeight := Height
		else if (Height = -1)
		dHeight := Round((sWidth/Width)*Height), dWidth := Width
		else
		dWidth := sWidth, dHeight := sHeight
	}
	else
		return -1
	pBitmap1 := Gdip_CreateBitmap(dWidth, dHeight),G1 := Gdip_GraphicsFromImage(pBitmap1)
	Gdip_SetInterpolationMode(G1, 7)
	Gdip_DrawImage(G1, pBitmap, 0, 0, dWidth, dHeight, 0, 0, Width, Height)

	Gdip_SaveBitmapToFile(pBitmap1, sOutput)
	Gdip_DeleteGraphics(G1)
	Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap1)
	Gdip_Shutdown(pToken)
	return 0
}