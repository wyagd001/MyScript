; 复制文字或图片后,在资源管理器和桌面，
; 按下快捷键保存复制内容为文件
剪贴板到文件:
 If (InFileList() && !IsRenaming())
{
CurrentFolder:=GetCurrentFolder()
if CurrentFolder
PasteToPath(CurrentFolder)
else
Send % trim(A_ThisHotkey,"$")
}
else
Send % trim(A_ThisHotkey,"$")
return

PasteToPath(path)
{
    if !InStr(FileExist(path), "D")
        return
    path := RegExReplace(path, "([^\\])$", "$1\")
    if DllCall("IsClipboardFormatAvailable", "Uint",1) or DllCall("IsClipboardFormatAvailable", "Uint",13) {
        paste_type := _("type.text")
    } else if DllCall("IsClipboardFormatAvailable", "Uint",2) {
        paste_type := _("type.image")
        pToken := Gdip_Startup()
    } else {
        return
    }
    
    clip := (paste_type == _("type.text") ? clipboard : Gdip_CreateBitmapFromClipboard())
    default_name := ""
    Loop {
        InputBox, filename, % _("paste.title", paste_type), % _("enter.filename"),, 360, 135,,,,, % default_name
        if ErrorLevel
            break
        filename := Trim(filename, OmitChars := " `t")
        if !IsFileName(filename) {
            MsgBox, 0x10, % _("invalid.name"), % _("invalid.name.msg")
            default_name := filename
            continue
        }
        if !InStr(filename, ".")
            filename := filename . (paste_type == _("type.text") ? ".txt" : ".png")
        fullname := path . filename
        default_name := filename
        if FileExist(fullname) and !(InStr(FileExist(fullname), "R") or InStr(FileExist(fullname), "D")) {
            MsgBox, 0x134, % _("file.exists"), % _("file.exists.msg1", filename)
            IfMsgBox, No
                continue
            try {
                FileDelete, %fullname%
                if (paste_type == _("type.text")) {
                    FileAppend, %clip%, %fullname%
                } else {
                    SaveImage(clip, fullname)
                }
            } catch {
                MsgBox, 0x10, % _("paste.failed"), % _("paste.failed.msg")
            }
            break
        } else if FileExist(fullname) {
            MsgBox, 0x30, % _("file.exists"), % _("file.exists.msg2", filename)
            continue
        } else {
            try {
                if (paste_type == _("type.text")) {
                    FileAppend, %clip%, %fullname%
                } else {
                    SaveImage(clip, fullname)
                }
            } catch {
                MsgBox, 0x10, % _("paste.failed"), % _("paste.failed.msg")
            }
            break
        }
    }
    if pToken
    Gdip_Shutdown(pToken)
}

SaveImage(pBitmap, filename)
{
    Gdip_SaveBitmapToFile(pBitmap, filename, Quality:=100)
    Gdip_DisposeImage(pBitmap)
}

IsFileName(filename)
{
    filename := Trim(filename, OmitChars := " `t")
    if !filename
        return false
    if filename in CON,PRN,AUX,NUL,COM1,COM2,COM3,COM4,COM5,COM6,COM7,COM8,COM9,LPT1,LPT2,LPT3,LPT4,LPT5,LPT6,LPT7,LPT8,LPT9
        return false
    if filename contains <,>,:,`",/,\,|,?,*
        return false
    return true
}

_(msg_key, p0 = "-0", p1 = "-0", p2 = "-0", p3 = "-0", p4 = "-0", p5 = "-0", p6 = "-0", p7 = "-0", p8 = "-0", p9 = "-0")
{
    IniRead, msg, % A_ScriptDir . "\Settings\locale.ini", zh_CN, % msg_key, % msg_key
    if (msg = "ERROR" or msg = "")
        return % msg_key
    StringReplace, msg, msg, `\n, `r`n, ALL
    StringReplace, msg, msg, `\t, % A_Tab, ALL
    Loop 10
    {
        idx := A_Index - 1
        if (p%idx% != "-0")
            msg := RegExReplace(msg, "\{" . idx . "\}", p%idx%)
    }
    return % msg
}