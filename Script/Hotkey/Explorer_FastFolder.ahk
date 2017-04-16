;#ifWinActive,ahk_class CabinetWClass
;#q::
八个收藏的文件夹菜单:
      Menu, FastFolders, add,1,FastFolderMenuHandler
	    Menu, FastFolders, DeleteAll
		win:=WinExist("A")
		loop 8
		{
			i:=A_INDEX
			if(FF%i%)
			{
				x:=FFTitle%i%
				if(x)
				{
					x := "&" i ": " x
					Menu, FastFolders, add, %x%, FastFolderMenuHandler
				}
			}
		}
		hwnd:=WinExist("A")
		Menu, FastFolders, Show
return
;#ifWinActive

FastFolderMenuHandler:
FastFolderMenuClicked(A_ThisMenuItemPos)
return

FastFolderMenuClicked(index)
{
	global
	local y:=FF%index%
	local ctrldown := GetKeyState("CTRL")
	local shiftdown := GetKeyState("shift")
	x:=GetSelectedFiles()
	StringReplace, x, x, `n , |, A
	if(x)
	{
		if(ctrldown)
			ShellFileOperation(0x2, x, y,0,hwnd)
		if(shiftdown)
			ShellFileOperation(0x1, x, y,0,hwnd)
		Else
		   {
		    Sleep 100
		    SetDirectory(y)
		   }
	}
	else
	{
		Sleep 100
		SetDirectory(y)
	}
	Menu, FastFolders, DeleteAll
}


#ifWinActive,ahk_group ccc
^Numpad1::UpdateStoredFolder(FF1,FFTitle1)
^Numpad2::UpdateStoredFolder(FF2,FFTitle2)
^Numpad3::UpdateStoredFolder(FF3,FFTitle3)
^Numpad4::UpdateStoredFolder(FF4,FFTitle4)
^Numpad5::UpdateStoredFolder(FF5,FFTitle5)
^Numpad6::UpdateStoredFolder(FF6,FFTitle6)
^Numpad7::UpdateStoredFolder(FF7,FFTitle7)
^Numpad8::UpdateStoredFolder(FF8,FFTitle8)
^!Numpad1::ClearStoredFolder(FF1,FFTitle1)
^!Numpad2::ClearStoredFolder(FF2,FFTitle2)
^!Numpad3::ClearStoredFolder(FF3,FFTitle3)
^!Numpad4::ClearStoredFolder(FF4,FFTitle4)
^!Numpad5::ClearStoredFolder(FF5,FFTitle5)
^!Numpad6::ClearStoredFolder(FF6,FFTitle6)
^!Numpad7::ClearStoredFolder(FF7,FFTitle7)
^!Numpad8::ClearStoredFolder(FF8,FFTitle8)
#ifWinActive

UpdateStoredFolder(ByRef FF, ByRef FFTitle)
{
	FF:=GetCurrentFolder()
	title:=FF
	if(strStartsWith(title,"::") && WinActive("ahk_group ExplorerGroup"))
		WinGetTitle,title,A

	SplitPath, title , FFTitle
	if(!FFTitle)
		FFtitle:=title
    IniWrite()
}

ClearStoredFolder(ByRef FF, ByRef FFTitle)
{
	global
	Critical
	FF:=""
	FFTitle:=""
    IniWrite()
}

IniWrite(){
	Loop 8
	{
	    x:=A_Index
	    y:=FF%x%
	    z:=FFTitle%x%
	    IniWrite, %y%, %run_iniFile%, FastFolders, Folder%x%
	    IniWrite, %z%, %run_iniFile%, FastFolders, FolderTitle%x%
}
Reload
}