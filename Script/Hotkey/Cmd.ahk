;CMD中右键复制，右键粘贴
命令提示符:
CurrentFolder:=GetCurrentFolder()
if(CurrentFolder)
Run "cmd.exe", %CurrentFolder%
else
	Run "cmd.exe", C:\
return

#ifWinActive,ahk_class ConsoleWindowClass
^v::
Coordmode,Mouse,Relative
MouseGetPos, MouseX, MouseY
Click right 40,40
sleep,50
MouseMove MouseX,MouseY
return

!F4::
WinClose, A
return
#ifWinActive

;___________________________________________
;______Easy Command Prompt  - Rajat_________

; Type '/' in the address bar of explorer window and type
; a DOS command to run it hidden.

; And to run it visibly and keep the command prompt
; window after that command, just use '//' instead of '/'

;----------地址栏运行命令提示符  /不显示cmd窗口 //显示cmd窗口----------

~/::
   do = n
   ControlGetFocus, ctl, A
   IfWinActive, ahk_class CabinetWClass,, IfEqual, ctl, Edit1, setenv, do, y
   IfWinActive, ahk_class ExploreWClass,, IfEqual, ctl, Edit1, setenv, do, y
   IfEqual, do, n, Return

   WinGetActiveTitle, pth
	Hotkey, Enter, Prompt, On
Return

Prompt:
   Hotkey, Enter, Off
   do = n
   ControlGetFocus, ctl, A
   IfWinActive, ahk_class CabinetWClass,, IfEqual, ctl, Edit1, setenv, do, y
   IfWinActive, ahk_class ExploreWClass,, IfEqual, ctl, Edit1, setenv, do, y
   IfEqual, do, n
   {
      Send, {Enter}
      Return
   }
   ControlGetText, cmd, Edit1, A
   StringLeft, check, cmd, 2
   IfEqual, check, //
   {
      StringTrimLeft, cmd, cmd, 2
      run, %comspec% /k %cmd%, %pth%
   }

   IfNotEqual, check, //
   {
      StringTrimLeft, cmd, cmd, 1
      run, %comspec% /c %cmd%, %pth%, hide
   }
   ControlSetText, Edit1, %pth%, %pth%
Return