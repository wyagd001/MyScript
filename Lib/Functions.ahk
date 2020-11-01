IsStringFunc(str:="")
{
	strfunc:=StrSplit(str,"(")
	If IsFunc(strfunc[1])
	return 1
	else
	return 0
}

RunStringFunc(str:="")
{
	strfunc:=StrSplit(str, "(", ")")
	tempfunc:=strfunc[1]
	params:=StrSplit(strfunc[2], ",", " `t")
	if (params.MaxIndex() = "")
	{
		%tempfunc%()
	return
	}
	else if (params.MaxIndex() = 1)
	{
		o := params[1]
		if !InStr(o,"""")
			Transform,o1,Deref,% %o%
		%tempfunc%(o1?o1:o)
	return
	}
	else if (params.MaxIndex() = 2)
	{
		o := params[1]
		p := params[2]
		if !InStr(o,"""")
			Transform,o1,Deref,% %o%
		if !InStr(p,"""")
			Transform,p1,Deref,% %p%

		%tempfunc%(o1?o1:InStr(o,"""")=1?Trim(o, """"):o, p1?p1:InStr(p,"""")=1?Trim(p, """"):p)
	return
	}
	else if (params.MaxIndex() = 3)
	{
		o := params[1]
		p := params[2]
		q := params[3]
		if !InStr(o,"""")
			Transform,o1,Deref,% %o%
		if !InStr(p,"""")
			Transform,p1,Deref,% %p%
		if !InStr(q,"""")
			Transform,q1,Deref,% %q%

		%tempfunc%(o1?o1:InStr(o,"""")=1?Trim(o, """"):o, p1?p1:InStr(p,"""")=1?Trim(p, """"):p, q1?q1:InStr(q,"""")=1?Trim(q, """"):q)
	return
	}
	else (params.MaxIndex() = 4)
	{
		o := params[1]
		p := params[2]
		q := params[3]
		r := params[3]
		if !InStr(o,"""")
			Transform,o1,Deref,% %o%
		if !InStr(p,"""")
			Transform,p1,Deref,% %p%
		if !InStr(q,"""")
			Transform,q1,Deref,% %q%
		if !InStr(r,"""")
			Transform,r1,Deref,% %r%
		%tempfunc%(o1?o1:InStr(o,"""")=1?Trim(o, """"):o, p1?p1:InStr(p,"""")=1?Trim(p, """"):p, q1?q1:InStr(q,"""")=1?Trim(q, """"):q, r1?r1:InStr(r,"""")=1?Trim(r, """"):r)
	return
	}
}

; 来源帮助文件中的示例
RunScript(script, WaitResult:="false")
{
	static test_ahk := A_AhkPath,
	shell := ComObjCreate("WScript.Shell")
	tempworkdir:= A_WorkingDir
	SetWorkingDir %A_ScriptDir%
	exec := shell.Exec(chr(34) test_ahk chr(34) " /ErrorStdOut *")
	exec.StdIn.Write(script)
	exec.StdIn.Close()
	SetWorkingDir %tempworkdir%
	if WaitResult
		return exec.StdOut.ReadAll()
	else 
return
}

RunNamedPipe(pipe_code:="", pipe_name:="")
{
		; https://autohotkey.com/board/topic/23575-how-to-run-dynamic-script-through-a-pipe/
		ptr := A_PtrSize ? "Ptr" : "UInt"
		char_size := A_IsUnicode ? 2 : 1
		pipe_name:=pipe_name?pipe_name:"运行Ahk命令"
; Before reading the file, AutoHotkey calls GetFileAttributes(). This causes
; the pipe to close, so we must create a second pipe for the actual file contents.
; Open them both before starting AutoHotkey, or the second attempt to open the
; "file" will be very likely to fail. The first created instance of the pipe
; seems to reliably be "opened" first. Otherwise, WriteFile would fail.
		pipe_ga := CreateNamedPipe(pipe_name, 2)
		pipe := CreateNamedPipe(pipe_name, 2)
		If (pipe=-1 or pipe_ga=-1) {
			MsgBox CreateNamedPipe failed.
			Return
		}

		Run, "%A_AhkPath%" "\\.\pipe\%pipe_name%"

; Wait for AutoHotkey to connect to pipe_ga via GetFileAttributes().
		DllCall("ConnectNamedPipe",ptr,pipe_ga,ptr,0)
; This pipe is not needed, so close it now. (The pipe instance will not be fully
; destroyed until AutoHotkey also closes its handle.)
		DllCall("CloseHandle",ptr,pipe_ga)
; Wait for AutoHotkey to connect to open the "file".
		DllCall("ConnectNamedPipe",ptr,pipe,ptr,0)

; AutoHotkey reads the first 3 bytes to check for the UTF-8 BOM "???". If it is
; NOT present, AutoHotkey then attempts to "rewind", thus breaking the pipe.
		pipe_code := (A_IsUnicode ? chr(0xfeff) : chr(239) chr(187) chr(191)) pipe_code

		If !DllCall("WriteFile",ptr,pipe,"str",pipe_code,"uint",(StrLen(pipe_code)+1)*char_size,"uint*",0,ptr,0)
			MsgBox WriteFile failed: %ErrorLevel%/%A_LastError%
		DllCall("CloseHandle",ptr,pipe)
return
}

CreateNamedPipe(Name, OpenMode=3, PipeMode=0, MaxInstances=255)
{
	ptr := A_PtrSize ? "Ptr" : "UInt"
Return DllCall("CreateNamedPipe","str","\\.\pipe\" Name,"uint",OpenMode
        ,"uint",PipeMode,"uint",MaxInstances,"uint",0,"uint",0,ptr,0,ptr,0)
}