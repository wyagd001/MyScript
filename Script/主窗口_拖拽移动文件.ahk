GuiDropFiles_Begin:
	CoverControl(hComBoBox)
Return

GuiDropFiles_End:
	CoverControl()

	If GuiDropFiles_FileFullPath
	{
		MouseGetPos,,,,hwnd,2
		If hwnd in %hComBoBox%,%hComBoBoxEdit%
			Gosub ShowFileFullPath
		Else
			Gosub movedropfile
	}
Return

CoverControl(hwnd_CsvList = ""){
	static handler := {__New: "test"}
	static _ := new handler
	static HGUI2
	If !HGUI2{
		Gui,New,+LastFound +hwndHGUI2 -Caption +E0x20 +ToolWindow +AlwaysOnTop
		Gui,Color,00FF00
		Gui,1:Default
		WinSet,Transparent,50
	}

	If (hwnd_CsvList = ""){
		Gui,%HGUI2%:Cancel
		Return
	}

	WinGetPos,x,y,w,h,ahk_id %hwnd_CsvList%
	Gui,%HGUI2%:Show,X%x% Y%y% w%w% h%h% NA
}

ShowFileFullPath:
;可将用户选择的选项储存为该项目的位置而不是该选项的名称。如果没有选择项目，对于 ComboBox 将储存编辑框中的文字
	GuiControl,,Dir,%GuiDropFiles_FileFullPath%
	GuiControl,Choose,Dir,%GuiDropFiles_FileFullPath%
Return

movedropfile:
	;首先将目标文件夹拖拽到窗口
	;判断拖拽的是否是文件夹
	If InStr(FileExist(GuiDropFiles_FileFullPath),"D")
	{
		TargetFolder := GuiDropFiles_FileFullPath
		IniWrite,%TargetFolder%,%run_iniFile%,常规,TargetFolder
		MsgBox,,,目标文件夹设置为 %TargetFolder% 。,3
		Return
	}
	FileFullPath:=GuiDropFiles_FileFullPath
	;分割文件路径
	SplitPath,FileFullPath,FileName,,FileExtension,FileNameNoExt

	IfInString,FileNameNoExt,foo_
	{
		;文件名类似 foo_lick_1.0.3.zip  的移动到 H:\foobar2000 v1.1.x\foo_lick
		StringGetPos,v_pos,FileNameNoExt,_,1
		StringLeft,FileNameNoExt,FileNameNoExt,%v_pos%

		TargetFile = H:\foobar2000 v1.1.x\%FileNameNoExt%\%FileName%
		IfNotExist,H:\foobar2000 v1.1.x\%FileNameNoExt%
			FileCreateDir,H:\foobar2000 v1.1.x\%FileNameNoExt%
		ifExist,%TargetFile%
		{
			MsgBox,指定文件夹中已存在同名文件!
			Return
		}
		Else
		{
			;Run,%comspec% /c move "%A_LoopField%" "H:\foobar2000 v1.1.x\%FileNameNoExt%"
			FileMove,%FileFullPath%,H:\foobar2000 v1.1.x\%FileNameNoExt%
			Return
		}
	}
	If InStr(FileExist(TargetFolder),"D")
	{
	;有同名文件时，自动重命名文件
		TargetFile = %TargetFolder%\%FileName%
		ifExist,%TargetFile%
		{
			ind = 1
			Loop,100
			{
				TargetFile = %TargetFolder%\%FileNameNoExt%_(%ind%).%FileExtension%
				IfExist,%TargetFile%
				{
					ind += 1
					Continue
				}
				Else
				{
					;Run,%comspec% /c move "%A_LoopField%" "%TargetFile%"
					FileMove,%FileFullPath%,%TargetFile%
					TrayTip,移动文件,文件 %FileFullPath% 已重命名并移动到文件夹 %TargetFolder% 。,2
					break
				}
			}
			return
		}
	; 无同名文件时，复制文件
		Else
		{
			;Run,%comspec% /c move "%A_LoopField%" "%TargetFolder%"
			FileMove,%FileFullPath%,%TargetFolder%
			TrayTip,移动文件,文件 %FileFullPath% 已移动到文件夹 %TargetFolder% 。,2
		}
	}
	Else
	{
		TrayTip,移动文件,目标文件夹没有设置，文件不会移动，`n如果要移动文件，请先拖拽文件夹到窗口或选择一个文件夹。,5
	}
Return