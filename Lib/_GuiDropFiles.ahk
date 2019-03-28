; http://ahkscript.org/boards/viewtopic.php?f=28&p=25564#p25564

Class GuiDropFiles
{
    config(GuiHwnd, BeginLable = "", EndLable = "") {
        global IDropSource, IDropTarget

        VarSetCapacity(IDropSource,A_PtrSize*6,0), NumPut(&IDropSource+A_PtrSize,IDropSource), nParams=31132
        Loop,   Parse,  nParams
            NumPut(RegisterCallback("IDropSource","",A_LoopField,A_Index-1),IDropSource,A_PtrSize*A_Index)
        VarSetCapacity(IDropTarget,8*A_PtrSize,0), NumPut(&IDropTarget+A_PtrSize,IDropTarget), nParams:=A_PtrSize=8?3115415:3116516
        Loop,   Parse,  nParams
            NumPut(RegisterCallback("IDropTarget","",A_LoopField,A_Index-1),IDropTarget,A_PtrSize*A_Index)
        DllCall("ole32\OleInitialize","Uint",0)
        DllCall("ole32\RegisterDragDrop","Uint",GuiHwnd,"Uint",&IDropTarget)

        this.GuiHwnd    := GuiHwnd
        this.BeginLable := BeginLable
        this.EndLable   := EndLable
    }

    __Delete() {
        static _ := new GuiDropFiles
        DllCall("ole32\RevokeDragDrop","Uint",this.GuiHwnd)
        DllCall("ole32\OleUninitialize")
    }
}

IDropSource(this, escape=0, key=0)
{
    If  A_EventInfo = 3
        hResult := escape ? 0x00040101 : key&3 ? 0 : 0x00040100
    Else If A_EventInfo = 4
        hResult := 0x00040102
    Else If A_EventInfo = 0
        hResult := 0, NumPut(this,key+0)
    Else    hResult := 0
    Return  hResult
}

IDropTarget(this, pdata=0, key=0, x=0, y=0, peffect=0)
{
    global GuiDropFiles_FileFullPath

    If (A_EventInfo = 4) {    ; dragging loop over window
        GuiDropFiles_FileFullPath := ""
        NumPut(NumGet(y+0)&5,y+0)
        If (GuiDropFiles.BeginLable != "")
            SetTimer, % GuiDropFiles.BeginLable, -1
    }
    Else If A_EventInfo = 3   ;dragging to window
        NumPut(NumGet(peffect+0)&5,peffect+0)
    Else If A_EventInfo = 6    ;dropped
        NumPut(NumGet(peffect+0)&5,peffect+0), GuiDropFiles_FileFullPath := IEnumFormatEtc(pdata)
    Else If A_EventInfo = 0
        NumPut(this,key+0)

    If A_EventInfo in 5,6   ;5 leaving window
    {
        If (GuiDropFiles.EndLable != "")
            SetTimer, % GuiDropFiles.EndLable, -1
    }
    Return  0
}

IEnumFormatEtc(this)
{
    DllCall(NumGet(NumGet(1*this)+8*A_PtrSize),"Uint",this,"Uint",1,"UintP",penum) ; DATADIR_GET=1, DATADIR_SET=2
    Loop
    {
        VarSetCapacity(FormatEtc,A_PtrSize * 5,0)
        If  DllCall(NumGet(NumGet(1*penum)+A_PtrSize * 3), "Ptr", penum, "Uint",1, "Ptr", &FormatEtc, "Uint",0)
            Break
        0+(nFormat:=NumGet(FormatEtc,0,"Ushort"))<18 ? RegExMatch(__cfList, "(?:\w+\s+){" . nFormat-1 . "}(?<FORMAT>\w+\b)", CF_) : nFormat>=0x80&&nFormat<=0x83 ? RegExMatch("CF_OWNERDISPLAY CF_DSPTEXT CF_DSPBITMAP CF_DSPMETAFILEPICT", "(?:\w+\s+){" . nFormat-0x80 . "}(?<FORMAT>\w+\b)", CF_) : nFormat=0x8E ? CF_FORMAT:="CF_DSPENHMETAFILE" : CF_FORMAT:=GetClipboardFormatName(nFormat)
        VarSetCapacity(StgMedium,A_PtrSize * 3,0)
        If  DllCall(NumGet(NumGet(1*this)+A_PtrSize * 3), "Ptr", this, "Ptr", &FormatEtc, "Ptr", &StgMedium)
            Continue
        If  NumGet(StgMedium,0)=1   ; TYMED_HGLOBAL=1
        {
            hData:=NumGet(StgMedium,A_PtrSize)
            pData:=DllCall("GlobalLock", "Uint", hData)
            nSize:=DllCall("GlobalSize", "Uint", hData)
            VarSetCapacity(sData,1023), DllCall("wsprintf", "str", sData, "str", (DllCall("advapi32\IsTextUnicode", "Uint", pData, "Uint", nSize, "Uint", 0) & A_IsUnicode) ? "%s" : "%S", "Uint", pData, "Cdecl")
            DllCall("GlobalUnlock", "Uint", hData)

            If (CF_FORMAT = "FileNameW")
                FileNameW := sData
        }
        Else {
            RegExMatch("TYMED_NULL TYMED_FILE TYMED_ISTREAM TYMED_ISTORAGE TYMED_GDI TYMED_MFPICT TYMED_ENHMF", "(?:\w+\s+){" . Floor(ln(NumGet(StgMedium)+1)/ln(2)) . "}(?<STGMEDIUM>\w+\b)", TYMED_)
        }
    
        DllCall("ole32\ReleaseStgMedium","Uint",&StgMedium)
    }
    DllCall(NumGet(NumGet(1*penum)+2*A_PtrSize), "Uint", penum)
    Return FileNameW
}