;×ÀÃæ¿ì½Ý·½Ê½
Desktoplnk:
kShortcutDir = %A_desktop%
kShortcutExt = lnk
Loop, %A_desktop%\*.%kShortcutExt%,,   ; for each shortcut in the directory, add a menu item for it
{
    SplitPath, A_LoopFilePath, , , , menuName,      ; remove extension
    Menu, mymenu, Add, %menuName%, RunThisMenuItem333
    FileGetShortcut, %A_LoopFilePath%, OutItem, , , , OutIcon, OutIconNum
			try{
				if(OutIcon){
					Menu,mymenu,Icon,%menuName%,%OutIcon%,%OutIconNum%
				}else{
					Menu,mymenu,Icon,%menuName%,%OutItem%
				}
			} catch e {
				Menu,mymenu,Icon,%menuName%,shell32.dll,1
			}
}

If Fileexist(A_desktop "\Òþ²Ø")
{
Menu,mymenu, add
Loop, %A_desktop%\Òþ²Ø\*.lnk
   {
        SplitPath, A_LoopFilePath, , , , menuName,      ; remove extension
        Menu, Òþ²Ø, add, %menuName%, RunThisMenuItem2  ; ´´½¨×Ó²Ëµ¥Ïî¡£
    FileGetShortcut, %A_LoopFilePath%, OutItem, , , , OutIcon, OutIconNum
			try{
				if(OutIcon){
					Menu,Òþ²Ø,Icon,%menuName%,%OutIcon%,%OutIconNum%
				}else{
					Menu,Òþ²Ø,Icon,%menuName%,%OutItem%
				}
			} catch e {
				Menu,Òþ²Ø,Icon,%menuName%,shell32.dll,1
			}
    }
Menu,mymenu, add, Òþ²Ø, :Òþ²Ø  ; ´´½¨¸¸²Ëµ¥Ïî¡£
}

Menu,mymenu,show
Menu,mymenu,deleteall
If Fileexist(A_desktop "\Òþ²Ø")
	Menu, Òþ²Ø,deleteall
return

RunThisMenuItem333:
Run %kShortcutDir%\%A_ThisMenuItem%.lnk
Return

RunThisMenuItem2:
RunFileName = %A_desktop%\Òþ²Ø\%A_ThisMenuItem%.lnk
run, %RunFileName%
Return    ;ÖØÔØ