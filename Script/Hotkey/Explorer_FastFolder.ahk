;#ifWinActive,ahk_class CabinetWClass
;#q::
八个收藏的文件夹菜单:
      Menu, FastFolders, add,1,FastFolderMenuHandler
	    Menu, FastFolders, DeleteAll
		loop 8
		{
			i:=A_INDEX
			if(Fast_Folder%i%)
			{
				x:=Fast_FolderTitle%i%
				if(x)
				{
					x := "&" i ": " x
					Menu, FastFolders, add, %x%, FastFolderMenuHandler
				}
			}
		}
		F_hwnd:=WinExist("A")
		Menu, FastFolders, Show
return
;#ifWinActive

FastFolderMenuHandler:
FastFolderMenuClicked(A_ThisMenuItemPos)
return

FastFolderMenuClicked(index)
{
	global
	local y:=Fast_Folder%index%
	local ctrldown := GetKeyState("CTRL")
	local shiftdown := GetKeyState("shift")
	x:=GetSelectedFiles()
	StringReplace, x, x, `n , |, A
	if(x)
	{
		if(ctrldown)
			ShellFileOperation(0x2, x, y,0,F_hwnd)
		if(shiftdown)
			ShellFileOperation(0x1, x, y,0,F_hwnd)
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
^Numpad1::UpdateStoredFolder(Fast_Folder1,Fast_FolderTitle1)
^Numpad2::UpdateStoredFolder(Fast_Folder2,Fast_FolderTitle2)
^Numpad3::UpdateStoredFolder(Fast_Folder3,Fast_FolderTitle3)
^Numpad4::UpdateStoredFolder(Fast_Folder4,Fast_FolderTitle4)
^Numpad5::UpdateStoredFolder(Fast_Folder5,Fast_FolderTitle5)
^Numpad6::UpdateStoredFolder(Fast_Folder6,Fast_FolderTitle6)
^Numpad7::UpdateStoredFolder(Fast_Folder7,Fast_FolderTitle7)
^Numpad8::UpdateStoredFolder(Fast_Folder8,Fast_FolderTitle8)
^!Numpad1::ClearStoredFolder(Fast_Folder1,Fast_FolderTitle1)
^!Numpad2::ClearStoredFolder(Fast_Folder2,Fast_FolderTitle2)
^!Numpad3::ClearStoredFolder(Fast_Folder3,Fast_FolderTitle3)
^!Numpad4::ClearStoredFolder(Fast_Folder4,Fast_FolderTitle4)
^!Numpad5::ClearStoredFolder(Fast_Folder5,Fast_FolderTitle5)
^!Numpad6::ClearStoredFolder(Fast_Folder6,Fast_FolderTitle6)
^!Numpad7::ClearStoredFolder(Fast_Folder7,Fast_FolderTitle7)
^!Numpad8::ClearStoredFolder(Fast_Folder8,Fast_FolderTitle8)
#ifWinActive

UpdateStoredFolder(ByRef FF, ByRef FFTitle)
{
	title:=FF:=GetCurrentFolder()
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
	FF:=FFTitle:=""
	IniWrite()
}

IniWrite(){
	Loop 8
	{
	    i:=A_Index
	    x:=Fast_Folder%i%
	    y:=Fast_FolderTitle%i%
	    IniWrite, %x%, %run_iniFile%, FastFolders, Fast_Folder%i%
	    IniWrite, %y%, %run_iniFile%, FastFolders, Fast_FolderTitle%i%
}
IniRead, content, %run_iniFile%,FastFolders
Gosub, GetAllKeys
}