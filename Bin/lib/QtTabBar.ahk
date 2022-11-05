QtTabBar()
{
	try QtTabBarObj := ComObjCreate("QTTabBarLib.Scripting")
	if IsObject(QtTabBarObj)
	return 1
	else
	return 0
}

QtTabBar_GetAllTabs()
{
	OPenedFolder_Str := ""
	QtTabBarObj := ComObjCreate("QTTabBarLib.Scripting")
	if QtTabBarObj
	{
		for k in QtTabBarObj.Windows
			for w in k.Tabs
			{
				Tmp_Fp := w.path
				if (Tmp_Fp)
					if FileExist(Tmp_Fp)
					{
						OPenedFolder_Str .= Tmp_Fp "`n"
					}
			}
	}
	OPenedFolder_Str := Trim(OPenedFolder_Str, " `t`n")
	OPenedFolder := StrSplit(OPenedFolder_Str, "`n")
	return OPenedFolder
}