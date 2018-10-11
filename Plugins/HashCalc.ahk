; ===================================================================================
; AHK Version ...: AHK_L 1.1.14.03 x64 Unicode
; Win Version ...: Windows 7 Professional x64 SP1
; Description ...: Calculate hash from string, hex or file to
;                  MD2, MD4, MD5, SHA1, SHA-256, SHA-384, SHA-512
;                  HMAC
; Version .......: v0.9
; Modified ......: 2014.03.10-1959
; Author ........: jNizM
; ===================================================================================
;@Ahk2Exe-SetName HashCalc
;@Ahk2Exe-SetDescription HashCalc
;@Ahk2Exe-SetVersion v0.9
;@Ahk2Exe-SetCopyright Copyright (c) 2013-2014`, jNizM
;@Ahk2Exe-SetOrigFilename HashCalc.ahk
; ===================================================================================

; GLOBAL SETTINGS ===================================================================

#Warn
#NoEnv
#SingleInstance Force
SetBatchLines, -1

global name        := "HashCalc"
global version     := "v0.9"
global love        := chr(9829)
global copyright   := chr(169)

; SCRIPT ============================================================================

if 0 = 0
1=

Gui, Margin, 10, 10
Gui, Font, s9, Courier New
Gui, Add, Text, xm ym w100, Data Format:
Gui, Add, Text, x+10 ym w390, Data:
Gui, Add, DropDownList, xm y+6 w100 AltSubmit vDDL, Text String||Hex|File
Gui, Add, Edit, x+10 yp w390 vStr,%1%
Gui, Add, Button, x+3 yp w80 h23 gFile vFile, File
Gui, Add, Checkbox, xm y+6 w100 h23 vCheck, HMAC
Gui, Add, Edit, x+10 yp w390 vHMAC,
Gui, Add, Text, xm y+10 w586 h1 0x10

Gui, Add, Checkbox, xm y+10 w100 h23 vCheckCRC32, CRC32
Gui, Add, Edit, x+10 yp w390 0x800 vCRC32,
Gui, Add, Button, x+3 yp w80 h23 gCopyCRC32 vCopyCRC32, Copy

Gui, Add, Checkbox, xm y+6 w100 h23 vCheckMD2, MD2
Gui, Add, Edit, x+10 yp w390 0x800 vMD2,
Gui, Add, Button, x+3 yp w80 h23 gCopyMD2 vCopyMD2, Copy

Gui, Add, Checkbox, xm y+6 w100 h23 vCheckMD4, MD4
Gui, Add, Edit, x+10 yp w390 0x800 vMD4,
Gui, Add, Button, x+3 yp w80 h23 gCopyMD4 vCopyMD4, Copy

Gui, Add, Checkbox, xm y+6 w100 h23 Checked vCheckMD5, MD5
Gui, Add, Edit, x+10 yp w390 0x800 vMD5,
Gui, Add, Button, x+3 yp w80 h23 gCopyMD5 vCopyMD5, Copy

Gui, Add, Checkbox, xm y+6 w100 h23 Checked vCheckSHA, SHA-1
Gui, Add, Edit, x+10 yp w390 0x800 vSHA,
Gui, Add, Button, x+3 yp w80 h23 gCopySHA vCopySHA, Copy

Gui, Add, Checkbox, xm y+6 w100 h23 vCheckSHA2, SHA-256
Gui, Add, Edit, x+10 yp w390 0x800 vSHA2,
Gui, Add, Button, x+3 yp w80 h23 gCopySHA2 vCopySHA2, Copy

Gui, Add, Checkbox, xm y+6 w100 h23 vCheckSHA3, SHA-384
Gui, Add, Edit, x+10 yp w390 0x800 vSHA3,
Gui, Add, Button, x+3 yp w80 h23 gCopySHA3 vCopySHA3, Copy

Gui, Add, Checkbox, xm y+6 w100 h23 vCheckSHA5, SHA-512
Gui, Add, Edit, x+10 yp w390 0x800 vSHA5,
Gui, Add, Button, x+3 yp w80 h23 gCopySHA5 vCopySHA5, Copy
Gui, Add, Text, xm y+10 w586 h1 0x10

Gui, Add, Text, xm y+10 w100 h23 0x200, Verify
Gui, Add, Edit, x+10 yp w390 vVerify,
Gui, Add, Edit, x+3 yp w80 0x201 0x800 vHashOK,
Gui, Add, Text, xm y+10 w586 h1 0x10

Gui, Font, cSilver,
Gui, Add, Text, xm y+10 w300 h21 0x200, made with %love% and AHK 2013-%A_YYYY%, jNizM
Gui, Font,,
Gui, Add, Button, x+36 yp-1 w80 gCalculate, Calculate
Gui, Add, Button, x+3 yp w80 gClear, Clear
Gui, Add, Button, x+3 yp w80 gClose, Close

Gui, Show, AutoSize, %name% %version%

SetTimer, CheckEdit, 100
SetTimer, VerifyHash, 200
return

GuiDropFiles:
    FilePath := A_GuiEvent
    GuiControl,, Str, % FilePath
    GuiControl, Choose, DDL, 3
return

CheckEdit:
    Gui, Submit, NoHide
    if (DDL = 1)
    {
        GuiControl, % Check = "0" ? "Disable" : "Enable",  HMAC
        GuiControl, % DDL   = "1" ? "Enable"  : "Disable", Check
    }
    if (DDL = 2)
    {
        GuiControl, % DDL   = "2" ? "Disable" : "Enable",  HMAC
        GuiControl, % DDL   = "2" ? "Disable" : "Enable",  Check
        GuiControl, % DDL   = "2" ? "Enable"  : "Disable", File
    }
    if (DDL = 3)
    {
        GuiControl, % DDL   = "3" ? "Disable" : "Enable",  HMAC
        GuiControl, % DDL   = "3" ? "Disable" : "Enable",  Check
        GuiControl, % DDL   = "3" ? "Enable"  : "Disable", File
    }
    GuiControl, % Check = "1" ? "Disable" : "Enable",  CheckCRC32
    GuiControl, % CRC32 = ""  ? "Disable" : "Enable",  CopyCRC32
    GuiControl, % MD2   = ""  ? "Disable" : "Enable",  CopyMD2
    GuiControl, % MD4   = ""  ? "Disable" : "Enable",  CopyMD4
    GuiControl, % MD5   = ""  ? "Disable" : "Enable",  CopyMD5
    GuiControl, % SHA   = ""  ? "Disable" : "Enable",  CopySHA
    GuiControl, % SHA2  = ""  ? "Disable" : "Enable",  CopySHA2
    GuiControl, % SHA3  = ""  ? "Disable" : "Enable",  CopySHA3
    GuiControl, % SHA5  = ""  ? "Disable" : "Enable",  CopySHA5
return

File:
    GuiControl, Choose, DDL, 3
    FileSelectFile, File
    GuiControl,, Str, %File%
return

Calculate:
    Gui, Submit, NoHide
    GuiControl,, CRC32, % ((CheckCRC32 = "1") ? ((DDL = "1") ? ((Check = "0") ? (CRC32(Str))  : "")                          : ((DDL = "2") ? (HexCRC32(Str))  : (FileCRC32(Str))))  : (""))
    GuiControl,, MD2,   % ((CheckMD2   = "1") ? ((DDL = "1") ? ((Check = "0") ? (MD2(Str))    : (HMAC(HMAC, Str, "MD2")))    : ((DDL = "2") ? (HexMD2(Str))    : (FileMD2(Str))))    : (""))
    GuiControl,, MD4,   % ((CheckMD4   = "1") ? ((DDL = "1") ? ((Check = "0") ? (MD4(Str))    : (HMAC(HMAC, Str, "MD4")))    : ((DDL = "2") ? (HexMD4(Str))    : (FileMD4(Str))))    : (""))
    GuiControl,, MD5,   % ((CheckMD5   = "1") ? ((DDL = "1") ? ((Check = "0") ? (MD5(Str))    : (HMAC(HMAC, Str, "MD5")))    : ((DDL = "2") ? (HexMD5(Str))    : (FileMD5(Str))))    : (""))
    GuiControl,, SHA,   % ((CheckSHA   = "1") ? ((DDL = "1") ? ((Check = "0") ? (SHA(Str))    : (HMAC(HMAC, Str, "SHA")))    : ((DDL = "2") ? (HexSHA(Str))    : (FileSHA(Str))))    : (""))
    GuiControl,, SHA2,  % ((CheckSHA2  = "1") ? ((DDL = "1") ? ((Check = "0") ? (SHA256(Str)) : (HMAC(HMAC, Str, "SHA256"))) : ((DDL = "2") ? (HexSHA256(Str)) : (FileSHA256(Str)))) : (""))
    GuiControl,, SHA3,  % ((CheckSHA3  = "1") ? ((DDL = "1") ? ((Check = "0") ? (SHA384(Str)) : (HMAC(HMAC, Str, "SHA384"))) : ((DDL = "2") ? (HexSHA384(Str)) : (FileSHA384(Str)))) : (""))
    GuiControl,, SHA5,  % ((CheckSHA5  = "1") ? ((DDL = "1") ? ((Check = "0") ? (SHA512(Str)) : (HMAC(HMAC, Str, "SHA512"))) : ((DDL = "2") ? (HexSHA512(Str)) : (FileSHA512(Str)))) : (""))
return

Clear:
    GuiControl,, Str,
    GuiControl,, HMAC,
    GuiControl,, CRC32,
    GuiControl,, MD2,
    GuiControl,, MD4,
    GuiControl,, MD5,
    GuiControl,, SHA,
    GuiControl,, SHA2,
    GuiControl,, SHA3,
    GuiControl,, SHA5,
    GuiControl,, Verify,
return

VerifyHash:
    Gui, Submit, NoHide
    Result := Hashify(Verify, CRC32, MD2, MD4, MD5, SHA, SHA2, SHA3, SHA5)
    GuiControl, % (InStr(Result, "OK") ? "+c008000" : "+c800000"), HashOK
    GuiControl,, HashOk, %Result%
return

CopyCRC32:
    Clipboard := CRC32
return
CopyMD2:
    Clipboard := MD2
return
CopyMD4:
    Clipboard := MD4
return
CopyMD5:
    Clipboard := MD5
return
CopySHA:
    Clipboard := SHA
return
CopySHA2:
    Clipboard := SHA2
return
CopySHA3:
    Clipboard := SHA3
return
CopySHA5:
    Clipboard := SHA5
return

; FUNCTIONS =========================================================================

; Verify ============================================================================
Hashify(Hash, CRC32, MD2, MD4, MD5, SHA, SHA2, SHA3, SHA5)
{
    return % (Hash = "")    ? ""
           : (Hash = CRC32) ? ("CRC32 OK")
           : (Hash = MD2)   ? ("MD2 OK")
           : (Hash = MD4)   ? ("MD4 OK")
           : (Hash = MD5)   ? ("MD5 OK")
           : (Hash = SHA)   ? ("SHA1 OK")
           : (Hash = SHA2)  ? ("SHA256 OK")
           : (Hash = SHA3)  ? ("SHA384 OK")
           : (Hash = SHA5)  ? ("SHA512 OK")
           : "FALSE"
}

; HMAC ==============================================================================
HMAC(Key, Message, Algo := "MD5")
{
    static Algorithms := {MD2:    {ID: 0x8001, Size:  64}
                        , MD4:    {ID: 0x8002, Size:  64}
                        , MD5:    {ID: 0x8003, Size:  64}
                        , SHA:    {ID: 0x8004, Size:  64}
                        , SHA256: {ID: 0x800C, Size:  64}
                        , SHA384: {ID: 0x800D, Size: 128}
                        , SHA512: {ID: 0x800E, Size: 128}}
    static iconst := 0x36
    static oconst := 0x5C
    if (!(Algorithms.HasKey(Algo)))
    {
        return ""
    }
    Hash := KeyHashLen := InnerHashLen := ""
    HashLen := 0
    AlgID := Algorithms[Algo].ID
    BlockSize := Algorithms[Algo].Size
    MsgLen := StrPut(Message, "UTF-8") - 1
    KeyLen := StrPut(Key, "UTF-8") - 1
    VarSetCapacity(K, KeyLen + 1, 0)
    StrPut(Key, &K, KeyLen, "UTF-8")
    if (KeyLen > BlockSize)
    {
        CalcAddrHash(&K, KeyLen, AlgID, KeyHash, KeyHashLen)
    }

    VarSetCapacity(ipad, BlockSize + MsgLen, iconst)
    Addr := KeyLen > BlockSize ? &KeyHash : &K
    Length := KeyLen > BlockSize ? KeyHashLen : KeyLen
    i := 0
    while (i < Length)
    {
        NumPut(NumGet(Addr + 0, i, "UChar") ^ iconst, ipad, i, "UChar")
        i++
    }
    if (MsgLen)
    {
        StrPut(Message, &ipad + BlockSize, MsgLen, "UTF-8")
    }
    CalcAddrHash(&ipad, BlockSize + MsgLen, AlgID, InnerHash, InnerHashLen)

    VarSetCapacity(opad, BlockSize + InnerHashLen, oconst)
    Addr := KeyLen > BlockSize ? &KeyHash : &K
    Length := KeyLen > BlockSize ? KeyHashLen : KeyLen
    i := 0
    while (i < Length)
    {
        NumPut(NumGet(Addr + 0, i, "UChar") ^ oconst, opad, i, "UChar")
        i++
    }
    Addr := &opad + BlockSize
    i := 0
    while (i < InnerHashLen)
    {
        NumPut(NumGet(InnerHash, i, "UChar"), Addr + i, 0, "UChar")
        i++
    }
    return CalcAddrHash(&opad, BlockSize + InnerHashLen, AlgID)
}

; MD2 ===============================================================================
MD2(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x8001, encoding)
}
HexMD2(hexstring)
{
    return CalcHexHash(hexstring, 0x8001)
}
FileMD2(filename)
{
    return CalcFileHash(filename, 0x8001, 64 * 1024)
}
; MD4 ===============================================================================
MD4(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x8002, encoding)
}
HexMD4(hexstring)
{
    return CalcHexHash(hexstring, 0x8002)
}
FileMD4(filename)
{
    return CalcFileHash(filename, 0x8002, 64 * 1024)
}
; MD5 ===============================================================================
MD5(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x8003, encoding)
}
HexMD5(hexstring)
{
    return CalcHexHash(hexstring, 0x8003)
}
FileMD5(filename)
{
    return CalcFileHash(filename, 0x8003, 64 * 1024)
}
; SHA ===============================================================================
SHA(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x8004, encoding)
}
HexSHA(hexstring)
{
    return CalcHexHash(hexstring, 0x8004)
}
FileSHA(filename)
{
    return CalcFileHash(filename, 0x8004, 64 * 1024)
}
; SHA256 ============================================================================
SHA256(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x800c, encoding)
}
HexSHA256(hexstring)
{
    return CalcHexHash(hexstring, 0x800c)
}
FileSHA256(filename)
{
    return CalcFileHash(filename, 0x800c, 64 * 1024)
}
; SHA384 ============================================================================
SHA384(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x800d, encoding)
}
HexSHA384(hexstring)
{
    return CalcHexHash(hexstring, 0x800d)
}
FileSHA384(filename)
{
    return CalcFileHash(filename, 0x800d, 64 * 1024)
}
; SHA512 ============================================================================
SHA512(string, encoding = "UTF-8")
{
    return CalcStringHash(string, 0x800e, encoding)
}
HexSHA512(hexstring)
{
    return CalcHexHash(hexstring, 0x800e)
}
FileSHA512(filename)
{
    return CalcFileHash(filename, 0x800e, 64 * 1024)
}

; CalcAddrHash ======================================================================
CalcAddrHash(addr, length, algid, byref hash = 0, byref hashlength = 0)
{
    static h := [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "a", "b", "c", "d", "e", "f"]
    static b := h.minIndex()
    hProv := hHash := o := ""
    if (DllCall("advapi32\CryptAcquireContext", "Ptr*", hProv, "Ptr", 0, "Ptr", 0, "UInt", 24, "UInt", 0xf0000000))
    {
        if (DllCall("advapi32\CryptCreateHash", "Ptr", hProv, "UInt", algid, "UInt", 0, "UInt", 0, "Ptr*", hHash))
        {
            if (DllCall("advapi32\CryptHashData", "Ptr", hHash, "Ptr", addr, "UInt", length, "UInt", 0))
            {
                if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", 0, "UInt*", hashlength, "UInt", 0))
                {
                    VarSetCapacity(hash, hashlength, 0)
                    if (DllCall("advapi32\CryptGetHashParam", "Ptr", hHash, "UInt", 2, "Ptr", &hash, "UInt*", hashlength, "UInt", 0))
                    {
                        loop % hashlength
                        {
                            v := NumGet(hash, A_Index - 1, "UChar")
                            o .= h[(v >> 4) + b] h[(v & 0xf) + b]
                        }
                    }
                }
            }
            DllCall("advapi32\CryptDestroyHash", "Ptr", hHash)
        }
        DllCall("advapi32\CryptReleaseContext", "Ptr", hProv, "UInt", 0)
    }
    return o
}

; CalcStringHash ====================================================================
CalcStringHash(string, algid, encoding = "UTF-8", byref hash = 0, byref hashlength = 0)
{
    chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
    length := (StrPut(string, encoding) - 1) * chrlength
    VarSetCapacity(data, length, 0)
    StrPut(string, &data, floor(length / chrlength), encoding)
    return CalcAddrHash(&data, length, algid, hash, hashlength)
}

; CalcHexHash =======================================================================
CalcHexHash(hexstring, algid)
{
    length := StrLen(hexstring) // 2
    VarSetCapacity(data, length, 0)
    loop % length
    {
        NumPut("0x" SubStr(hexstring, 2 * A_Index -1, 2), data, A_Index - 1, "Char")
    }
    return CalcAddrHash(&data, length, algid)
}

; CalcFileHash ======================================================================
CalcFileHash(filename, algid, continue = 0, byref hash = 0, byref hashlength = 0)
{
    fpos := ""
    if (!(f := FileOpen(filename, "r")))
    {
        return
    }
    f.pos := 0
    if (!continue && f.length > 0x7fffffff)
    {
        return
    }
    if (!continue)
    {
        VarSetCapacity(data, f.length, 0)
        f.rawRead(&data, f.length)
        f.pos := oldpos
        return CalcAddrHash(&data, f.length, algid, hash, hashlength)
    }
    hashlength := 0
    while (f.pos < f.length)
    {
        readlength := (f.length - fpos > continue) ? continue : f.length - f.pos
        VarSetCapacity(data, hashlength + readlength, 0)
        DllCall("RtlMoveMemory", "Ptr", &data, "Ptr", &hash, "Ptr", hashlength)
        f.rawRead(&data + hashlength, readlength)
        h := CalcAddrHash(&data, hashlength + readlength, algid, hash, hashlength)
    }
    return h
}

; CRC32 =============================================================================
CRC32(string, encoding = "UTF-8")
{
    chrlength := (encoding = "CP1200" || encoding = "UTF-16") ? 2 : 1
    length := (StrPut(string, encoding) - 1) * chrlength
    VarSetCapacity(data, length, 0)
    StrPut(string, &data, floor(length / chrlength), encoding)
    hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
    SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
    CRC := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0, "UInt", &data, "UInt", length, "UInt")
    o := SubStr(CRC | 0x1000000000, -7)
    DllCall("User32.dll\CharLower", "Str", o)
    SetFormat, Integer, %A_FI%
    return o, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}

; HexCRC32 ==========================================================================
HexCRC32(hexstring)
{
    length := StrLen(hexstring) // 2
    VarSetCapacity(data, length, 0)
    loop % length
    {
        NumPut("0x" SubStr(hexstring, 2 * A_Index -1, 2), data, A_Index - 1, "Char")
    }
    hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
    SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
    CRC := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0, "UInt", &data, "UInt", length, "UInt")
    o := SubStr(CRC | 0x1000000000, -7)
    DllCall("User32.dll\CharLower", "Str", o)
    SetFormat, Integer, %A_FI%
    return o, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}

; FileCRC32 =========================================================================
FileCRC32(sFile := "", cSz := 4)
{
    Bytes := ""
    cSz := (cSz < 0 || cSz > 8) ? 2**22 : 2**(18 + cSz)
    VarSetCapacity(Buffer, cSz, 0)
    hFil := DllCall("Kernel32.dll\CreateFile", "Str", sFile, "UInt", 0x80000000, "UInt", 3, "Int", 0, "UInt", 3, "UInt", 0, "Int", 0, "UInt")
    if (hFil < 1)
    {
        return hFil
    }
    hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll")
    CRC := 0
    DllCall("Kernel32.dll\GetFileSizeEx", "UInt", hFil, "Int64", &Buffer), fSz := NumGet(Buffer, 0, "Int64")
    loop % (fSz // cSz + !!Mod(fSz, cSz))
    {
        DllCall("Kernel32.dll\ReadFile", "UInt", hFil, "Ptr", &Buffer, "UInt", cSz, "UInt*", Bytes, "UInt", 0)
        CRC := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", CRC, "UInt", &Buffer, "UInt", Bytes, "UInt")
    }
    DllCall("Kernel32.dll\CloseHandle", "Ptr", hFil)
    SetFormat, Integer, % SubStr((A_FI := A_FormatInteger) "H", 0)
    CRC := SubStr(CRC + 0x1000000000, -7)
    DllCall("User32.dll\CharLower", "Str", CRC)
    SetFormat, Integer, %A_FI%
    return CRC, DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
}


; EXIT ==============================================================================

Close:
GuiClose:
    exitapp