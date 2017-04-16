SetWorkingDir %A_ScriptDir%


IfNotExist, Notepad
  FileCreateDir, Notepad
IfNotExist, Notepad\Number.txt
  FileAppend, 1, Notepad\Number.txt
IfNotExist, Notepad\Note1.txt
  FileAppend, , Notepad\Note1.txt
IfNotExist, Notepad\ToDoNote1.txt
  FileAppend, , Notepad\ToDoNote1.txt
IfNotExist, Notepad\Cancel.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Cancel.bmp, Notepad\Cancel.bmp
IfNotExist, Notepad\new.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/new.bmp, Notepad\new.bmp
IfNotExist, Notepad\Note.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Note.bmp, Notepad\Note.bmp
IfNotExist, Notepad\Save.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Save.bmp, Notepad\Save.bmp
IfNotExist, Notepad\Alarm.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Alarm.bmp, Notepad\Alarm.bmp
IfNotExist, Notepad\Tab1On.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Tab1On.bmp, Notepad\Tab1On.bmp
IfNotExist, Notepad\Tab1Off.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Tab1Off.bmp, Notepad\Tab1Off.bmp
IfNotExist, Notepad\Tab1Off2.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Tab1Off2.bmp, Notepad\Tab1Off2.bmp
IfNotExist, Notepad\Tab2Off.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Tab2Off.bmp, Notepad\Tab2Off.bmp
IfNotExist, Notepad\Tab2Off2.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Tab2Off2.bmp, Notepad\Tab2Off2.bmp
IfNotExist, Notepad\Tab2On.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Tab2On.bmp, Notepad\Tab2On.bmp
IfNotExist, Notepad\Tab3On.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Tab3On.bmp, Notepad\Tab3On.bmp
IfNotExist, Notepad\Tab3Off.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Tab3Off.bmp, Notepad\Tab3Off.bmp
IfNotExist, Notepad\Button1Pushed.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Button1Pushed.bmp, Notepad\Button1Pushed.bmp
IfNotExist, Notepad\Button2Pushed.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Button2Pushed.bmp, Notepad\Button2Pushed.bmp
IfNotExist, Notepad\Button1Normal.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Button1Normal.bmp, Notepad\Button1Normal.bmp
IfNotExist, Notepad\Button2Normal.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Button2Normal.bmp, Notepad\Button2Normal.bmp
IfNotExist, Notepad\Button1BPushed.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Button1BPushed.bmp, Notepad\Button1BPushed.bmp
IfNotExist, Notepad\Button2BPushed.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Button2BPushed.bmp, Notepad\Button2BPushed.bmp
IfNotExist, Notepad\Button1BNormal.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Button1BNormal.bmp, Notepad\Button1BNormal.bmp
IfNotExist, Notepad\Button2BNormal.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Button2BNormal.bmp, Notepad\Button2BNormal.bmp
IfNotExist, Notepad\Button3BPushed.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Button3BPushed.bmp, Notepad\Button3BPushed.bmp
IfNotExist, Notepad\Button3BNormal.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Button3BNormal.bmp, Notepad\Button3BNormal.bmp
IfNotExist, Notepad\Default.png
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Default.PNG, Notepad\Default.png
IfNotExist, Notepad\OptionsBar.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/OptionsBar.bmp, Notepad\OptionsBar.bmp
IfNotExist, Notepad\NotePreview.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/NotePreview.bmp, Notepad\NotePreview.bmp
IfNotExist, Notepad\Blank.png
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/blank.PNG, Notepad\Blank.png
IfNotExist, Notepad\Blank.png
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/blank.PNG, Notepad\Blank.png
IfNotExist, Notepad\OptionsBorder.bmp
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/OptionsBorder.bmp, Notepad\OptionsBorder.bmp
IfNotExist, Notepad\Icon.ico
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Icon.ico, Notepad\Icon.ico
IfNotExist, Notepad\main.dll
  UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/main.dll, Notepad\main.dll

#SingleInstance Force

;Ala-Vista Note App
;
;Already version 1.6!

AppVersion=1.6




;Never edit this position!;
;Developer should be always 0!;
;Changing this value may cause malfunction!;
Developer:=0
;Never edit this position!;


menu, tray, icon, notepad\icon.ico

SetWinDelay, 10
SetBatchLines, 10
SetControlDelay, 10
SetMouseDelay, 10

if(Developer>0)
  DisableDownloadMng=1

Check1=%1%
Check2=/nodm
if(Check1=Check2)
{
MsgBox, 262208, Update Manager, Note has been lauched with disabled update manager. Please reload the script to undo this., 4
DisableDownloadMng=1
}
Check2=/safe
if(Check1=Check2)
{
  msgbox, %1%
  FileDelete, Notepad\safemodetmp.bat
}

Hotkey, LButton, PickColorHook
Hotkey, LButton, Off

main_dll := DllCall("LoadLibrary", "str", "main.dll")

;;;;;;;;;;;;;;;;
;IfNotExist, Notepad\*.bmp
;{
;    UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Cancel.bmp, Notepad\Cancel.bmp
;    UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/new.bmp, Notepad\new.bmp
;    UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Note.bmp, Notepad\Note.bmp
;    UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Save.bmp, Notepad\Save.bmp
;    UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/Alarm.bmp, Notepad\Alarm.bmp
;Tab1On
;}
;;;;;;;;;;;;;;;;

IniRead, AnimationType1, Notepad\Settings.ini, Settings, AnimationType1
IniRead, AnimationType2, Notepad\Settings.ini, Settings, AnimationType2
IniRead, UseAnimation, Notepad\Settings.ini, Settings, UseAnimation
IniRead, UseNotePreview, Notepad\Settings.ini, Settings, UseNotePreview
IniRead, UseChangableAnimation, Notepad\Settings.ini, Settings, UseChangableAnimation
IniRead, AskToUpdate, Notepad\Settings.ini, Settings, AskToUpdate
IniRead, SilentUpdate, Notepad\Settings.ini, Settings, SilentUpdate
IniRead, TransparencyLevel, Notepad\Settings.ini, Settings, TransparencyLevel

OnExit, Exit
OnMessage(0x201, "LBtnDown")
OnMessage(0x202, "LBtnUp")
if(UseNotePreview=1)
{
OnMessage(0x203, "LBtnDblClick")
OnMessage(0x206, "RBtnDblClick")
}

Menu, tray, add, Options, ShowOptions
Menu, tray, add, Enable/Disable window, EnableDisable
Menu, Tray, Default, Enable/Disable window

IfNotExist, Notepad\PaintNote1.png
  FileCopy, Notepad\Default.png, Notepad\PaintNote1.png

Enabled=1
Number=1
MaxNum=1
Note1=Welcome to Note %AppVersion%. Click here to create new note.
notwriting=1
Thickness=5
UseChangableAnimation=1

FileRead, Dictionary, Notepad\Dictionary.txt

FileRead, Number, Notepad\LastNote.txt

if(Number="")
  Number:=1

FileRead, Gui, Notepad\LastPos.txt
StringSplit, Gui, Gui, *


Gui, 6:Default

Gui, +LastFound -Caption +OwnDialogs -SysMenu
Gui, Color, CFC1D0
GUI_ID6:=WinExist()
Gui, Margin, 0,0
Gui, Add, Picture, gDragPreview x0 y0, Notepad\OptionsBar.bmp
Gui, Add, Picture, gDragPreview x0 y23 h340 w20, Notepad\OptionsBorder.bmp
Gui, Add, Picture, gDragPreview x477 y0 h363 w20, Notepad\OptionsBorder.bmp
Gui, Add, Picture, gDragPreview x0 y363 h20 w497, Notepad\OptionsBorder.bmp
Gui, Add, GroupBox, x30 y24 w425 h79, General options.
Gui, Add, Checkbox, gAnimationJustChanged vUseAnimationCheckbox x42 y40, Use window &animation.
Gui, Add, Checkbox, vUseChangableAnimationCheckbox x42 y55, Use &changable animation. (When checked, the "Note - Preview" window`nchanges it's hide animation, depending on the actual position of the main window)
Gui, Add, Checkbox, gNotePreviewJustChanged vUseNotePreviewCheckbox x42 y83, Use the "Note - &Preview" window.
Gui, Add, GroupBox, x30 y103 h74 w425, FixMe options.
Gui, Add, Button, vUpdateNowSettingsButton gNonSilentUpdate x42 y119, &Update the app now
Gui, Add, Text, x154 y118 BackgroundTrans vUpdateErrorOutput, NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN`nNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
Gui, Add, Button, gFixTheAppWarning vFixMeButton x42 y147, &Fix Notepad
Gui, Add, Button, gRebootSafeMode vSafeModeButton x143 y147, S&witch Notepad to safe mode.
Gui, Add, GroupBox, x30 y177 w425 h106, Detailed animation options.
Gui, Add, Text, vAnimationType1DDLText x42 y221, Animation type of the preview`nwindow, when being &opened.
Gui, Add, DropDownList, vAnimationType1DDList x42 y193 w140, Default||Fade|Left to right|Right to left|Top to bottom|Bottom to top|Centre|Top-left to bottom-right|Top-right to bottom-left|Bottom-left to top-right|Bottom-right to top-left
Gui, Add, Text, vAnimationType2DDLText x303 y221, Animation type of the preview`nwindow, when being c&losed.
Gui, Add, DropDownList, vAnimationType2DDList x303 y193 w140, Default||Fade|Left to right|Right to left|Top to bottom|Bottom to top|Centre|Top-left to bottom-right|Top-right to bottom-left|Bottom-left to top-right|Bottom-right to top-left
Gui, Add, Text, x42 y259, &Transparency level of the main window, when deactivated:
Gui, Add, Edit, w43 x325 y255 Number
Gui, Add, UpDown, vTransparencyLevelCheckbox Range1-254 x325 y255, 159
Gui, Add, GroupBox, x30 y283 w425 h50, Updating options.
Gui, Add, Checkbox, vSilentUpdateCheckbox x42 y297, &Display errors, which occured while updating the program.
Gui, Add, Checkbox, vAskToUpdateCheckbox x42 y313, As&k the user what to do, when an update is availiable.
Gui, Add, Button, Default gSaveOptions x152 y335 w90, &Save Settings
Gui, Add, Button, gDiscardOptions vDiscardOptionsButton x242 y335 w90, D&iscard Changes
GuiControl, , UpdateErrorOutput, %A_Space%
Gui, Show, Hide

IfNotExist, Notepad\Settings.ini
{
  GuiControl, Disable, DiscardOptionsButton
  goto ShowOptions
}


Gui, 4:+AlwaysOnTop -Caption +LastFound +OwnDialogs +Owner -SysMenu
GUI_ID4:=WinExist()
Gui, 4:Margin, 0,0
Gui, 4:Add, Picture, x0 y0, Notepad\ColorPalette.png

Sleep, 500

Gui, 3:+AlwaysOnTop -Caption +ToolWindow +Owner +LastFound +OwnDialogs -SysMenu
GUI_ID3:=WinExist()
Gui, 3:Show, x0 y0 w1024 h768
WinSet, Transparent, 1, ahk_id %GUI_ID3%
Gui, 3:Hide

Sleep, 500

Gui, 2:Default

Gui, +LastFound +Owner -Caption +OwnDialogs -SysMenu
GUI_ID2:=WinExist()
hdc:=DllCall("GetDC", UInt,  GUI_ID2)
Gui, Margin, 0, 0
Gui, Color, FAF99F
Gui, Add, Edit, vNotePreview +E0x200 -Wrap +HScroll x4 y44 h500 w380, This is a note preview...
Gui, Add, ListView, gRefreshListView x4 y44 h500 w380 vToDoList Checked -ReadOnly -Hdr +HScroll -Multi +0x8, Note
LV_ModifyCol(1, "Left")
Gui, Add, Picture, gDelete x4 y4, Notepad\Cancel.bmp
Gui, Add, Picture, gSave x23 y4, Notepad\Save.bmp
Gui, Add, Picture, vTab1On x4 y23, Notepad\Tab1On.bmp
Gui, Add, Picture, vTab1Off gTab1SwitchOn x4 y23, Notepad\Tab1Off.bmp
GuiControl, Hide, Tab1Off
Gui, Add, Picture, vTab1Off2 gTab1SwitchOn x4 y23, Notepad\Tab1Off2.bmp
GuiControl, Hide, Tab1Off2
Gui, Add, Picture, vTab2On x70 y23, Notepad\Tab2On.bmp
GuiControl, Hide, Tab2On
Gui, Add, Picture, vTab2Off gTab2SwitchOn x70 y23, Notepad\Tab2Off.bmp
GuiControl, Hide, Tab2Off
Gui, Add, Picture, vTab2Off2 gTab2SwitchOn x70 y23, Notepad\Tab2Off2.bmp
Gui, Add, Picture, vTab3On x126 y23, Notepad\Tab3On.bmp
GuiControl, Hide, Tab3On
Gui, Add, Picture, vTab3Off gTab3SwitchOn x126 y23, Notepad\Tab3Off.bmp  ;126   174
GuiControl, Show, NotePreview
GuiControl, Hide, ToDoList
Gui, Add, Picture, vPaintingField gNone x4 y44 h500 w380, Notepad\blank.png
GuiControl, Hide, PaintingField
Gui, Add, Picture, vPFClear gNone x174 y27, Notepad\Button2BNormal.bmp
Gui, Add, Picture, vPFPick gNone x222 y27, Notepad\Button1BNormal.bmp
Gui, Add, Picture, vPFPalette gNone x270 y27, Notepad\Button3BNormal.bmp
Gui, Add, Edit, vThicknessSet +0x2000 -E0x200 x318 y27 Limit W20 H17, 5
GuiControl, Hide, ThicknessSet
GuiControl, Hide, PFPalette
GuiControl, Hide, PFClear
GuiControl, Hide, PFPick
Gui, Add, Picture, vLVDelete gNone x174 y27, Notepad\Button2Normal.bmp
Gui, Add, Picture, vLVAdd gNone x222 y27, Notepad\Button1Normal.bmp
GuiControl, Hide, LVAdd
GuiControl, Hide, LVDelete
Gui, Add, Picture, x40 y0 w348 h20 gDragPreview, Notepad\NotePreview.bmp
Gui, Add, Text, BackgroundTrans x42 y7, Notepad - Preview
Gui, Show, Hide w388 h548

Gui, 1:Default

Gui +LastFound +Owner +AlwaysOnTop -Caption +OwnDialogs -SysMenu


GUI_ID:=WinExist()
Gui, Margin, 0, 0
Gui, Color, FAF99F
Gui, Add, Picture, gDelete x4 y4, Notepad\Cancel.bmp
Gui, Add, Edit, vAlarmSetH Limit2 x17 y4 W18 H17, 00
Gui, Add, Edit, vAlarmSetM Limit2 x35 y4 W18 H17, 00
Gui, Add, Edit, vAlarmSetS Limit2 x53 y4 W18 H17, 00
Gui, Add, Picture, vAlarmButton gSetTimer x54 y4, Notepad\Alarm.bmp
GuiControl, Hide, AlarmSetH
GuiControl, Hide, AlarmSetM
GuiControl, Hide, AlarmSetS
Gui, Add, Picture, gSave x73 y4, Notepad\Save.bmp
Gui, Add, Picture, gNew x92 y4, Notepad\New.bmp
Gui, Add, Text, BackgroundTrans gEdit vNoteRead x4 y26 W99 H78, tttttttttttttttttttttttttttttttttttttttttttttttt
Gui, Add, Edit, vNoteWrite R5 x4 y26 W99, Welcome to Note %AppVersion%. Click here to create new note.
GuiControl, Hide, NoteWrite
Gui, Add, Text, BackgroundTrans gPrev x4 y104, %A_Space%<%A_Space%
Gui, Add, Text, BackgroundTrans gNext x14 y104, %A_Space%>%A_Space%
Gui, Add, Text, vAlarmRem x30 y104, 00:00:00
GuiControl, Hide, AlarmRem
Gui, Add, Picture, vBackground 0x4000000 gStopWriting x0 y0, Notepad\Note.bmp
GuiControl, Show, NoteRead
GuiControl, , NoteRead, Welcome to Note %AppVersion%. Click here to create new note.

SysGet, VirtualScreenWidth, 78
SysGet, VirtualScreenHeight, 79
VirtualScreenWidth-=113
VirtualScreenHeight-=121

PreviewVisible:=0

if(Gui1<0 or Gui2<0 or Gui1>VirtualScreenWidth or Gui2>VirtualScreenHeight)
{
    Gui, Show, , Notepad
    WinGetPos, Gui_X, Gui_Y, , , ahk_id %GUI_ID%
    FileDelete, Notepad\LastPos.txt
    FileAppend, %Gui_X%*%Gui_Y%, Notepad\LastPos.txt
}
Else
    Gui, Show, x%Gui1% y%Gui2%, Notepad

w:=WinExist()

WinSet, Region, 0-0 110-0 112-2 112-120 3-120 0-117 0-0, ahk_id %w%

Loop, Notepad\Note*.txt
    FileRead, Note%A_Index%, %A_LoopFileLongPath%
Note:=Note%Number%
GuiControl, , NoteRead, %Note%

Loop, Notepad\ToDoNote*.txt
    FileRead, ToDoNote%A_Index%, %A_LoopFileLongPath%

FileRead, MaxNum, Notepad\Number.txt

if(Note1="")
    GuiControl, , NoteRead, Welcome to Note %AppVersion%. Click here to create new note.

gosub EnableDisable

SetTimer, Update, 60000

Sleep, 1000

SetWinDelay, -1
SetBatchLines, -1
SetControlDelay, -1
SetMouseDelay, -1
Return


SetTimer:
if(AlarmCounting=1)
{
    if(A_GuiEvent="DoubleClick")
    {
        Sleep, 500
        GuiControl, Hide, AlarmRem
        AlarmCounting=0
        SetTimer, AlarmCountdown, OFF
        Return
    }
Return
}
GuiControl, Show, AlarmSetH
GuiControl, Show, AlarmSetM
GuiControl, Show, AlarmSetS
GuiControl, , AlarmSetH, 00
GuiControl, , AlarmSetM, 00
GuiControl, , AlarmSetS, 00
GuiControl, Hide, AlarmButton
SettingAlarm=1
Return

AlarmCountdown:
Alarm3-=1
if(Alarm3<0)
{
Alarm3:=59
Alarm2-=1
}
if(Alarm2<0)
{
Alarm2:=59
Alarm1-=1
}
if(Alarm1<0)
{
Sleep, 500
GuiControl, Hide, AlarmRem
Gui, Color, FF8080
SoundBeep
Sleep, 500
Gui, Color, FFFFFF
Sleep, 500
Gui, Color, FAF99F
Sleep, 500
SoundBeep
Gui, Color, FF8080
Sleep, 500
Gui, Color, FFFFFF
Sleep, 500
Gui, Color, FAF99F
Sleep, 500
AlarmCounting=0
if(RunAppWhenExpired=1)
    Run, %FileToRun%, %Parameter%
SetTimer, AlarmCountdown, OFF
Return
}
AlarmT:=StrLen(Alarm1)
if(AlarmT=1)
    Alarm1=0%Alarm1%
AlarmT:=StrLen(Alarm2)
if(AlarmT=1)
    Alarm2=0%Alarm2%
AlarmT:=StrLen(Alarm3)
if(AlarmT=1)
    Alarm3=0%Alarm3%
AlarmA=%Alarm1%:%Alarm2%:%Alarm3%
GuiControl, , AlarmRem, %AlarmA%
Return

StopWriting:
if(SettingAlarm=1)
{
GuiControl, Hide, AlarmSetH
GuiControl, Hide, AlarmSetM
GuiControl, Hide, AlarmSetS
GuiControl, Show, AlarmButton
SettingAlarm=0
}
if (notwriting=1)
{
if(A_GuiEvent="DoubleClick")
{
    WinGetPos, Gui_X, Gui_Y, , , ahk_id %GUI_ID%
    FileDelete, Notepad\LastPos.txt
    FileAppend, %Gui_X%*%Gui_Y%, Notepad\LastPos.txt
    Return
}
	PostMessage, 0xA1, 2,,, A
	Return
}
GuiControlGet, Note,, NoteWrite
GuiControl, Show, NoteRead
GuiControl, Hide, NoteWrite
gosub Save
notwriting=1
if(Note="")
{
    if(MaxNum>1)
    {
        MsgBox, 8196,, No text has been entered. Would you like to delete the note?
        IfMsgBox Yes
            gosub Delete
        IfMsgBox No
            GuiControl, , NoteRead, Welcome to Note %AppVersion%. Click here to create new note
     }Else
            GuiControl, , NoteRead, Welcome to Note %AppVersion%. Click here to create new note
}
Else
{
;   NoteNew=
;   Loop, Parse, Note, %A_Space%
;   {
;       Word=
;       pos:=InStr(Dictionary, A_LoopField)
;       if(pos=0)
;           Loop, Parse, A_LoopField
;              Word=%Word%&%A_LoopField%
;       Else
;           Word:=A_LoopField
;       NoteNew=%NoteNew% %Word%
;    }
;   Gui, Font, underline
   GuiControl, , NoteRead, %Note%
}
Return

Save:
if(PreviewVisible=1)
{
if(PaintingNow=1)
{
MsgBox, 8195,, The image is still unsaved. Save it now?
Sleep, 100
IfMsgBox Yes
   SaveImage("PaintNote" . Number)
IfMsgBox Cancel
   Return
PaintingNow=0
WinSet, Transparent, OFF, ahk_id %GUI_ID2%
Gui 2:-Caption -ToolWindow
Gui 2:Show, Activate
gosub Tab1SwitchOn
}
GuiControlGet, Note,, NotePreview
GuiControl, 1:Show, NoteRead
GuiControl, 1:Hide, NoteWrite
Note%Number%:=Note
if(Note="")
{
    MsgBox, 8195,, No text has been entered. Would you like to delete the note?
    IfMsgBox Yes
        gosub Delete
    IfMsgBox Cancel
        Return
    IfMsgBox No
        Note=Welcome to Note %AppVersion%. Click here to create new note.
}
GuiControl, 1:, NoteRead, %Note%
FileDelete, Notepad\Note%Number%.txt
FileAppend, %Note%, Notepad\Note%Number%.txt

LVCount:=LV_GetCount()
ToDoNote:=""
Loop %LVCount%
{
  LV_GetText(ToDoText, A_Index)
  SendMessage, 4140, A_Index - 1, 0xF000, SysListView321, ahk_id  %GUI_ID2%
  if((ErrorLevel >> 12)-1=1)
    ListViewCheck:="!"
  Else
    ListViewCheck:="@"
  ToDoNote=%ToDoNote%%ListViewCheck%%ToDoText%|
}
FileDelete, Notepad\ToDoNote%Number%.txt
FileAppend, %ToDoNote%, Notepad\ToDoNote%Number%.txt
ToDoNote%Number%:=ToDoNote
AnimateGUIWindow(GUI_ID2,GUI_ID)
Gui, 1:Default
if(Enabled=-1)
{
	WinSet, ExStyle, -0x20, ahk_id %GUI_ID%
	TMP:=(255-TransparencyLevel)/8
	Loop %TMP%
	{
		Sleep, 25
		TMPTrans:=TransparencyLevel+A_Index*8
		WinSet, Transparent, %TMPTrans%, ahk_id %GUI_ID%
	}
	WinSet, Transparent, OFF, ahk_id %GUI_ID%
	Enabled=1
}
PreviewVisible:=0
Menu, Tray, Click, 2
Return
}
if(SettingAlarm=1)
{
Parameter:=""
MsgBox, 262180, Note v1.16, Do you want to launch any program when the timer expires?
IfMsgBox Yes
{
FileSelectFile, FileToRun
if(FileToRun<>"")
{
    MsgBox, 262180, Note v1.16, Do you want any parameteres to be sent?
IfMsgBox Yes
    InputBox, Parameter, Note v1.16, Parameters:, , 200, 125
RunAppWhenExpired=1
}
}
GuiControl, Hide, AlarmSetH
GuiControl, Hide, AlarmSetM
GuiControl, Hide, AlarmSetS
GuiControl, Show, AlarmButton
GuiControl, Show, AlarmRem
GuiControlGet, Alarm1,, AlarmSetH
GuiControlGet, Alarm2,, AlarmSetM
GuiControlGet, Alarm3,, AlarmSetS
Alarm=%Alarm1%:%Alarm2%:%Alarm3%
GuiControl, , AlarmRem, %Alarm%
SetTimer, AlarmCountdown, 1000
SettingAlarm=0
AlarmCounting=1
Return
}
if (notwriting=1)
    GuiControlGet, Note,, NoteRead
Else
    GuiControlGet, Note,, NoteWrite
GuiControl, , NoteRead, %Note%
GuiControl, Show, NoteRead
GuiControl, Hide, NoteWrite
Note%Number%:=Note
FileDelete, Notepad\Note%Number%.txt
FileAppend, %Note%, Notepad\Note%Number%.txt
Return

New:
if(SettingAlarm=1)
{
GuiControl, Hide, AlarmSetH
GuiControl, Hide, AlarmSetM
GuiControl, Hide, AlarmSetS
GuiControl, Show, AlarmButton
SettingAlarm=0
}
if (notwriting=0)
    gosub Save
Else
    notwriting=0
MaxNum+=1
FileDelete, Notepad\Number.txt
FileAppend, %MaxNum%, Notepad\Number.txt
Number:=MaxNum
GuiControl, , NoteRead, Welcome to Note %AppVersion%. Click here to create new note.
GuiControl, , NoteWrite,
GuiControl, Hide, NoteRead
GuiControl, Show, NoteWrite
GuiControl, Focus, NoteWrite
Return

Edit:
if(SettingAlarm=1)
{
GuiControl, Hide, AlarmSetH
GuiControl, Hide, AlarmSetM
GuiControl, Hide, AlarmSetS
GuiControl, Show, AlarmButton
SettingAlarm=0
}
GuiControlGet, Note,, NoteRead
if(Note=="Welcome to Note %AppVersion%. Click here to create new note.")
   GuiControl, , NoteWrite,
Else
   GuiControl, , NoteWrite, %Note%
GuiControl, Hide, NoteRead
GuiControl, Show, NoteWrite
GuiControl, Focus, NoteWrite
notwriting=0
Return

Prev:
if(SettingAlarm=1)
{
GuiControl, Hide, AlarmSetH
GuiControl, Hide, AlarmSetM
GuiControl, Hide, AlarmSetS
GuiControl, Show, AlarmButton
SettingAlarm=0
}
if(Number=1)
   Return
Number-=1
if(Number<1)
   Number=1
Note:=Note%Number%
if(Note="")
    Note=Welcome to Note %AppVersion%. Click here to create new note.
if (notwriting=1)
    GuiControl, , NoteRead, %Note%
Else
    GuiControl, , NoteWrite, %Note%
Return

Next:
if(SettingAlarm=1)
{
GuiControl, Hide, AlarmSetH
GuiControl, Hide, AlarmSetM
GuiControl, Hide, AlarmSetS
GuiControl, Show, AlarmButton
SettingAlarm=0
}
if(Number=MaxNum)
   Return
Number+=1
Note:=Note%Number%
if(Note="")
    Note=Welcome to Note %AppVersion%. Click here to create new note.
if (notwriting=1)
    GuiControl, , NoteRead, %Note%
Else
    GuiControl, , NoteWrite, %Note%
Return

Delete:
if(PreviewVisible=1)
{
if(PaintingNow=1)
{
MsgBox, 8195,, The image is still unsaved. Save it now?
Sleep, 100
IfMsgBox Yes
   SaveImage("PaintNote" . Number)
IfMsgBox Cancel
   Return
PaintingNow=0
WinSet, Transparent, OFF, ahk_id %GUI_ID2%
Gui 2:-Caption -ToolWindow
Gui 2:Show, Activate
gosub Tab1SwitchOn
}
AnimateGUIWindow(GUI_ID2,GUI_ID)
Gui, 1:Default
if(Enabled=-1)
{
	WinSet, ExStyle, -0x20, ahk_id %GUI_ID%
	TMP:=(255-TransparencyLevel)/8
	Loop %TMP%
	{
		Sleep, 25
		TMPTrans:=TransparencyLevel+A_Index*8
		WinSet, Transparent, %TMPTrans%, ahk_id %GUI_ID%
	}
	WinSet, Transparent, OFF, ahk_id %GUI_ID%
	Enabled=1
}
PreviewVisible:=0
Menu, Tray, Click, 2
Return
}
if(SettingAlarm=1)
{
GuiControl, Hide, AlarmSetH
GuiControl, Hide, AlarmSetM
GuiControl, Hide, AlarmSetS
GuiControl, Show, AlarmButton
SettingAlarm=0
Return
}
if (notwriting=1)
{
if(MaxNum=1)
{
    FileDelete, Notepad\Note1.txt
    FileDelete, Notepad\ToDoNote1.txt
    ToDoNote1:=""
    FileDelete, Notepad\PaintNote1.png
    FileAppend, , Notepad\Note1.txt
    GuiControl, , NoteWrite,
    GuiControl, , NoteRead, Welcome to Note %AppVersion%. Click here to create new note.
    Return
}
Loop %MaxNum%
{
    NumberCopyTo:=A_Index+Number-1
    NumberCopyFrom:=A_Index+Number
    Note%NumberCopyTo%:=Note%NumberCopyFrom%
    Note:=Note%A_Index%
    FileDelete, Notepad\Note%A_Index%.txt
    FileAppend, %Note%, Notepad\Note%A_Index%.txt
    ToDoNote%NumberCopyTo%:=ToDoNote%NumberCopyFrom%
    ToDoNote:=ToDoNote%A_Index%
    FileDelete, Notepad\ToDoNote%A_Index%.txt
    FileAppend, %ToDoNote%, Notepad\ToDoNote%A_Index%.txt
    FileMove, Notepad\PaintNote%NumberCopyFrom%.png, Notepad\PaintNote%NumberCopyTo%.png
}
FileDelete, Notepad\Note%MaxNum%.txt
FileDelete, Notepad\ToDoNote%MaxNum%.txt
FileDelete, Notepad\PaintNote%MaxNum%.png
FileDelete, Notepad\PaintNote0.png
MaxNum-=1
FileDelete, Notepad\Number.txt
FileAppend, %MaxNum%, Notepad\Number.txt
if (Number>1)
	Number:=MaxNum
Note:=Note%Number%
GuiControl, , NoteRead, %Note%
}
Else
{
Note:=Note%Number%
GuiControl, , NoteRead, %Note%
notwriting=1
GuiControl, Show, NoteRead
GuiControl, Hide, NoteWrite
}
Return

EnableDisable:
if(Enabled=-1)
{
if(PaintingNow=1)
{
  MsgBox, 270384, Notepad - Preview, You can't hide the Preview Window while in painting mode`,`nas it will erase Your picture!, 5
  Return
}
if(PreviewHidden=1)
{
Gui, 2:Show
WinActivate, ahk_id %GUI_ID2%
PreviewHidden=0
}else{
Gui, 2:Hide
PreviewHidden=1
}
Return
}
if(SettingAlarm=1)
{
GuiControl, Hide, AlarmSetH
GuiControl, Hide, AlarmSetM
GuiControl, Hide, AlarmSetS
GuiControl, Show, AlarmButton
SettingAlarm=0
}
if(Enabled=1)
{
	WinSet, ExStyle, +0x20, ahk_id %GUI_ID%
	TMP:=(255-TransparencyLevel)/8
	Loop %TMP%   ;11
	{
		Sleep, 25
		TMPTrans:=255-A_Index*8
		WinSet, Transparent, %TMPTrans%, ahk_id %GUI_ID%
	}
	WinSet, Transparent, %TransparencyLevel%, ahk_id %GUI_ID%
	Enabled=0
	if(notwriting=0)
		goto StopWriting
}Else{
	WinSet, ExStyle, -0x20, ahk_id %GUI_ID%
	TMP:=(255-TransparencyLevel)/8
	Loop %TMP%   ;11
	{
		Sleep, 25
		TMPTrans:=TransparencyLevel+A_Index*8
		WinSet, Transparent, %TMPTrans%, ahk_id %GUI_ID%
	}
	WinSet, Transparent, OFF, ahk_id %GUI_ID%
	Enabled=1
}
Return

Update:
if(DisableDownloadMng=1)
  Return
connected:=DllCall("Wininet.dll\InternetGetConnectedState", "Str", 0x40,"Int",0)
if connected=0

{
	UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/CurrentVer.txt, %A_Temp%\NotepadCurrentVersion.txt
	FileRead, CurVer, %A_Temp%\NotepadCurrentVersion.txt
	if(CurVer=AppVersion)
	{
		SetTimer, Update, OFF
		UpdateError:="Application is up to date.`nNo new actualizations have been found."
		Return
	}else{
		if(AskToUpdate)
		{
			msgbox, 8228, New version found., New version of Note: v%CurVer% has been found.`nWould you like to continue updating (recommended)?
			ifMsgBox Yes
				ContinueUpdating=1
			else{
				ContinueUpdating=0
				SetTimer, Update, OFF
			}
		}else{
			ContinueUpdating=1
		}
		if(ContinueUpdating=1)
		{
			MsgBox, 262208, Updating..., Note v%AppVersion% has to update to version %CurVer%.`nPlease wait..., 2
			UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/UpdateList.txt, %A_Temp%\NotepadUpdateList.txt
			if ErrorLevel
			{
				UpdateError:="An error occured, while downloading the update list.`nPlease check the website for more info."
				if SilentUpdate=1
					msgbox, %UpdateError%
				Return
			}
			FileRead, UpdateList, %A_Temp%\NotepadUpdateList.txt
			UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note/ChangesList.txt, %A_Temp%\NotepadChangesList.txt
			if ErrorLevel
			{
				UpdateError:="An error occured, while downloading the changes list.`nPlease check the website for more info."
				if SilentUpdate=1
					msgbox, %UpdateError%`nHint: Run the app in safe mode to omit downloading of the changes list file.
				Return
			}
			FileRead, UpdateChanges, %A_Temp%\NotepadChangesList.txt
			Loop, Parse, UpdateList, 
			{
				StringSplit, UpdateFile, A_LoopField, ?
				UrlDownloadToFile, %UpdateFile1%, %UpdateFile2%
			}
			if ErrorLevel
			{
				UpdateError:="An error occured, while downloading update files.`nPlease check the website for more info."
				if SilentUpdate=1
					msgbox, %UpdateError%
				Return
			}
			MsgBox, 262148, Updated!, Note has just been updated! Current version is: %CurVer%.`nShow log of changes?
			IfMsgBox Yes
			    msgbox, %UpdateChanges%
			if SilentUpdate<>2
				Reload
		}
	}
}else{
UpdateError:="No internet connection. Please dial first."
Return
}
Return

NonSilentUpdate:
SilentUpdateTMP:=SilentUpdate
SilentUpdate:=2
gosub Update
SilentUpdate:=SilentUpdateTMP
GuiControl, , UpdateErrorOutput, %UpdateError%
Return

Exit:
DllCall("FreeLibrary", "UInt", main_dll)
FileDelete, Notepad\LastNote.txt
FileAppend, %Number%, Notepad\LastNote.txt
ExitApp


None:
Return


Help()
{
msgbox, To be continued
}

RBtnDblClick()
{
gosub, ShowPreview
}
LBtnDblClick()
{
gosub, HidePreview
}

LBtnDown(a,b,c,d1)
{
global LBtnOnControlCheck, PaintingNow, GUI_ID2, Thickness
if(PaintingNow=1)
{
  GuiControlGet, d2, Hwnd, PaintingField
  if(d2=d1)
  {
    GuiControlGet, Thickness,, ThicknessSet
    OnMessage(0x200, "Paint", 999)
    Paint()
    Return
  }
}
GuiControlGet, d2, Hwnd, LVAdd
if(d2=d1)
{
GuiControl, , LVAdd, Notepad\Button1Pushed.bmp
LBtnOnControlCheck=1
Return
}
GuiControlGet, d2, Hwnd, LVDelete
if(d2=d1)
{
GuiControl, , LVDelete, Notepad\Button2Pushed.bmp
LBtnOnControlCheck=2
Return
}
GuiControlGet, d2, Hwnd, PFClear
if(d2=d1)
{
GuiControl, , PFClear, Notepad\Button2BPushed.bmp
LBtnOnControlCheck=3
Return
}
GuiControlGet, d2, Hwnd, PFPick
if(d2=d1)
{
GuiControl, , PFPick, Notepad\Button1BPushed.bmp
LBtnOnControlCheck=4
Return
}
GuiControlGet, d2, Hwnd, PFPalette
if(d2=d1)
{
GuiControl, , PFPalette, Notepad\Button3BPushed.bmp
LBtnOnControlCheck=5
gosub PickColorFromPalette
Return
}
}

LBtnUp()
{
global LBtnOnControlCheck, PaintingNow, GUI_ID2
if(LBtnOnControlCheck>0)
{
GuiControl, , LVAdd, Notepad\Button1Normal.bmp
GuiControl, , LVDelete, Notepad\Button2Normal.bmp
GuiControl, , PFPick, Notepad\Button1BNormal.bmp
GuiControl, , PFClear, Notepad\Button2BNormal.bmp
if(LBtnOnControlCheck=1)
  gosub ListViewAdd
if(LBtnOnControlCheck=2)
  gosub ListViewDelete
if(LBtnOnControlCheck=3)
  gosub PFClear
if(LBtnOnControlCheck=4)
  PickColor()
if(LBtnOnControlCheck=5)
  gosub PickColorFromPaletteH
LBtnOnControlCheck=0
}
if(PaintingNow=1)
    WinSet, Transparent, 255, ahk_id %GUI_ID2%
    OnMessage(0x200, "")
}

ShowPreview:
if(PreviewVisible=0)
{
if(SettingAlarm=1)
{
GuiControl, Hide, AlarmSetH
GuiControl, Hide, AlarmSetM
GuiControl, Hide, AlarmSetS
GuiControl, Show, AlarmButton
SettingAlarm=0
}
if(Enabled=1)
{
	WinSet, ExStyle, +0x20, ahk_id %GUI_ID%
	TMP:=(255-TransparencyLevel)/8
	Loop %TMP%  ;11
	{
		Sleep, 25
		TMPTrans:=255-A_Index*8
		WinSet, Transparent, %TMPTrans%, ahk_id %GUI_ID%
	}
	WinSet, Transparent, %TransparencyLevel%, ahk_id %GUI_ID%
	Enabled=-1
	if(notwriting=0)
		gosub StopWriting
}
Gui, 2:Default
gosub Tab1SwitchOn
Gui, Show, Hide
Note:=Note%Number%
StringSplit, ToDoNoteTMP, ToDoNote%Number%, |
LV_Delete()
Loop %ToDoNoteTMP0%
   if(SubStr(ToDoNoteTMP%A_Index%, 2, StrLen(ToDoNoteTMP%A_Index%))<>"")
     if(SubStr(ToDoNoteTMP%A_Index%, 1, 1)="!")
        LV_Add("+Check",SubStr(ToDoNoteTMP%A_Index%, 2, StrLen(ToDoNoteTMP%A_Index%)))
     else
        LV_Add("-Check",SubStr(ToDoNoteTMP%A_Index%, 2, StrLen(ToDoNoteTMP%A_Index%)))
GuiControl, , NotePreview, %Note%
if(UseAnimation=1)
	if(AnimationType1=0)
	{
		WinGetPos, X, Y, , , ahk_id %GUI_ID%
		XPart2:= A_ScreenWidth/3
		XPart3:= A_ScreenWidth/3*2
		YPart2:= A_ScreenHeight/3
		YPart3:= A_ScreenHeight/3*2
		if(X>XPart3)
		  Position:=2
		Else
		  if(X>XPart2)
		    Position:=0
		  Else
		    Position:=1
		if(Y>YPart3)
		  Position+=8
		Else
		  if(Y>YPart2)
		    if(Position=0)
		      Position:=16
		    Else
		      Position:=Position
		  Else
		    Position+=4
		Position+=131072
		SetFormat, integer, hex
		Position:=Position+0
		if(UseChangableAnimation=1)
		    DllCall("AnimateWindow","UInt",GUI_ID2,"Int",500,"UInt",Position)
		Else
		    DllCall("AnimateWindow","UInt",GUI_ID2,"Int",500,"UInt",0x2000A)
		SetFormat, integer, d
	}else{
		Position:=AnimationType1+131072
		SetFormat, integer, hex
		DllCall("AnimateWindow","UInt",GUI_ID2,"Int",500,"UInt",Position)
		SetFormat, integer, d
	}
GuiControl, MoveDraw, NotePreview, x4 y44  ;Refresh the editbox to delete the "sunken" effect
Menu, Tray, Click, 1
PreviewVisible:=1
}
Return

DragPreview:
if(PreviewVisible=1)
  PostMessage, 0xA1, 2,,, ahk_id %GUI_ID2%
else
  PostMessage, 0xA1, 2,,, A
Return

HidePreview:
if(PreviewVisible=-2)
{
AnimateGUIWindow(GUI_ID2,GUI_ID)
if(Enabled=-1)
{
	WinSet, ExStyle, -0x20, ahk_id %GUI_ID%
	TMP:=(255-TransparencyLevel)/8
	Loop %TMP%
	{
		Sleep, 25
		TMPTrans:=TransparencyLevel+A_Index*8
		WinSet, Transparent, %TMPTrans%, ahk_id %GUI_ID%
	}
	WinSet, Transparent, OFF, ahk_id %GUI_ID%
	Enabled=1
}
Menu, Tray, Click, 2
PreviewVisible:=0
}
Return

Tab1SwitchOn:
if(PaintingNow=1)
{
MsgBox, 8195,, The image is still unsaved. Save it now?
Sleep, 100
IfMsgBox Yes
   SaveImage("PaintNote" . Number)
IfMsgBox Cancel
   Return
PaintingNow=0
WinSet, Transparent, OFF, ahk_id %GUI_ID2%
Gui 2:-Caption -ToolWindow
Gui 2:Show, Activate
}
GuiControl, 2:Hide, Tab1Off
GuiControl, 2:Hide, Tab1Off2
GuiControl, 2:Show, Tab1On
GuiControl, 2:Hide, Tab2On
GuiControl, 2:Hide, Tab2Off
GuiControl, 2:Show, Tab2Off2
GuiControl, 2:Show, NotePreview
GuiControl, 2:Show, Tab3Off
GuiControl, 2:Hide, Tab3On
GuiControl, 2:Hide, ToDoList
GuiControl, 2:Hide, PFPick
GuiControl, 2:Hide, PFPalette
GuiControl, 2:Hide, PFClear
GuiControl, 2:Hide, ThicknessSet
GuiControl, 2:Hide, LVAdd
GuiControl, 2:Hide, LVDelete
GuiControl, 2:Hide, PaintingField
Return
Tab2SwitchOn:
if(PaintingNow=1)
{
MsgBox, 8195,, The image is still unsaved. Save it now?
Sleep, 100
IfMsgBox Yes
   SaveImage("PaintNote" . Number)
IfMsgBox Cancel
   Return
PaintingNow=0
WinSet, Transparent, OFF, ahk_id %GUI_ID2%
Gui 2:-Caption -ToolWindow
Gui 2:Show, Activate
}
GuiControl, 2:Hide, Tab2Off2
GuiControl, 2:Hide, Tab2Off
GuiControl, 2:Show, Tab2On
GuiControl, 2:Hide, Tab1On
GuiControl, 2:Hide, Tab1Off2
GuiControl, 2:Show, Tab1Off
GuiControl, 2:Show, Tab3Off
GuiControl, 2:Hide, Tab3On
GuiControl, 2:Show, ToDoList
GuiControl, 2:Hide, NotePreview
GuiControl, 2:Hide, PFPick
GuiControl, 2:Hide, PFClear
GuiControl, 2:Hide, PFPalette
GuiControl, 2:Hide, ThicknessSet
GuiControl, 2:Show, LVAdd
GuiControl, 2:Show, LVDelete
GuiControl, 2:Hide, PaintingField
Return
Tab3SwitchOn:
PaintingNow=1
Gui 2:-Caption +ToolWindow
WinSet, Transparent, 255, ahk_id %GUI_ID2%
Gui 2:Show, Activate
IfNotExist, Notepad\PaintNote%Number%.png
  LoadImage("blank")
Else
  LoadImage("PaintNote" . Number)
Loop 3
{
  b:=A_Index
  Loop 95
    DllCall("gdi32.dll\SetPixelV",UInt,hdc,UInt,A_Index+173,UInt,b+22,UInt,color)
}
WinSet, Transparent, 255, ahk_id %GUI_ID2%
GuiControl, 2:Show, Tab2Off
GuiControl, 2:Hide, Tab2Off2
GuiControl, 2:Hide, Tab2On
GuiControl, 2:Hide, Tab1Off
GuiControl, 2:Show, Tab1Off2
GuiControl, 2:Hide, Tab1On
GuiControl, 2:Hide, Tab3Off
GuiControl, 2:Show, Tab3On
GuiControl, 2:Hide, NotePreview
GuiControl, 2:Hide, ToDoList
GuiControl, 2:Show, PFPalette
GuiControl, 2:Show, PFPick
GuiControl, 2:Show, PFClear
GuiControl, 2:Show, ThicknessSet
GuiControl, 2:Hide, LVAdd
GuiControl, 2:Hide, LVDelete
GuiControl, 2:Show, PaintingField
Return

ListViewAdd:
GuiControl, Focus, ToDoList
LV_Add("+Select", "")
Send, {END}{F2}
Return

ListViewDelete:
LV_Delete(LV_GetNext(0, "Focused"))
Return

RefreshListView:
LV_ModifyCol()
Return

Paint()
{
  global hdc, Thickness, color, GUI_ID2, DeveloperParam
  MouseGetPos, X, Y
  Y2:=Y-Floor(Thickness/2)
  X2:=X-Floor(Thickness/2)
  if(X2<4)
    Return
  if(Y2<44)
    Return
  X3:=X2+Thickness
  Y3:=Y2+Thickness
  if(X3>384)
    Return
  if(Y3>544)
    Return
  DllCall("gdi32.dll\SetPixelV",UInt,hdc,UInt,X,UInt,Y,UInt,color)
;  msgbox % DllCall("GetLastError")
  if(Thickness>1)
    Loop %Thickness%
    {
      b:=A_Index
      Loop %Thickness%
        DllCall("gdi32.dll\SetPixelV",UInt,hdc,UInt,X2+A_Index,UInt,Y2+b,UInt,color)
    }
  WinSet, Transparent, 255, ahk_id %GUI_ID2% ;The window must be refreshed (but still transparent), so that we can see what is being drawn at the moment
}

SaveImage(File, Data="", Y=44, X=4)
{
Gui 2:+AlwaysOnTop +LastFound
WinTitle:="ahk_id " + WinExist()
WinGetPos, X, Y, W, H, %WinTitle%
W:=W+X-4
H:=H+Y-4
X+=4
Y+=44
Rect=%X%`, %Y%`, %W%`, %H%
BlockInput, On
DllCall("SetCursor","UInt",DllCall("LoadCursor","UInt",DllCall("GetModuleHandle", Str, "main.dll"),"Int",2,"UInt"))
WinActivate, %WinTitle%
TakeScreenShot(Rect, "Notepad\" . File . ".png")
Gui 2:-AlwaysOnTop
Gui 1:+AlwaysOnTop
BlockInput, Off
}

PFClear:
LoadImage(0)
Return

PickColor()
{
global ChangeCursor
Gui, 3:Show, x0 y0 w1024 h768
ChangeCursor:=DllCall("LoadCursor","UInt",DllCall("GetModuleHandle", Str, "main.dll"),"Int","1","UInt")
DllCall("SetCursor","UInt",ChangeCursor)
Hotkey, LButton, On
SetTimer, ChangeCursorH, -10
}

LoadImage(File, x2=0, y2=44)
{
global GUI_ID2, PaintingField
BlockInput, On
DllCall("SetCursor","UInt",DllCall("LoadCursor","UInt",DllCall("GetModuleHandle", Str, "main.dll"),"Str","BUSY_CUR","UInt"))
if(File=0) {
  GuiControl, 2:, PaintingField, Notepad\blank.png
  GuiControl, 2:MoveDraw, PaintingField, x4 y44 w380 h500
  BlockInput, Off
  Return
}
GuiControl, 2:, PaintingField, Notepad\%File%.png  ;That was the easiest way, I thought up ;P
BlockInput, Off
}

AnimateGUIWindow(GUI_ID2, MAIN_GUI_ID)
{
	global UseChangableAnimation, UseAnimation, AnimationType2
	if(AnimationType2=0)
	{
		WinGetPos, X, Y, , , ahk_id %MAIN_GUI_ID%
		XPart2:= A_ScreenWidth/3
		XPart3:= A_ScreenWidth/3*2
		YPart2:= A_ScreenHeight/3
		YPart3:= A_ScreenHeight/3*2
		if(X>XPart3)
		  Position:=1
		Else
		  if(X>XPart2)
		    Position:=0
		  Else
		    Position:=2
		if(Y>YPart3)
		  Position+=4
		Else
		  if(Y>YPart2)
		    if(Position=0)
		      Position:=16
		    Else
		      Position:=Position
		  Else
		    Position+=8
		Position+=327680
		SetFormat, integer, hex
		if(UseAnimation=1)
		  if(UseChangableAnimation=1)
		    DllCall("AnimateWindow","UInt",GUI_ID2,"Int",500,"UInt",Position)
		  Else
		    DllCall("AnimateWindow","UInt",GUI_ID2,"Int",500,"UInt",0x50005)
		SetFormat, integer, d
	}else{
		Position:=AnimationType2+327680
		SetFormat, integer, hex
		DllCall("AnimateWindow","UInt",GUI_ID2,"Int",500,"UInt",Position)
		SetFormat, integer, d
	}
}

PickColorHook:
CoordMode, Mouse, Screen
MouseGetPos, X, Y
CoordMode, Mouse, Relative
color := DllCall("gdi32.dll\GetPixel",UInt,DllCall("GetDC", UInt,  WinExist("Progman")),UInt,X,UInt,Y)
Hotkey, LButton, OFF
ChangeCursor=0
Gui, 3:Hide
;174 23
;269 26
Loop 3
{
  b:=A_Index
  Loop 95
    DllCall("gdi32.dll\SetPixelV",UInt,hdc,UInt,A_Index+173,UInt,b+22,UInt,color)
}
WinSet, Transparent, 255, ahk_id %GUI_ID2%
Return

PickColorFromPalette:
CoordMode, Mouse, Screen
MouseGetPos, X, Y
CoordMode, Mouse, Relative
Gui, 4:Show, x%X% y%Y%
Return

PickColorFromPaletteH:
MouseGetPos, X, Y
color := DllCall("gdi32.dll\GetPixel",UInt,DllCall("GetDC", UInt,  GUI_ID4),UInt,X,UInt,Y)
Gui, 4:Hide
Loop 3
{
  b:=A_Index
  Loop 95
    DllCall("gdi32.dll\SetPixelV",UInt,hdc,UInt,A_Index+173,UInt,b+22,UInt,color)
}
GuiControl, 2:, PFPalette, Notepad\Button3BNormal.bmp
WinSet, Transparent, 255, ahk_id %GUI_ID2%
Return

ChangeCursorH:
Loop
  if(ChangeCursor<>0)
    DllCall("SetCursor","UInt",ChangeCursor)
  Else
    Return
Return

RebootSafeMode:
FileAppend, start note.ahk /safe`ncls, Notepad\safemodetmp.bat
Run, Notepad\safemodetmp.bat, , Hide
Return

ShowOptions:
IfNotExist, Notepad\Settings.ini
{
GuiControl, 6:, UseNotePreviewCheckbox, 1
GuiControl, 6:, UseChangableAnimationCheckbox, 1
GuiControl, 6:, UseAnimationCheckbox, 1
GuiControl, 6:, AskToUpdateCheckbox, 0
GuiControl, 6:, SilentUpdateCheckbox, 1
Gui, 6:Show
Return
}
IniRead, AnimationType1, Notepad\Settings.ini, Settings, AnimationType1
IniRead, AnimationType2, Notepad\Settings.ini, Settings, AnimationType2
IniRead, UseAnimation, Notepad\Settings.ini, Settings, UseAnimation
IniRead, UseNotePreview, Notepad\Settings.ini, Settings, UseNotePreview
IniRead, UseChangableAnimation, Notepad\Settings.ini, Settings, UseChangableAnimation
IniRead, AskToUpdate, Notepad\Settings.ini, Settings, AskToUpdate
IniRead, SilentUpdate, Notepad\Settings.ini, Settings, SilentUpdate
IniRead, TransparencyLevel, Notepad\Settings.ini, Settings, TransparencyLevel

GuiControl, 6:, UseNotePreviewCheckbox, %UseNotePreview%
GuiControl, 6:, UseChangableAnimationCheckbox, %UseChangableAnimation%
GuiControl, 6:, UseAnimationCheckbox, %UseAnimation%
GuiControl, 6:, AskToUpdateCheckbox, %AskToUpdate%
GuiControl, 6:, SilentUpdateCheckbox, %SilentUpdate%

if(Developer>0)
{
  GuiControl, 6:Disable, UpdateNowSettingsButton
  GuiControl, 6:Disable, FixMeButton
  GuiControl, 6:, UpdateErrorOutput, The app is in developer mode.
}

If(AnimationType2=0)
AnimationType2DDList=Default
If(AnimationType2=524288)
AnimationType2DDList=Fade
If(AnimationType2=1)
AnimationType2DDList=Left to right
If(AnimationType2=2)
AnimationType2DDList=Right to left
If(AnimationType2=4)
AnimationType2DDList=Top to bottom
If(AnimationType2=8)
AnimationType2DDList=Bottom to top
If(AnimationType2=16)
AnimationType2DDList=Centre
If(AnimationType2=5)
AnimationType2DDList=Top-left to bottom-right
If(AnimationType2=6)
AnimationType2DDList=Top-right to bottom-left
If(AnimationType2=9)
AnimationType2DDList=Bottom-left to top-right
If(AnimationType2=10)
AnimationType2DDList=Bottom-right to top-left

GuiControl, 6:ChooseString, AnimationType2DDList, %AnimationType2DDList%

If(AnimationType1=0)
AnimationType1DDList=Default
If(AnimationType1=524288)
AnimationType1DDList=Fade
If(AnimationType1=1)
AnimationType1DDList=Left to right
If(AnimationType1=2)
AnimationType1DDList=Right to left
If(AnimationType1=4)
AnimationType1DDList=Top to bottom
If(AnimationType1=8)
AnimationType1DDList=Bottom to top
If(AnimationType1=16)
AnimationType1DDList=Centre
If(AnimationType1=5)
AnimationType1DDList=Top-left to bottom-right
If(AnimationType1=6)
AnimationType1DDList=Top-right to bottom-left
If(AnimationType1=9)
AnimationType1DDList=Bottom-left to top-right
If(AnimationType1=10)
AnimationType1DDList=Bottom-right to top-left

GuiControl, 6:ChooseString, AnimationType1DDList, %AnimationType1DDList%

if(UseAnimation=0)
{
  GuiControl, 6:Disable, UseChangableAnimationCheckbox
  GuiControl, 6:Disable, AnimationType1DDList
  GuiControl, 6:Disable, AnimationType2DDList
  GuiControl, 6:Disable, AnimationType1DDLText
  GuiControl, 6:Disable, AnimationType2DDLText
}else{
  GuiControl, 6:Enable, UseChangableAnimationCheckbox
  GuiControl, 6:Enable, AnimationType1DDList
  GuiControl, 6:Enable, AnimationType2DDList
  GuiControl, 6:Enable, AnimationType1DDLText
  GuiControl, 6:Enable, AnimationType2DDLText
}
if(UseNotePreview=0)
{
  GuiControl, 6:Disable, UseAnimationCheckbox
  GuiControl, 6:Disable, UseChangableAnimationCheckbox
  GuiControl, 6:Disable, AnimationType1DDList
  GuiControl, 6:Disable, AnimationType2DDList
  GuiControl, 6:Disable, AnimationType1DDLText
  GuiControl, 6:Disable, AnimationType2DDLText
}else{
  GuiControl, 6:Enable, UseAnimationCheckbox
  GuiControl, 6:Enable, UseChangableAnimationCheckbox
  GuiControl, 6:Enable, AnimationType1DDList
  GuiControl, 6:Enable, AnimationType2DDList
  GuiControl, 6:Enable, AnimationType1DDLText
  GuiControl, 6:Enable, AnimationType2DDLText
}
Gui, 6:Show
Return


FixTheAppWarning:
MsgBox, 8484, Note - Options, Warning: The "FixMe" function deletes all data files and tries to download the main app again,`nto fix possible problems. This will erase all your data. Are you sure you want to continue?
ifMsgBox Yes
{
	FixMeError=Problems encountered:
	Progress, P0 H100, Estimating time remaining: 1.3 s, Please wait..., FixMe
	DllCall("FreeLibrary", "UInt", main_dll)
	Sleep, 500
	Loop, Notepad\*.*
	{
		FileSetAttrib, -RHSA, %A_LoopFileFullPath%
		FileDelete, %A_LoopFileFullPath%
		if ErrorLevel
			FixMeError=%FixMeError%`n%A_LoopFileFullPath%
		Progress, %A_Index%
	}
	Progress, 80, Estimating time remaining: 0.8 s
	FileRemoveDir, Notepad, 1
	if ErrorLevel
		FixMeError=%FixMeError%`nNotepad\*.*`nNotepad\
	Progress, 85
	FileSetAttrib, -RHSA, Note.ahk
	Sleep, 100
	FileDelete, Note.ahk
	Progress, 90, Estimating time remaining: 0.7 s
	if ErrorLevel
		FixMeError=%FixMeError%`nNote.ahk
	Sleep, 100
	UrlDownloadToFile, http://www.autohotkey.net/~jk7800/Note%AppVersion%.ahk, Note.ahk
	Progress, 95, Estimating time remaining: 0.6 s
	if ErrorLevel
		FixMeError=%FixMeError%`nDownloading:Note.ahk Failed
	Sleep, 500
	Progress, 100, Estimating time remaining: 0.1 s
	Progress, OFF
	if FixMeError="Problems encountered:"
	{
		msgbox, First part of fixing finished. Executing SilentFix (download of program files).
		Reload
	}
	Else
		msgbox, %FixMeError%`nCritical error! Please download the main file with an internet browser`nor close all applications, which may be using any of the program's files and press the FixMe button again.
}
Return


NotePreviewJustChanged:
Gui, 6:Submit, NoHide
if(UseNotePreviewCheckbox=0)
{
  MsgBox, 8484, Note - Options, Warning: Disabling the "Note - Preview" window makes Note`nless functional, by deleting full screen note editor,`nPicture Note editor, and to-do list. Are you sure, you want to continue?
  ifMsgBox Yes
  {
    GuiControl, Disable, UseAnimationCheckbox
    GuiControl, Disable, UseChangableAnimationCheckbox
    GuiControl, Disable, AnimationType1DDList
    GuiControl, Disable, AnimationType2DDList
    GuiControl, Disable, AnimationType1DDLText
    GuiControl, Disable, AnimationType2DDLText
  }else
    GuiControl, , UseNotePreviewCheckbox, 1
}else{
  GuiControl, Enable, UseAnimationCheckbox
  GuiControl, Enable, UseChangableAnimationCheckbox
  GuiControl, Enable, AnimationType1DDList
  GuiControl, Enable, AnimationType2DDList
  GuiControl, Enable, AnimationType1DDLText
  GuiControl, Enable, AnimationType2DDLText
}
Return


AnimationJustChanged:
Gui, 6:Submit, NoHide
if(UseAnimationCheckbox=0)
{
  GuiControl, Disable, UseChangableAnimationCheckbox
  GuiControl, Disable, AnimationType1DDList
  GuiControl, Disable, AnimationType2DDList
  GuiControl, Disable, AnimationType1DDLText
  GuiControl, Disable, AnimationType2DDLText
}else{
  GuiControl, Enable, UseChangableAnimationCheckbox
  GuiControl, Enable, AnimationType1DDList
  GuiControl, Enable, AnimationType2DDList
  GuiControl, Enable, AnimationType1DDLText
  GuiControl, Enable, AnimationType2DDLText
}
Return

SaveOptions:
Gui, 6:Submit
if(AnimationType2DDList="Default")
  AnimationType2=0
if(AnimationType2DDList="Fade")
  AnimationType2=524288
if(AnimationType2DDList="Left to right")
  AnimationType2=1
if(AnimationType2DDList="Right to left")
  AnimationType2=2
if(AnimationType2DDList="Top to bottom")
  AnimationType2=4
if(AnimationType2DDList="Bottom to top")
  AnimationType2=8
if(AnimationType2DDList="Centre")
  AnimationType2=16
if(AnimationType2DDList="Top-left to bottom-right")
  AnimationType2=5
if(AnimationType2DDList="Top-right to bottom-left")
  AnimationType2=6
if(AnimationType2DDList="Bottom-left to top-right")
  AnimationType2=9
if(AnimationType2DDList="Bottom-right to top-left")
  AnimationType2=10
if(AnimationType1DDList="Default")
  AnimationType1=0
if(AnimationType1DDList="Fade")
  AnimationType1=524288
if(AnimationType1DDList="Left to right")
  AnimationType1=1
if(AnimationType1DDList="Right to left")
  AnimationType1=2
if(AnimationType1DDList="Top to bottom")
  AnimationType1=4
if(AnimationType1DDList="Bottom to top")
  AnimationType1=8
if(AnimationType1DDList="Centre")
  AnimationType1=16
if(AnimationType1DDList="Top-left to bottom-right")
  AnimationType1=5
if(AnimationType1DDList="Top-right to bottom-left")
  AnimationType1=6
if(AnimationType1DDList="Bottom-left to top-right")
  AnimationType1=9
if(AnimationType1DDList="Bottom-right to top-left")
  AnimationType1=10

if(UseNotePreviewCheckbox<>UseNotePreview)
{
  ReloadNow=1
  msgbox, 8240, Settings changed., Note must be reloaded due to changes in the app's settings., 3
}

UseAnimation:=UseAnimationCheckbox
UseChangableAnimation:=UseChangableAnimationCheckbox
UseNotePreview:=UseNotePreviewCheckbox
AskToUpdate:=AskToUpdateCheckbox
SilentUpdate:=SilentUpdateCheckbox
TransparencyLevel:=TransparencyLevelCheckbox

IfNotExist, Notepad\Settings.ini
  ReloadNow=1

IniWrite, %AnimationType1%, Notepad\Settings.ini, Settings, AnimationType1
IniWrite, %AnimationType2%, Notepad\Settings.ini, Settings, AnimationType2
IniWrite, %UseAnimation%, Notepad\Settings.ini, Settings, UseAnimation
IniWrite, %UseNotePreview%, Notepad\Settings.ini, Settings, UseNotePreview
IniWrite, %UseChangableAnimation%, Notepad\Settings.ini, Settings, UseChangableAnimation
IniWrite, %UseNotePreview%, Notepad\Settings.ini, Settings, UseNotePreview
IniWrite, %AskToUpdate%, Notepad\Settings.ini, Settings, AskToUpdate
IniWrite, %SilentUpdate%, Notepad\Settings.ini, Settings, SilentUpdate
IniWrite, %TransparencyLevel%, Notepad\Settings.ini, Settings, TransparencyLevel

If ReloadNow=1
  Reload
Return

DiscardOptions:
Gui, 6:Hide
Return

GuiClose:
Gui, Show


TakeScreenShot(aRect = 0, sFile = "", nQuality = "")
{
	StringSplit, rt, aRect, `,, %A_Space%%A_Tab%
	nL := rt1
	nT := rt2
	nW := rt3 - rt1
	nH := rt4 - rt2
	znW := rt5
	znH := rt6
	mDC := DllCall("CreateCompatibleDC", "Uint", 0)
	bpp = 32
	pBits = ""
	NumPut(VarSetCapacity(bi, 40, 0), bi)
	NumPut(nW, bi, 4)
	NumPut(nH, bi, 8)
	NumPut(bpp, NumPut(1, bi, 12, "UShort"), 0, "Ushort")
	NumPut(0,  bi,16)
	hBM := DllCall("gdi32\CreateDIBSection", "Uint", hDC, "Uint", &bi, "Uint", 0, "UintP", pBits, "Uint", 0, "Uint", 0)
	oBM := DllCall("SelectObject", "Uint", mDC, "Uint", hBM)
	hDC := DllCall("GetDC", "Uint", 0)
	DllCall("BitBlt", "Uint", mDC, "int", 0, "int", 0, "int", nW, "int", nH, "Uint", hDC, "int", nL, "int", nT, "Uint", 0x40000000 | 0x00CC0020)
	DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)
	DllCall("SelectObject", "Uint", mDC, "Uint", oBM)
	DllCall("DeleteDC", "Uint", mDC)
	sFileTo := sFile
	nQuality := ""
	sFileFr:=hBM
	If	sFileTo  =
	{
		sFileTo := A_ScriptDir . "\screen.png"
		BlockInput, Off
		msgbox, Warning: No file has been selected! Using default filename. Errors may occur!
		BlockInput, On
	}
	SplitPath, sFileTo, , sDirTo, sExtTo, sNameTo

	If Not	hGdiPlus := DllCall("LoadLibrary", "str", "gdiplus.dll")
		Return	sFileFr = 0  ?  sFile2 := sDirTo . "\" . sNameTo . ".bmp" : ""	DllCall("GetObject", "Uint", sFileFr, "int", VarSetCapacity(oi,84,0), "Uint", &oi),	hFile:=	DllCall("CreateFile", "Uint", &sFile2, "Uint", 0x40000000, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 0, "Uint", 0),	DllCall("WriteFile", "Uint", hFile, "int64P", 0x4D42|14+40+NumGet(oi,44)<<16, "Uint", 6, "UintP", 0, "Uint", 0),	DllCall("WriteFile", "Uint", hFile, "int64P", 54<<32, "Uint", 8, "UintP", 0, "Uint", 0),	DllCall("WriteFile", "Uint", hFile, "Uint", &oi+24, "Uint", 40, "UintP", 0, "Uint", 0),	DllCall("WriteFile", "Uint", hFile, "Uint", NumGet(oi,20), "Uint", NumGet(oi,44), "UintP", 0, "Uint", 0),	DllCall("CloseHandle", "Uint", hFile)
	VarSetCapacity(si, 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", "UintP", pToken, "Uint", &si, "Uint", 0)

	If	sFileFr Is Integer
		DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Uint", sFileFr, "Uint", 0, "UintP", pImage)
	Else
	{
		sString:=sFileFr
		nSize := DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", 0, "int", 0)
		VarSetCapacity(wFileFr, nSize * 2)
		DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sString, "int", -1, "Uint", &wFileFr, "int", nSize)
		Unicode2Ansi := &wString
		DllCall("gdiplus\GdipLoadImageFromFile", "Uint", Unicode2Ansi, "UintP", pImage)

	}

	DllCall("gdiplus\GdipGetImageEncodersSize", "UintP", nCount, "UintP", nSize)
	VarSetCapacity(ci,nSize,0)
	DllCall("gdiplus\GdipGetImageEncoders", "Uint", nCount, "Uint", nSize, "Uint", &ci)
	Loop, %	nCount
	{
		nSize := DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", NumGet(ci,76*(A_Index-1)+44), "int", -1, "Uint", 0, "int",  0, "Uint", 0, "Uint", 0)
		VarSetCapacity(sString, nSize)
		DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "Uint", NumGet(ci,76*(A_Index-1)+44), "int", -1, "str", sString, "int", nSize, "Uint", 0, "Uint", 0)
		If	InStr(sString, "." . sExtTo)
		{
			pCodec := &ci+76*(A_Index-1)
			Break
		}
	}
	If	InStr(".JPG.JPEG.JPE.JFIF", "." . sExtTo) && nQuality<>"" && pImage && pCodec
	{
	DllCall("gdiplus\GdipGetEncoderParameterListSize", "Uint", pImage, "Uint", pCodec, "UintP", nSize)
	VarSetCapacity(pi,nSize,0)
	DllCall("gdiplus\GdipGetEncoderParameterList", "Uint", pImage, "Uint", pCodec, "Uint", nSize, "Uint", π)
	Loop, %	NumGet(pi)
		If	NumGet(pi,28*(A_Index-1)+20)=1 && NumGet(pi,28*(A_Index-1)+24)=6
		{
			pParam := π+28*(A_Index-1)
			NumPut(nQuality,NumGet(NumPut(4,NumPut(1,pParam+0)+20)))
			Break
		}
	}
	nSize := DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sFileTo, "int", -1, "Uint", 0, "int", 0)
	VarSetCapacity(wFileTo, nSize * 2)
	DllCall("MultiByteToWideChar", "Uint", 0, "Uint", 0, "Uint", &sFileTo, "int", -1, "Uint", &wFileTo, "int", nSize)
	If	pImage
		pCodec	? DllCall("gdiplus\GdipSaveImageToFile", "Uint", pImage, "Uint", &wFileTo, "Uint", pCodec, "Uint", pParam) : DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Uint", pImage, "UintP", hBitmap, "Uint", 0) . DllCall("GetObject", "Uint", hBitmap, "int", VarSetCapacity(oi,84,0), "Uint", &oi),	hDIB :=	DllCall("GlobalAlloc", "Uint", 2, "Uint", 40+NumGet(oi,44))	pDIB :=	DllCall("GlobalLock", "Uint", hDIB),	DllCall("RtlMoveMemory", "Uint", pDIB, "Uint", &oi+24, "Uint", 40),	DllCall("RtlMoveMemory", "Uint", pDIB+40, "Uint", NumGet(oi,20), "Uint", NumGet(oi,44)),	DllCall("GlobalUnlock", "Uint", hDIB),	DllCall("DeleteObject", "Uint", hBitmap),	DllCall("OpenClipboard", "Uint", 0),	DllCall("EmptyClipboard"),	DllCall("SetClipboardData", "Uint", 8, "Uint", hDIB),	DllCall("CloseClipboard"), DllCall("gdiplus\GdipDisposeImage", "Uint", pImage)
	DllCall("DeleteObject", "Uint", hBM)
	DllCall("gdiplus\GdiplusShutdown" , "Uint", pToken)
	DllCall("FreeLibrary", "Uint", hGdiPlus)
}