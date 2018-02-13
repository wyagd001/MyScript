#NoTrayIcon
IniRead, DefaultBrowser, %A_ScriptDir%\smartchooserbrowser.ini, DefaultBrowser, DefaultBrowser
IfNotExist,%DefaultBrowser%
{
DefaultBrowser:="iexplore.exe"
}
IniRead, url, %A_ScriptDir%\smartchooserbrowser.ini, DefaultUrl, url
IniRead, BrowserAppList, %A_ScriptDir%\smartchooserbrowser.ini, BrowserApp, BrowserAppList

if 0 != 1 ;Check %0% to see how many parameters were passed in
{
    msgbox ERROR: There are %0% parameters. There should be 1 parameter exactly.
}
else
{
    urladd = %1%  ;Fetch the contents of the command line argument
    IfNotInString,urladd,http
     urladd:="http://" . urladd
    Loop, parse, url, |
    {
    IfInString, urladd, %A_LoopField%
    {
    run %DefaultBrowser% "%urladd%"
    return
    }
    }

StringSplit,BApp,BrowserAppList,|
LoopN:=1
br:=0
Loop,%BApp0%
{
BCtrApp:=BApp%LoopN%
LoopN++
Process,Exist,%BCtrApp%
If (errorlevel<>0)
{
    NewPID = %ErrorLevel%
   If(BCtrApp="chrome.exe" or BCtrApp="firefox.exe")
   {
   pid:= GetCommandLine( NewPID )
  ;FileAppend ,%pid%`n,%A_desktop%\123.txt
   run,%pid% "%urladd%"
    br:=1
    return
   }
   else
   {
    pid:=GetModuleFileNameEx( NewPID )
    run,%pid% "%urladd%"
    br:=1
    return
    }
}
if br=0
run %DefaultBrowser% "%urladd%"
return
}
}
ExitApp


GetModuleFileNameEx( p_pid )
{
   if A_OSVersion in WIN_95,WIN_98,WIN_ME,WIN_XP
   {
      MsgBox, Windows 版本 (%A_OSVersion%) 不支持。Win 7 及以上系统才能正常使用。
      return
   }

   h_process := DllCall( "OpenProcess", "uint", 0x10|0x400, "int", false, "uint", p_pid )
   if ( ErrorLevel or h_process = 0 )
      return

   name_size = 255
   VarSetCapacity( name, name_size )

   result := DllCall( "psapi.dll\GetModuleFileNameExA", "uint", h_process, "uint", 0, "str", name, "uint", name_size )

   DllCall( "CloseHandle", h_process )

   return, name
}

GetCommandLine( PID ) { ;  by Sean          www.autohotkey.com/forum/viewtopic.php?t=16575
 Static pFunc
 If ! ( hProcess := DllCall( "OpenProcess", UInt,0x043A, Int,0, UInt, PID ) )
        Return
 If pFunc=
    pFunc := DllCall( "GetProcAddress", UInt
           , DllCall( "GetModuleHandle", Str,"kernel32.dll" ), Str,"GetCommandLineA" )
 hThrd := DllCall( "CreateRemoteThread", UInt,hProcess, UInt,0, UInt,0, UInt,pFunc, UInt,0
        , UInt,0, UInt,0 ),  DllCall( "WaitForSingleObject", UInt,hThrd, UInt,0xFFFFFFFF )
 DllCall( "GetExitCodeThread", UInt,hThrd, UIntP,pcl ), VarSetCapacity( sCmdLine,512 )
 DllCall( "ReadProcessMemory", UInt,hProcess, UInt,pcl, Str,sCmdLine, UInt,512, UInt,0 )
 DllCall( "CloseHandle", UInt,hThrd ), DllCall( "CloseHandle", UInt,hProcess )
Return sCmdLine
}