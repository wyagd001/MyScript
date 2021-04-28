MG_addfavorites:
	Loop, parse, A_GuiEvent, `n, `r
	{
		Gui, Submit, NoHide
		myfav = %A_ScriptDir%\favorites
		ifNotExist, %Dir%
		{
			msgbox,没有选择文件或文件夹。
		return
		}

		SplitPath,Dir, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		InputBox,shortName,,请输入快捷方式的名称?,,,,,,,,%OutNameNoExt%
		if ErrorLevel{
		return
		}
		else
		{
			IfExist,%myfav%\%shortName%.lnk
			{
				msgbox,4,,同名的快捷方式已经存在，是否替换?
				IfMsgBox No
				return
				else{
					FileCreateShortcut,%dir%,%myfav%\%shortName%.lnk
				return
				}
			}
			FileCreateShortcut,%dir%,%myfav%\%shortName%.lnk
		return
		}
	}
return

MG_showfavorites:
	myfavmenu := FolderMenu(A_ScriptDir "\Favorites", "lnk","收藏夹",0,2,1,1)
	Menu, % myfavmenu, show
	Menu, % myfavmenu, delete
return