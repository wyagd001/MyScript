/*
- RHCP - https://autohotkey.com/board/topic/41467-make-ahk-drop-files-into-other-applications/page-2

Example:
DropFiles( "C:\SomeName.txt", "ahk_class Notepad" )

; Definition
struct DROPFILES
{
    DWORD pFiles;    // offset of file list
    POINT pt;        // drop point (client coords)
    BOOL fNC;        // is it on NonClient area and pt is in screen coords
    BOOL fWide;      // wide character flag
};
*/

DropFiles( FileList, wTitle="", Ctrl="", X=0, Y=0, NCA=0 ) 
{
 characterSize := A_IsUnicode ? 2 : 1
 StringReplace, FileList, FileList, `r`n, `n , All
 VarSetCapacity( DROPFILES,20,32 ),  DROPFILES.=FileList "`n`n",  nSize:=StrLen(DROPFILES)*characterSize
 StringReplace, DROPFILES,DROPFILES, `n,`n, UseErrorLevel
 Loop %ErrorLevel%
	NumPut( 0, DROPFILES, InStr(DROPFILES,"`n",0,0)*characterSize - characterSize, A_IsUnicode ? "Short" : "Char" )

 pDP := &DROPFILES
 NumPut(20, pDP+0, 0, "UInt")
 NumPut(X, pDP+4, 0, "UInt")
 NumPut(Y, pDP+8, 0, "UInt")
 NumPut(NCA, pDP+12, 0, "UInt")
 NumPut(A_IsUnicode ? 1 : 0, pDP+16, 0, "UInt")
 hDrop := DllCall( "GlobalAlloc", UInt,0x42, UPtr, nSize, "UPtr" )
 pData := DllCall( "GlobalLock", Ptr, hDrop)
 DllCall( "RtlMoveMemory", UInt,pData, UInt,pDP, UInt, nSize )
 DllCall( "GlobalUnlock", UInt,hDrop )
 PostMessage, 0x233, hDrop, 0, %Ctrl%, %wTitle% ; WM_DROPFILES := 0x233
}

HDrop(fnames,x=0,y=0)    
{
	characterSize := A_IsUnicode ? 2 : 1
	fns := RegExReplace(fnames,"\n$")
	fns := RegExReplace(fns,"^\n")
	hDrop := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", 20+(StrLen(fns)*characterSize)+characterSize*2)
	p:=DllCall("GlobalLock", "UInt", hDrop)
	NumPut(20, p+0, 0, "UInt")  ;offset
	NumPut(x,  p+4, 0, "UInt")  ;pt.x
	NumPut(y,  p+8, 0, "UInt")  ;pt.y
	NumPut(0,  p+12, 0, "UInt") ;fNC
	NumPut(A_IsUnicode ? 1 : 0,  p+16, 0, "UInt") ;fWide
	p2:=p+20
	Loop, Parse, fns, `n, `r
	{
		DllCall("RtlMoveMemory", "UInt", p2, "Str", A_LoopField, "UInt", StrLen(A_LoopField)*characterSize)
		p2+=StrLen(A_LoopField)*characterSize + characterSize
	}
	DllCall("GlobalUnlock", "UInt", hDrop)
	Return hDrop
}