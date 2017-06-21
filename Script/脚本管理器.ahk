;脚本启动时会打开运行"脚本管理器"目录中文件名开头没有"!"的所有脚本
tsk_openAll:
tempworkdir:=A_WorkingDir
SetWorkingDir %ScriptManager_Path%
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If  scripts%A_index%1 = 0    ;没打开
    {
        ifinstring, thisScript, !
	    continue
        IfWinNotExist %thisScript% - AutoHotkey    ; 没有打开
            Run,"%A_AhkPath%" "%ScriptManager_Path%\%thisScript%"

        scripts%A_index%1 = 1

        StringRePlace menuName, thisScript, .ahk
        Menu scripts_unclose, add, %menuName%, tsk_close
        Menu scripts_unopen, delete, %menuName%
    }
}
SetWorkingDir,%tempworkdir%
Return

tsk_open:
tempworkdir:=A_WorkingDir
SetWorkingDir %ScriptManager_Path%
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If thisScript = %A_thismenuitem%.ahk  ; match found.
    {
        IfWinNotExist %thisScript% - AutoHotkey    ; 没有打开
            Run,"%A_AhkPath%" "%ScriptManager_Path%\%thisScript%"

        scripts%A_index%1 := 1

        Menu scripts_unclose, add, %A_thismenuitem%, tsk_close
        Menu scripts_unopen, delete, %A_thismenuitem%
        Break
    }
}
SetWorkingDir,%tempworkdir%
Return

tsk_close:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If thisScript = %A_thismenuitem%.ahk  ; match found.
    {
        WinClose %thisScript% - AutoHotkey
        scripts%A_index%1 := 0

        Menu scripts_unopen, add, %A_thismenuitem%, tsk_open
        Menu scripts_unclose, delete, %A_thismenuitem%
        Break
    }
}
Return

tsk_closeAll:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If scripts%A_index%1 = 1  ; 已打开
    {
        WinClose %thisScript% - AutoHotkey
        scripts%A_index%1 = 0

        StringRePlace menuName, thisScript, .ahk
        Menu scripts_unopen, add, %menuName%, tsk_open
        Menu scripts_unclose, delete, %menuName%
    }
}
Return

tsk_edit:
Run, notepad %ScriptManager_Path%\%A_thismenuitem%.ahk
Return

tsk_reload:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If thisScript = %A_thismenuitem%.ahk  ; match found.
    {
        WinClose %thisScript% - AutoHotkey
        Run %ScriptManager_Path%\%thisScript%
        Break
    }
}
Return