Cando_图像文件放进剪贴板:
pToken := Gdip_Startup()
pbitmap := Gdip_CreateBitmapFromFile(CandySel)
Gdip_SetBitmapToClipboard(pBitmap)
Gdip_DisposeImage(pBitmap)
Gdip_Shutdown(pToken)
Return

Cando_图像尺寸缩小:
Output := CandySel_ParentPath . "\" . CandySel_FileNamenoExt . "_0.5." . CandySel_Ext
ConvertImage(CandySel, Output, "50", "50", "Percent")
IfNotExist %Output%
	TrayTip, 图像转换失败, %Output%, 3000
Return

; JPG品质小于50时不能再次压缩尺寸
Cando_图像转为JPG:
Output := CandySel_ParentPath . "\" . CandySel_FileNamenoExt . "-0.5.jpg"
ConvertImage_Quality(CandySel, Output, 50)
IfNotExist %Output%
	TrayTip, 图像转换失败, %Output%, 3000
Return

Cando_图像去色:
Output := CandySel_ParentPath . "\" . CandySel_FileNamenoExt . "_GreyScale." . CandySel_Ext
ConvertImage_GreyScale(CandySel, output)
IfNotExist %Output%
	TrayTip, 图像转换失败, %Output%, 3000
Return

ConvertImage_Quality(sInput, sOutput, Quality)
{
	pToken := Gdip_Startup()
	pBitmap := Gdip_CreateBitmapFromFile(sInput)
	Gdip_SaveBitmapToFile(pBitmap, sOutput, Quality)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
	return
}

ConvertImage(sInput, sOutput, sWidth="", sHeight="", Method="Percent")
{
	pToken := Gdip_Startup()
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

	Gdip_SaveBitmapToFile(pBitmap1, sOutput, 100)
	Gdip_DeleteGraphics(G1)
	Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap1)
	Gdip_Shutdown(pToken)
	return 0
}

; 来源网址: https://autohotkey.com/board/topic/61891-convert-image-to-greyscale/page-2
ConvertImage_GreyScale(sInput, sOutput)
{
	SetBatchLines, -1 
	pToken := Gdip_Startup() 
	pBitmap := Gdip_CreateBitmapFromFile(sInput) 
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap) 
	pBitmap1 := Gdip_CreateBitmap(Width,height), G1 := Gdip_GraphicsFromImage(pBitmap1) 
	Matrix = 0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1 
	Gdip_DrawImage(G1, pBitmap, 0, 0, Width, Height, 0, 0, Width, Height, Matrix) 
	sleep 200  
	Gdip_SaveBitmapToFile(pBitmap1, sOutput) 
	Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap1)
	Gdip_DeleteGraphics(G1) 
	Gdip_Shutdown(pToken)
	Return 
}