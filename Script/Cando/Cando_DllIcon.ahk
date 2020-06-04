; 来源网址: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3216&sid=fda9945d8bfa77fd0593f8e2bee09918&start=60
; https://autohotkey.com/board/topic/5278-simple-icon-browser/
; https://gist.github.com/AHK-just-me/5518511
; Program: Icon Browser
; 首次发布: 2005.09.29
; 最近修改: 2019.06.02
; 修改内容: 添加 AHK-just-me 修改的 IconEx 脚本中的保存功能, 32位系统下测试通过
; 只有保存图标组的功能，没有添加保存单个图标的功能

Cando_DllIcon:
dllfile := CandySel

Start:
Gui,66:Destroy
Gui,66:Default 
SetBatchLines, -1
Gui, Margin, 5, 5
Gui, color, white
Gui, font, s8, Tahoma
Gui, Add, ComboBox, w600 vFile2 -Multi Limit, wmploc.dll|imageres.dll|netshell.dll|SHELL32.dll
Gui, Add, Button, x+5 h20 gSelect2 +Default vhgo, &Go
Gui, Add, Button, x+5 h20 gSelectdllFile, ...
Loop, 500
{
  if a_index = 1
    Gui, add, Pic, xm y+5 w32 h32 icon%a_index% border altsubmit gIcon vIcon%a_index%, %dllfile%
  else if a_index in 1,21,41,61,81,101,121,141,161,181,201,221,241,261,281,301
    Gui, add, Pic, xm y+2 w32 h32 icon%a_index% border altsubmit gIcon vIcon%a_index%, %dllfile%
  else
    Gui, add, Pic, x+2 w32 h32 icon%a_index% border altsubmit gIcon vIcon%a_index%, %dllfile%
  GuiControlGet, test, pos, Icon%a_index%
  if testw <> 34
  {
    GuiControl, Hide, Icon%a_index%
    break
  }
}
Gui, Show,, Icon Browser
GuiControl,text,File2, %dllfile%
GuiControl, Focus, hgo
return

SelectdllFile:
FileSelectFile, dllFile, 1, %systemroot%\system32\, Open, Icon Files (*.ico; *.dll; *.exe)
GuiControl,text,File2, %dllfile%
Goto, Start
return

Select2:
Gui, Submit, Nohide
dllFile = %File2%
Goto, Start
return

Icon:
Gui, +OwnDialogs
StringTrimLeft, icon, a_guicontrol, 4
gosub ExtractIcon
return

ExtractIcon:
RT_GROUP_ICON  := 14
RT_ICON        := 3
hModule := LoadLibraryEx(dllfile)
SplitPath, dllfile, , OutDir,, OutNameNoExt
FileN := SaveIcon(OutDir . "\" . OutNameNoExt "_ig" icon . ".ico")

IGCount := 0
CallB          := RegisterCallback("EnumResNameProc")

DllCall("Kernel32.dll\EnumResourceNames", "Ptr", hModule, "Ptr", 14, "Ptr", CallB, "Ptr", 0)
;msgbox % aIconGroup

   hFile := FileOpen(FileN, "rw", "CP0")
   sBuff := GetResource(hModule, icon, RT_GROUP_ICON, nSize, hResData)
   Icons := NumGet(sBuff + 0, 4, "UShort")
   hFile.RawWrite(sBuff + 0, 6)
   sBuff += 6
   Loop, %Icons% {
      hFile.RawWrite(sBuff + 0, 14)
      hFile.WriteUShort(0)
      sBuff += 14
   }
   DllCall("Kernel32.dll\FreeResource", "Ptr", hResData)
   EOF := hFile.Pos
   hFile.Pos := 18
   Loop %Icons% {
      nID := hFile.ReadUShort()
      hFile.Seek(-2, 1)
      hFile.WriteUInt(EOF)
      DataOffSet := hFile.Pos
      sBuff := GetResource(hModule, nID, RT_ICON, nSize, hResData)
      hFile.Seek(-0, 2)
      hFile.RawWrite(sBuff + 0, nSize)
      DllCall("Kernel32.dll\FreeResource", "Ptr", hResData)
      EOF := hFile.Pos
      hFile.Pos := DataOffset + 12
   }
   hFile.CLose()
   DllCall("Kernel32.dll\FreeLibrary", "Ptr", hModule)
Return


LoadLibraryEx(File) {
   Return DllCall("Kernel32.dll\LoadLibraryEx", "Str", File, "Ptr", 0, "UInt", 0x02, "UPtr")
}

SaveIcon(Filename, Prompt := "保存 Icon 为") {
   FileSelectFile, File, 16, %Filename%, %Prompt%, Icon (*.ico)
   Return ((File <> "" && SubStr(File, -3) <> ".ico") ? File . ".ico" : File)
}

GetResource(hModule, rName, rType, ByRef nSize, ByRef hResData) {
   Arg := (rName + 0 = "") ? &rName : rName
   hResource := DllCall("Kernel32.dll\FindResource", "Ptr", hModule, "Ptr", Arg, "Ptr", rType, "UPtr")
   nSize     := DllCall("Kernel32.dll\SizeofResource", "Ptr", hModule, "Ptr", hResource, "UInt")
   hResData  := DllCall("Kernel32.dll\LoadResource", "Ptr", hModule, "Ptr" , hResource, "UPtr")
   Return DllCall("Kernel32.dll\LockResource", "Ptr", hResData, "UPtr")
}

EnumResNameProc(hModule, lpszType, lpszName, lParam) {
   Global Icon, IGCount
   If (lpszName > 0xFFFF)
      lpszName := StrGet(lpszName)
	 IGCount++
	if (IGCount = Icon)
{
     Icon := lpszName
Return false
}
   Return True
}