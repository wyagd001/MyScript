#ifWinActive ahk_Group ccc
$Space::
if(A_Cursor="IBeam") or IsRenaming() or (IME_GetSentenceMode(_mhwnd())= 0)
{
 send {space}
 return
}
Files := ShellFolder(0,2)
if !Files or IsFolder(Files) or instr(CandySel,"`n")
	return
SplitPath,Files,,,Files_Ext
if(Files_Ext="")
	return
Candy_Cmd:=SkSub_Regex_IniRead(Candy_ProFile_Ini, "FilePrew", "i)(^|\|)" Files_Ext "($|\|)")
if Candy_Cmd
{
If IsLabel("Cando_" . Candy_Cmd . "_prew")
	Goto % "Cando_" .  Candy_Cmd . "_prew"
} 
return
#ifWinActive

#ifWinActive 文件预览 ahk_class AutoHotkeyGUI
$Space::
goto PreWWinGuiClose
#ifWinActive

PreWWinGuiClose:
Gui,PreWWin:Destroy
if pipa
ObjRelease( pipa )
return

PreWWinGuiSize:
GuiControl, Move, displayArea, x0 y0 w%A_GuiWidth% h%A_GuiHeight%
GuiControl, Move, WMP,x0 y0 w%A_GuiWidth% h%A_GuiHeight%
   return

IsFolder(Path) {
	return InStr(FileExist(Path), "D") ? True : False
}

Cando_pdf_prew:
GUI, PreWWin:Default
GUI, PreWWin:Destroy
Gui, +ReSize
Gui Add, ActiveX,xm w1050 h800 vWB, Shell.Explorer
WB.silent := true
ComObjConnect(WB, WB_events)
IOleInPlaceActiveObject_Interface := "{00000117-0000-0000-C000-000000000046}"
pipa := ComObjQuery( WB, IOleInPlaceActiveObject_Interface )
TranslateAccelerator := NumGet( NumGet( pipa+0 ) + 5*A_PtrSize )
OnMessage( 0x0100, "WM_KeyPress" ) ; WM_KEYDOWN 
OnMessage( 0x0101, "WM_KeyPress" ) ; WM_KEYUP   

Gui, PreWWin:Show,,% Files " - 文件预览"
WB.Navigate("https://mozilla.github.io/pdf.js/web/viewer.html?file=blank.pdf")
sleep,3000
settimer,autoopenpdf,-1000 
wb.document.getElementById("openFile").click()
tooltip
return

autoopenpdf:
WinWaitActive,ahk_class #32770,,5000
ControlSetText , edit1, %Files%, ahk_class #32770
sleep,100
send {enter}
return

class WB_events
{
	;for more events and other, see http://msdn.microsoft.com/en-us/library/aa752085

	NavigateComplete2(wb) {
		;~ wb.Stop() ;blocked all navigation, we want our own stuff happening
	}
	DownloadComplete(wb, NewURL) {
		;~ wb.Stop() ;blocked all navigation, we want our own stuff happening
	}
	DocumentComplete(wb, NewURL) {
		;~ wb.Stop() ;blocked all navigation, we want our own stuff happening
	}
}

WM_KeyPress( wParam, lParam, nMsg, hWnd ) {

Global WB, pipa, TranslateAccelerator
Static Vars := "hWnd | nMsg | wParam | lParam | A_EventInfo | A_GuiX | A_GuiY" 

  WinGetClass, ClassName, ahk_id %hWnd%

  If ( ClassName = "Shell DocObject View" && wParam = 0x09 ) {
    WinGet, hIES, ControlListHwnd, ahk_id %hWnd% ; Find child of 'Shell DocObject View'
    ControlFocus,, ahk_id %hIES%
    Return 0
  }

  If ( ClassName = "Internet Explorer_Server" ) {

    VarSetCapacity( MSG, 28, 0 )                   ; MSG STructure    http://goo.gl/4bHD9Z
    Loop, Parse, Vars, |, %A_Space%
      NumPut( %A_LoopField%, MSG, ( A_Index-1 ) * A_PtrSize )

    Loop 2  ; IOleInPlaceActiveObject::TranslateAccelerator method    http://goo.gl/XkGZYt
      r := DllCall( TranslateAccelerator, UInt,pipa, UInt,&MSG )
    Until wParam != 9 || WB.document.activeElement != ""

    IfEqual, R, 0, Return, 0         ; S_OK: the message was translated to an accelerator.

  }
}

Cando_music_prew:
GUI, PreWWin:Default
GUI, PreWWin:Destroy
Gui, +LastFound +Resize
Gui, Add, ActiveX, x0 y0 w0 h0 vWMP, WMPLayer.OCX
WMP.Url := files
Gui, PreWWin:Show, w500 h300 Center,% Files " - 文件预览"
return

Cando_pic_prew:
GUI, PreWWin:Destroy
GUI, PreWWin:Default
        GUI, -Caption +AlwaysOnTop +Owner
        Gui, Margin, 0, 0
        Gui, Add, Picture, vpicpre, %files%
        Gui, Show, AutoSize Center
        WinGetPos, Xpos, Ypos, Width, Height, A
        picwidth := A_ScreenWidth*0.8
        if (Width>picwidth)
        {
            GuiControl,,picpre,*w%picwidth% *h-1 %files%
            Gui, Show, AutoSize Center
        }
        picheight := A_ScreenHeight*0.8
        if (Height>picheight)
        {
            GuiControl,,picpre,*w-1 *h%picheight% %files%
            Gui, Show, AutoSize Center,% Files " - 文件预览"
        }
return

Cando_text_prew:
if TF_CountLines(files)>100
{
Loop, Read,% files
{
textvalue .= A_LoopReadLine "`n"
if a_index >100
break
}
}
else
FileRead,textvalue,%files%
GUI, PreWWin:Destroy
GUI, PreWWin:Default
Gui, +ReSize
Gui, Add,text,,qqqq
Gui, Add, Edit, w800 h600 ReadOnly vdisplayArea,
Gui, Show, AutoSize Center, % Files " - 文件预览"
GuiControl,, displayArea,%textvalue%
textvalue=
return

