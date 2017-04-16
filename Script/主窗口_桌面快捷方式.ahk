;桌面快捷方式
Desktoplnk:
kShortcutDir = %A_desktop%
tempworkdir:=A_WorkingDir
SetWorkingDir, %kShortcutDir%
kShortcutExt = lnk
Loop, %A_WorkingDir%\*.%kShortcutExt%,,   ; for each shortcut in the directory, add a menu item for it
{
    SplitPath, A_LoopFileName, , , , menuName,      ; remove extension
    Menu, mymenu, Add, %menuName%, RunThisMenuItem
}

Menu,mymenu, add

Loop, %A_desktop%\隐藏\*.lnk
   {
        SplitPath, A_LoopFileName, , , , menuName,      ; remove extension
        Menu, 隐藏, add, %menuName%, RunThisMenuItem2  ; 创建子菜单项。
    }
Menu,mymenu, add, 隐藏, :隐藏  ; 创建父菜单项。

Menu,mymenu,show
Menu,mymenu,deleteall
Menu, 隐藏,deleteall
   SetWorkingDir,%tempworkdir%
   ;tooltip, % A_WorkingDir
return

RunThisMenuItem2:
RunFileName = %A_desktop%\隐藏\%A_ThisMenuItem%.lnk
run, %RunFileName%
Return    ;重载




