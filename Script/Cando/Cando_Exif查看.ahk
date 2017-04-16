Cando_Exif查看:
	Gui 66: Destroy
	;RunWait,regsvr32.exe `/s %SImageUtil%
	Image := ComObjCreate("SImageUtil.Image")
	Image.OpenImageFile(Candysel)


	Main := Object()
	Main.Desc := "描述"
	Main.Make := "相机制造商"
	Main.Model := "相机型号"
	Main.Ori := "方向"
	Main.XRes := "水平分辨率"
	Main.YRes := "垂直分辨率"
	Main.ResUnit :=     "分辨率单位"
	Main.Software := "固件版本"
	Main.ModTime := "修改时间"
	Main.WPoint := "白点色度"
	Main.PrimChr := "主要色度"
	Main.YCbCrCoef := "颜色空间转换矩阵系数"
	Main.YCbCrPos := "色相定位"
	Main.RefBW := "黑白参照值"
	Main.Copy := "版权"
	Main.ExifOffset := "子IFD偏移量"
	; XP tags
	Main.Title := "标题"
	Main.Comments := "备注"
	Main.Author := "作者"
	Main.Keywords := "标记"
	Main.Subject := "主题"

	Sub := Object()
	Sub.s :=  "曝光时间"
	Sub.f := "光圈级数(F值)"
	Sub.prog :=   "曝光程序"
	Sub.iso := "感光度(ISO 速度)"
	Sub.ExifVer := "Exif 版本"
	Sub.OrigTime := "拍摄时间"
	Sub.DigTime := "数字化时间"
	Sub.CompConfig := "图像构造"
	Sub.bpp := "平均压缩比"
	Sub.sa := "快门速度"
	Sub.aa := "镜头光圈"
	Sub.ba := "亮度"
	Sub.eba := "曝光补偿"
	Sub.maa := "最大光圈"
	Sub.dist := "物距(目标距离)"
	Sub.meter := "测光模式"
	Sub.ls := "光源"
	Sub.flash := "闪光灯"
	Sub.focal :=   "焦距"
	Sub.Maker := "制造商设置信息"
	Sub.User := "用户标记"
	Sub.sTime := "日期时间"
	Sub.sOrigTime := "原始日期时间"
	Sub.sDigTime := "原始日期时间数字化"
	Sub.flashpix := "Flash Pix 版本"
	Sub.ColorSpace :=  "色彩模式"
	Sub.Width := "图片宽度"
	Sub.Height := "图片高度"
	Sub.SndFile := "声音文件"
	Sub.ExitIntOff := "Exif 互用偏移量"
	Sub.FPXRes := "焦平面水平轴分辨率"
	Sub.FPYRes := "焦平面垂直轴分辨率"
	Sub.FPResUnit := "焦平面单位"
	Sub.ExpIndex := "曝光指数"
	Sub.SenseMethod := "场景方法"
	Sub.FileSource :=  "源文件"
	Sub.SceneType := "场景类型"
	Sub.CFAPat := "CFA 模板"


	Gui 66: Margin,0 0
	Gui 66: Add, ListView, x0 y0  w600 r40  vMyLV, 属性|值
	GuiControl 66: -Redraw, MyLV
    Gui,66:Default   ;在多gui，多lv的情况下，为了让lv显示到这个gui上，这个必须的
	Gui, ListView, MyLV

	For k,v in Main
	 if (value := Image.GetExif("Main." . k))
	  LV_Add("",v,value)

	For k,v in Sub
	 if (value := Image.GetExif("Sub." . k))
	  LV_Add("",v,value)

	GuiControl 66: +Redraw, MyLV
	LV_ModifyCol(1,180)
	LV_ModifyCol(2,400)
	Gui 66: Show, , Exif 信息
	Image.Close()
	;RunWait,regsvr32.exe `/s `/u %SImageUtil%
	Return