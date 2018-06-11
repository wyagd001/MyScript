¼ì²â:
activeplayer:=activeplayer(DefaultPlayer)
If activeplayer
{
    Image = %A_ScriptDir%\pic\MusicPlayer\h_%activeplayer%.bmp
If (activeplayer="Foobar2000")
          {
              If WinExist("foo_httpcontrol")
              GuiControl,Enable,fhc
          }

}
Else
{
Image = %A_ScriptDir%\pic\MusicPlayer\%DefaultPlayer%.bmp
GuiControl,Disable,fhc
}

SoundGet,vol_Master
SoundGet,master_mute,,mute
Guicontrol,,VSlider,%vol_Master%

If(master_mute="on")
;color = red
volimage = %A_ScriptDir%\pic\m_vol.ico
Else
;color = green
volimage = %A_ScriptDir%\pic\vol.ico

Refresh:
   If (Image != OldImage)
   {
      GuiControl, , Picture, %Image%
      OldImage := Image
   }
   If (volimage != Oldvolimage)
{
  ; MsgBox,%volimage% %oldvolimage%
GuiControl, , vol, %volimage%
Oldvolimage := volimage
}
Return

OpenAudioPlayer:
;±à¼­½Å±¾Ê±£¬ÅÐ¶Ï»á³ö´í
DetectHiddenWindows On
SetTitleMatchMode 2
If (DefaultPlayer="AhkPlayer")
{
 If WinExist(" - AhkPlayer")
 Send,!{F7}
 Else Run,% %DefaultPlayer%
}
Else Run,% %DefaultPlayer%  ;,,UseErrorLevel
;gosub ¼ì²â
Return

foo_httpcontrol_click:
Run %A_ScriptDir%\Plugins\foo_httpcontrol.ahk
Return

GB1_down:
Return
GB2_down:
Return
GB3_down:
Return
GB4_down:
Return

activeplayer(DefaultPlayer){
DetectHiddenWindows On
SetTitleMatchMode 2
if ProcessExist(DefaultPlayer ".exe")
return DefaultPlayer
else If WinExist(" - AhkPlayer")
return "AhkPlayer"
else if ProcessExist("foobar2000.exe")
return "foobar2000"
else if ProcessExist("iTunes.exe")
return "iTunes"
else if ProcessExist("Wmplayer.exe")
return "Wmplayer"
else if ProcessExist("TTPlayer.exe")
return "TTPlayer"
else if ProcessExist("Winamp.exe")
return "Winamp"
}

ProcessExist(Name){
	Process,Exist,%Name%
	return Errorlevel
}

GB1_down_up:
;prev:
activeplayer:=activeplayer(DefaultPlayer)
If (activeplayer="AhkPlayer")
Send,^+{F3}
If (activeplayer="foobar2000")
Run %foobar2000% /prev,,UseErrorLevel
If (activeplayer="wmplayer")
postMessage 0x111,18810,,,ahk_class WMPlayerApp
If (activeplayer="Winamp")
postMessage 0x111,40044 ,,,ahk_class Winamp v1.x
If (activeplayer="ttplayer")
postMessage 0x111,0x7d05 ,,,ahk_class TTPlayer_PlayerWnd
If (activeplayer="itunes")
ControlSend, ahk_parent, ^{left}, iTunes ahk_class iTunes
Return


GB2_down_up:
;pause:
activeplayer:=activeplayer(DefaultPlayer)
If (activeplayer="AhkPlayer")
Send,^+P
If (activeplayer="foobar2000")
Run %foobar2000% /playpause,,UseErrorLevel
If (activeplayer="wmplayer")
SendMessage 0x111,18808, , ,ahk_class WMPlayerApp
If (activeplayer="Winamp")
postMessage 0x111,40046 ,,,ahk_class Winamp v1.x
If (activeplayer="ttplayer")
postMessage 0x111,0x7d00 ,,,ahk_class TTPlayer_PlayerWnd
If (activeplayer="itunes")
ControlSend, ahk_parent, {space}, iTunes ahk_class iTunes
Return

GB3_down_up:
;next:
activeplayer:=activeplayer(DefaultPlayer)
If (activeplayer="AhkPlayer")
Send,^+{F5}
If (activeplayer="foobar2000")
Run %foobar2000% /next,,UseErrorLevel
If (activeplayer="wmplayer")
SendMessage 0x111,18811, , ,ahk_class WMPlayerApp
If (activeplayer="Winamp")
postMessage 0x111,40048 ,,,ahk_class Winamp v1.x
If (activeplayer="ttplayer")
postMessage 0x111,0x7d06,,,ahk_class TTPlayer_PlayerWnd
If (activeplayer="itunes")
ControlSend, ahk_parent, ^{right}, iTunes ahk_class iTunes
Return

GB4_down_up:
;close:
activeplayer:=activeplayer(DefaultPlayer)
If (activeplayer="AhkPlayer")
Send,^+E
If (activeplayer="foobar2000")
Run %foobar2000% /quit,,UseErrorLevel
If (activeplayer="wmplayer")
SendMessage 0x111,57665, , ,ahk_class WMPlayerApp
If (activeplayer="Winamp")
postMessage 0x111,40001 ,,,ahk_class Winamp v1.x
If (activeplayer="ttplayer")
postMessage 0x0010,0 ,,,ahk_class TTPlayer_PlayerWnd
If (activeplayer="itunes")
Process,Close,itunes.exe
gosub ¼ì²â
Return

VolumeC:
Gui, Submit, NoHide
SoundSet,%VSlider%,master
Return

mute:
Send {Volume_Mute}
gosub ¼ì²â
Return

DPlayer:
If(A_ThisMenuItem=DefaultPlayer)
Return
menu,audioplayer,Check,%A_ThisMenuItem%
menu,audioplayer,unCheck,%DefaultPlayer%
DefaultPlayer := A_ThisMenuItem
Gosub,OpenAudioPlayer
Gosub,¼ì²â
IniWrite,%A_ThisMenuItem%, %run_iniFile%,¹Ì¶¨µÄ³ÌÐò, DefaultPlayer
Return