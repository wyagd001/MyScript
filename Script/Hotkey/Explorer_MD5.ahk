;!M::
文件MD5:
cando_MD5:
  Gui,2:Default
;IfWinActive,ahk_Group ccc
  IfWinExist,MD5验证
  {
    Md5FilePath2:=GetSelectedFiles()
    if (Md5FilePath2 = Md5FilePath)
      Return
    GuiControl,enable,CRC32_2
    GuiControl,enable,del2
    GuiControl,, CRC32_2,CRC32
    GuiControl,, Md5FilePath2,%Md5FilePath2%
    if md5type=1
    {
      If A_IsUnicode
      {
        StrPutVar(Md5FilePath2,Md5FilePath2_2,"cp0")
        VarSetCapacity(md5sum2, 32)
        DllCall(A_ScriptDir "\MD5Lib.dll\hexMD5", "str", md5sum2, "str", Md5FilePath2_2)
        Ansi2Unicode(md5sum2_2,md5sum2,936)
VarSetCapacity(md5sum2_2, -1)
        GuiControl,, hash2, % md5sum2_2
      }
      Else
      {
        VarSetCapacity(md5sum, 32)
        DllCall(A_ScriptDir "\MD5Lib.dll\hexMD5", "str", md5sum, "str", Md5FilePath2)
        GuiControl,, hash2, % md5sum
      }
    }
    Else
      GuiControl,, hash2, % MD5_File(Md5FilePath2)

    WinActivate,MD5验证
  }
  Else
  {
    Md5FilePath:=GetSelectedFiles()
    if (Md5FilePath = "")
      Return
    Gui, add, text,x5 ,文件1
    Gui, Add, edit, x+10 VMd5FilePath readonly w350,%Md5FilePath%
    Gui, add, edit,  y+7  h20 w350 Vhash readonly cblue,
    Gui, Add, Button,x+5 w65 h20 gdelfile,删除文件1
		Gui, add, text,  yp-25 w60 cgreen vCRC32 gCRC32,CRC32


		Gui, add, text,x5 ,文件2
		Gui, Add, edit, x+10 VMd5FilePath2 w350 readonly,
		Gui, add, edit, y+7  h20 w350 Vhash2 readonly gTrueorFalse cblue,
		Gui, Add, Button,x+5 w65 h20 vdel2 gdelfile,删除文件2
		Gui, add, text, yp-25 w60 cgreen vCRC32_2 gCRC32,CRC32

		Gui, add, text,x5 ,两文件是否相同：
		Gui, add, text,x+1 vtof w30,

   GuiControl,disable,CRC32_2
   GuiControl,disable,del2

		if md5type=1
		{
			If A_IsUnicode
			{
				StrPutVar(Md5FilePath,Md5FilePath_1,"cp0")
				VarSetCapacity(md5sum, 32)
				DllCall(A_ScriptDir "\MD5Lib.dll\hexMD5", "str", md5sum, "str", Md5FilePath_1)
				Ansi2Unicode(md5sum_1,md5sum,936)
VarSetCapacity(md5sum_1, -1)
				GuiControl,, hash, % md5sum_1
			}
			Else
			{
				VarSetCapacity(md5sum, 32)
				DllCall(A_ScriptDir "\MD5Lib.dll\hexMD5", "str", md5sum, "str", Md5FilePath)
				GuiControl,, hash, % md5sum
			}
		}
		Else
			GuiControl,, hash, % MD5_File(Md5FilePath)

		Gui, Show, ,MD5验证
	}

	Gosub TrueorFalse
Return

2GuiClose:
2GuiEscape:
Gui,Destroy
Return

TrueorFalse:
GuiControlGet,hash,,hash
GuiControlGet,hash2,,hash2
if(hash=hash2)
{
Gui, Font,  cgreen bold
GuiControl,Font, tof
GuiControl, , tof,是
}
Else
{
Gui, Font,  cred bold
GuiControl,Font, tof
GuiControl, , tof,否
}
Return


2GuiDropFiles:
Loop, parse, A_GuiEvent, `n
{

FileGetAttrib, Attributes,%A_LoopField%
IfEqual A_guicontrol ,Md5FilePath
   {
   IfInString, Attributes, D
     return  ; exit if it is folder
   GuiControl,, %A_guicontrol%, %A_LoopField%  ; to asign filename to a control
   if md5type=1
{
If A_IsUnicode
      {
        StrPutVar(Md5FilePath,Md5FilePath_1,"cp0")
        VarSetCapacity(md5sum, 32)
        DllCall(A_ScriptDir "\MD5Lib.dll\hexMD5", "str", md5sum, "str", Md5FilePath_1)
        Ansi2Unicode(md5sum_1,md5sum,936)
VarSetCapacity(md5sum_1, -1)
        GuiControl,, hash, % md5sum_1
      }
      Else
      {
        VarSetCapacity(md5sum, 32)
        DllCall(A_ScriptDir "\MD5Lib.dll\hexMD5", "str", md5sum, "str", Md5FilePath)
        GuiControl,, hash, % md5sum
      }
}
Else
   GuiControl,, hash, % MD5_File(A_LoopField)
  }
IfEqual A_guicontrol ,Md5FilePath2
   {
   IfInString, Attributes, D
     return  ; exit if it is folder
   GuiControl,, %A_guicontrol%, %A_LoopField%  ; to asign filename to a control
      if md5type=1
{
      If A_IsUnicode
      {
        StrPutVar(Md5FilePath2,Md5FilePath2_2,"cp0")
        VarSetCapacity(md5sum2, 32)
        DllCall(A_ScriptDir "\MD5Lib.dll\hexMD5", "str", md5sum2, "str", Md5FilePath2_2)
        Ansi2Unicode(md5sum2_2,md5sum2,936)
VarSetCapacity(md5sum2_2, -1)
        GuiControl,, hash2, % md5sum2_2
      }
      Else
      {
        VarSetCapacity(md5sum, 32)
        DllCall(A_ScriptDir "\MD5Lib.dll\hexMD5", "str", md5sum, "str", Md5FilePath2)
        GuiControl,, hash2, % md5sum
      }
}
Else
   GuiControl,, hash2, % MD5_File(A_LoopField)
   }
}

Gosub TrueorFalse
return

delfile:
GuiControlGet,whichbutton, Focus
if whichbutton=Button1
  delfile=Md5FilePath
else 
  delfile=Md5FilePath2
GuiControlGet,Md5FilePath,,%delfile%
MsgBox,4,删除提示,确定要把下面的文件放入回收站吗？`n`n%Md5FilePath%
IfMsgBox Yes
FileRecycle,%Md5FilePath%
return

/*
;删除文件按钮函数统一为一个
delfile1:
GuiControlGet,Md5FilePath
MsgBox,4,删除提示,确实要把此文件放入回收站吗？`n`n%Md5FilePath%
IfMsgBox Yes
FileRecycle,%Md5FilePath%
return

delfile2:
GuiControlGet,Md5FilePath2
MsgBox,4,删除提示,确实要把此文件放入回收站吗？`n`n%Md5FilePath2%
IfMsgBox Yes
FileRecycle,%Md5FilePath2%
return
*/

CRC32:
if A_GuiControl =CRC32
 {
  CRCfile=Md5FilePath
  whichstatic=static2 
}
else 
{
  CRCfile=Md5FilePath2
  whichstatic=static4
}
Gui, Font,  cblue bold
GuiControl,Font, %A_GuiControl%
GuiControlGet,Md5FilePath,,%CRCfile%
GuiControl,, %A_GuiControl% , % FileCRC32(Md5FilePath)
ControlGetText,CRC32,%whichstatic% 
Clipboard:=CRC32
Return

/*
;两个 CRC32 函数统一为一个
CRC32:
Gui, Font,  cblue bold
GuiControl,Font, CRC32
GuiControlGet,Md5FilePath
GuiControl,, CRC32, % FileCRC32(Md5FilePath)
ControlGetText,CRC32,static2
Clipboard:=CRC32
Return


CRC32_2:
Gui, Font,  cblue bold
GuiControl,Font, CRC32_2
GuiControlGet,Md5FilePath2
GuiControl,, CRC32_2, % FileCRC32(Md5FilePath2)
ControlGetText,CRC32_2,static4
Clipboard:=CRC32_2
Return
*/

; ************  MD5 hashing functions by Laszlo  *******************

MD5_File( sFile="", cSz=4 ) { ; www.autohotkey.com/forum/viewtopic.php?p=275910#275910
 cSz  := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 )
 hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,1,Int,0,Int,3,Int,0,Int,0)
 IfLess,hFil,1, Return,hFil
 DllCall( "GetFileSizeEx", UInt,hFil, Str,Buffer ),   fSz := NumGet( Buffer,0,"Int64" )
 VarSetCapacity( MD5_CTX,104,0 ),    DllCall( "advapi32\MD5Init", Str,MD5_CTX )
 Loop % ( fSz//cSz+!!Mod(fSz,cSz) )
   DllCall( "ReadFile", UInt,hFil, Str,Buffer, UInt,cSz, UIntP,bytesRead, UInt,0 )
 , DllCall( "advapi32\MD5Update", Str,MD5_CTX, Str,Buffer, UInt,bytesRead )
 DllCall( "advapi32\MD5Final", Str,MD5_CTX ), DllCall( "CloseHandle", UInt,hFil )
 Loop % StrLen( Hex:="123456789ABCDEF0" )
  N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
Return MD5
}

MD5( ByRef V, L=0 ) { ; www.autohotkey.com/forum/viewtopic.php?p=275910#275910
 VarSetCapacity( MD5_CTX,104,0 ), DllCall( "advapi32\MD5Init", Str,MD5_CTX )
 DllCall( "advapi32\MD5Update", Str,MD5_CTX, Str,V, UInt,L ? L : VarSetCapacity(V) )
 DllCall( "advapi32\MD5Final", Str,MD5_CTX )
 Loop % StrLen( Hex:="123456789ABCDEF0" )
  N := NumGet( MD5_CTX,87+A_Index,"Char"), MD5 .= SubStr(Hex,N>>4,1) . SubStr(Hex,N&15,1)
Return MD5
}

FileCRC32( sFile="",cSz=4 ) { ; by SKAN www.autohotkey.com/community/viewtopic.php?t=64211
 cSz := (cSz<0||cSz>8) ? 2**22 : 2**(18+cSz), VarSetCapacity( Buffer,cSz,0 ) ; 10-Oct-2009
 hFil := DllCall( "CreateFile", Str,sFile,UInt,0x80000000, Int,3,Int,0,Int,3,Int,0,Int,0 )
 IfLess,hFil,1, Return,hFil
 hMod := DllCall( "LoadLibrary", Str,"ntdll.dll" ), CRC32 := 0
 DllCall( "GetFileSizeEx", UInt,hFil, UInt,&Buffer ),    fSz := NumGet( Buffer,0,"Int64" )
 Loop % ( fSz//cSz + !!Mod( fSz,cSz ) )
   DllCall( "ReadFile", UInt,hFil, UInt,&Buffer, UInt,cSz, UIntP,Bytes, UInt,0 )
 , CRC32 := DllCall( "NTDLL\RtlComputeCrc32", UInt,CRC32, UInt,&Buffer, UInt,Bytes, UInt )
 DllCall( "CloseHandle", UInt,hFil )
 SetFormat, Integer, % SubStr( ( A_FI := A_FormatInteger ) "H", 0 )
 CRC32 := SubStr( CRC32 + 0x1000000000, -7 ), DllCall( "CharUpper", Str,CRC32 )
 SetFormat, Integer, %A_FI%
Return CRC32, DllCall( "FreeLibrary", UInt,hMod )
}