;桌面快捷方式
Desktoplnk:
	mydesktopmenu := FolderMenu(A_desktop, "lnk",,1,0,1,0)
	menu, % mydesktopmenu, show
	Menu, % mydesktopmenu, delete
return