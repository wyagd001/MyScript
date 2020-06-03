;menu, % FolderMenu(A_desktop, "lnk","收藏夹",1,2,1,1), show
;menu, % FolderMenu("D:\Program Files\运行\win 7\Favorites", "lnk","收藏夹",1,2,1,0), show

; FolderMenu 函数参数
; FolderPath             文件夹路径，类型：字符串，必须的参数例如 "C:\"
; SpecifyExt             指定要显示的文件的扩展名，类型：字符串，可选 例如 "lnk"，"exe"，默认值"*"
; MenuName               是否指定菜单名称，类型：字符串，默认值为空
; ShowIcon               菜单是否带图标，类型：布尔值 0 或 1，默认值 1
; ShowOpenFolderMenu     是否显示子文件夹的“打开”菜单，类型：布尔值 0 或 1，默认值 1
;                        特殊值 2, 效果等同于 0，不同的在于在底部显示主目录的打开菜单
; Showhide               是否显示隐藏文件，类型：布尔值 0 或 1，默认值 0
; FolderFirst            子文件夹在前，类型：布尔值 0 或 1，默认值 1
;                        值为 1 时，文件菜单按文件名排序(中文排序不准)，值为 0 时，不排序(按loop文件的顺序)
; FolderMenu 函数返回值  菜单名称 MenuName
;                        子文件夹数量超过 50，文件数量超过 500，返回空值


FolderMenu(FolderPath, SpecifyExt:="*", MenuName:="",ShowIcon:=1, ShowOpenFolderMenu:=1, Showhide:=0, FolderFirst:=1)
{
	MenuName := MenuName ? MenuName : FolderPath
	
	if (ShowOpenFolderMenu = 1)
	{
		BoundRun := Func("Run").Bind(FolderPath)
		Menu, %MenuName%, add, 打开 %FolderPath%, %BoundRun%
		if ShowIcon
			FolderMenu_AddIcon(MenuName, "打开 " . FolderPath)
		Menu, %MenuName%, add
	}

	if !FolderFirst
	{
		ExistSubMenuName:={}
		Loop, %FolderPath%\*.%SpecifyExt%, 0, 1  ; 文件
		{
			if (A_Index > 500)
			{
				msgbox, ,目录菜单创建失败, 选定文件夹内文件过多，无法创建菜单。`n限制数量`n文件夹：50，文件：500。
			return
			}
			if !Showhide
			{
				if A_LoopFileAttrib contains H,R,S  ; 跳过具有 H(隐藏), R(只读) 或 S(系统) 属性的任何文件. 注意: 在 "H,R,S" 中不含空格.
				continue  ; 跳过这个文件并前进到下一个.
			}
			StringGetPos, pos, A_LoopFileLongPath, \, R
			StringLeft, ParentFolderDirectory, A_LoopFileLongPath, %pos%
			ParentFolderDirectory := (ParentFolderDirectory=FolderPath) ? MenuName : ParentFolderDirectory
			if (ShowOpenFolderMenu=1) & (ParentFolderDirectory != MenuName) & !ExistSubMenuName[ParentFolderDirectory]
			{
				ExistSubMenuName[ParentFolderDirectory]:=1
				BoundRun := Func("Run").Bind(ParentFolderDirectory)
				StringGetPos, pos, ParentFolderDirectory, \, R
				StringTrimLeft, SubMenuName, ParentFolderDirectory, % pos+1
				Menu, %ParentFolderDirectory%, add, 打开 %SubMenuName%, %BoundRun%
				if ShowIcon
					FolderMenu_AddIcon(ParentFolderDirectory, "打开 " . SubMenuName)
				Menu, %ParentFolderDirectory%, add
			}
			;msgbox %  pos "`n" A_LoopFileLongPath "`n" ParentFolderDirectory "`n" A_LoopFileName
			FileMenuName := (A_LoopFileExt!="lnk")?A_LoopFileName:StrReplace(A_LoopFileName, ".lnk")
			BoundRun := Func("Run").Bind(A_LoopFileLongPath)
			Menu, %ParentFolderDirectory%, add, %FileMenuName%, %BoundRun%
			if ShowIcon
				FolderMenu_AddIcon(ParentFolderDirectory, FileMenuName)
		}
	}

	Loop, %FolderPath%\*.*, 2, 1   ; 文件夹
	{
		if (A_Index > 50)
		{
			msgbox, ,目录菜单创建失败, 选定文件夹内文件过多，无法创建菜单。`n限制数量`n文件夹：50，文件：500。
		return
		}
		if !Showhide
		{
			if A_LoopFileAttrib contains H,R,S  ; 跳过具有 H(隐藏), R(只读) 或 S(系统) 属性的任何文件. 注意: 在 "H,R,S" 中不含空格.
			continue  ; 跳过这个文件并前进到下一个.
		}
		StringGetPos, pos, A_LoopFileLongPath, \, R
			StringLeft, ParentFolderDirectory, A_LoopFileLongPath, %pos%
		;msgbox %  pos "`n" A_LoopFileLongPath "`n" ParentFolderDirectory "`n" A_LoopFileName
		ParentFolderDirectory := (ParentFolderDirectory=FolderPath) ? MenuName : ParentFolderDirectory
		if FolderFirst || !ExistSubMenuName[A_LoopFileLongPath]
		{
			BoundRun := Func("Run").Bind(A_LoopFileLongPath)
			Menu, %A_LoopFileLongPath%, add, 打开 %A_LoopFileName%, %BoundRun%
			if (ShowOpenFolderMenu=1)
			{
				if ShowIcon
					FolderMenu_AddIcon(A_LoopFileLongPath, "打开 " . A_LoopFileName)
				filecount := 0
				Loop, %A_LoopFileLongPath%\*.%SpecifyExt%, 1, 0
				{
					filecount++
					break
				}
				Loop, %A_LoopFileLongPath%\*.*, 2, 0
				{
					filecount++
					break
				}
				if filecount
					Menu, %A_LoopFileLongPath%, add
			}
		}
		Menu, %ParentFolderDirectory%, add, %A_LoopFileName%, :%A_LoopFileLongPath%
		if ShowIcon
			FolderMenu_AddIcon(ParentFolderDirectory, A_LoopFileName)
		if (ShowOpenFolderMenu!=1)
		{
			Menu, %A_LoopFileLongPath%, Delete, 打开 %A_LoopFileName%
			filecount := 0
			Loop, %A_LoopFileLongPath%\*.%SpecifyExt%, 0, 1
			{
				filecount++
				break
			}
			if !filecount
				Menu, %A_LoopFileLongPath%, Delete
		}
	}
	
	if FolderFirst
	{
		Loop, %FolderPath%\*.%SpecifyExt%, 0, 1  ; 文件
		{
			if (A_Index > 500)
			{
				msgbox, ,目录菜单创建失败, 选定文件夹内文件过多，无法创建菜单。`n限制数量`n文件夹：50，文件：500。
			return
			}
			FileList .= A_LoopFileLongPath "`n"
		}
		Sort, FileList, \
		Loop, parse, FileList, `n
		{
			if A_LoopField =
			continue
			if !Showhide
			{
				FileGetAttrib, FileAttrib, A_LoopField
				if FileAttrib contains H,R,S  ; 跳过具有 H(隐藏), R(只读) 或 S(系统) 属性的任何文件. 注意: 在 "H,R,S" 中不含空格.
				continue  ; 跳过这个文件并前进到下一个.
			}
			SplitPath, A_LoopField, FileName, ParentFolderDirectory, fileExt, FileNameNoExt
			ParentFolderDirectory := (ParentFolderDirectory=FolderPath) ? MenuName : ParentFolderDirectory
			;msgbox %  pos "`n" A_LoopFileLongPath "`n" ParentFolderDirectory "`n" A_LoopFileName
			BoundRun := Func("Run").Bind(A_LoopField)
			FileMenuName := (FileExt!="lnk")?FileName:FileNameNoExt
			Menu, %ParentFolderDirectory%, add, %FileMenuName%, %BoundRun%
			if ShowIcon
				FolderMenu_AddIcon(ParentFolderDirectory, FileMenuName)
		}
	}

	if (ShowOpenFolderMenu = 2)
	{
		Menu, %MenuName%, add
		BoundRun := Func("Run").Bind(FolderPath)
		Menu, %MenuName%, add, 打开 %FolderPath%, %BoundRun%
		if ShowIcon
		 FolderMenu_AddIcon(MenuName, "打开 " . FolderPath)
	}
	return MenuName
}

Run(a) {
	run, %a%
}

FolderMenu_AddIcon(menuitem,submenu)
{
	; Allocate memory for a SHFILEINFOW struct.
	VarSetCapacity(fileinfo, fisize := A_PtrSize + 688)
	
	; Get the file's icon.
	if DllCall("shell32\SHGetFileInfoW", "wstr", A_LoopFileLongPath?A_LoopFileLongPath:A_LoopField
		, "uint", 0, "ptr", &fileinfo, "uint", fisize, "uint", 0x100 | 0x000000001)
	{
		hicon := NumGet(fileinfo, 0, "ptr")
		; Set the menu item's icon.
		Menu %menuitem%, Icon, %submenu%, HICON:%hicon%
		; Because we used ":" and not ":*", the icon will be automatically
		; freed when the program exits or if the menu or item is deleted.
	}
}