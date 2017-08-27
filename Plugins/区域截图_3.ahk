#SingleInstance, Force
OnExit ExitSub
run_iniFile = %A_ScriptDir%\..\settings\setting.ini
IniRead,询问, %run_iniFile%,截图, 询问
IniRead,filetp, %run_iniFile%,截图, filetp
IniRead,截图保存目录, %run_iniFile%,截图, 截图保存目录
IfnotExist,%截图保存目录%
  IniRead, 截图保存目录, %run_iniFile%, 路径设置, 截图保存目录

  TrayTip,截图进行中...,
  (
"Win+左键"拖拽鼠标选取截图范围，
按"Esc/右键"键退出截图操作
  ),5,17

#Lbutton::
TrayTip
pBitmap:=SCW_ScreenClip2Win()
gosub xuanzhe
Return


Esc:: ExitApp ;contribued by tervon
Rbutton:: ExitApp  ;contributed by tervon

ExitSub:
Gdip_DisposeImage(pBitmap)
Gdip_Shutdown("pToken")
ExitApp

;===Description========================================================================
/*
[module/script] ScreenClip2Win
Author:      Learning one
Thanks:      Tic, HotKeyIt

Creates always on top layered windows from screen clippings. Click in upper right corner to close win. Click and drag to move it.
Uses Gdip.ahk by Tic.

#Include ScreenClip2Win.ahk      ; by Learning one
;=== Short documentation ===
SCW_ScreenClip2Win()          ; creates always on top window from screen clipping. Click and drag to select area.
SCW_DestroyAllClipWins()       ; destroys all screen clipping windows.
SCW_Win2Clipboard()            ; copies window to clipboard. By default, removes borders. To keep borders, specify "SCW_Win2Clipboard(1)"
SCW_SetUp(Options="")         ; you can change some default options in Auto-execute part of script. Syntax: "<option>.<value>"
   StartAfter - module will start to consume GUIs for screen clipping windows after specified GUI number. Default: 80
   MaxGuis - maximum number of screen clipping windows. Default: 6
   BorderAColor - Default: ff6666ff (ARGB format)
   BorderBColor - Default: ffffffff (ARGB format)
   DrawCloseButton - on/off draw "Close Button" on screen clipping windows. Default: 0 (off)
   AutoMonitorWM_LBUTTONDOWN - on/off automatic monitoring of WM_LBUTTONDOWN message. Default: 1 (on)
   SelColor - selection color. Default: Yellow
   SelTrans - selection transparency. Default: 80

   Example:   SCW_SetUp("MaxGuis.30 StartAfter.50 BorderAColor.ff000000 BorderBColor.ffffff00")



;=== Avoid OnMessage(0x201, "WM_LBUTTONDOWN") collision example===
Gui, Show, w200 h200
SCW_SetUp("AutoMonitorWM_LBUTTONDOWN.0")   ; turn off auto monitoring WM_LBUTTONDOWN
OnMessage(0x201, "WM_LBUTTONDOWN")   ; manualy monitor WM_LBUTTONDOWN
Return

^Lbutton::SCW_ScreenClip2Win()   ; click & drag
Esc::ExitApp

#Include Gdip.ahk      ; by Tic
#Include ScreenClip2Win.ahk      ; by Learning one
WM_LBUTTONDOWN() {
   if SCW_LBUTTONDOWN()   ; LBUTTONDOWN on module's screen clipping windows - isolate - it's module's buissines
   return
   else   ; LBUTTONDOWN on other windows created by script
   MsgBox,,, You clicked on script's window not created by this module,1
}
*/


;===Functions==========================================================================

SCW_Version() {
   return 1.02
}

SCW_DestroyAllClipWins() {
   MaxGuis := SCW_Reg("MaxGuis"), StartAfter := SCW_Reg("StartAfter")
   Loop, %MaxGuis%
   {
      StartAfter++
      Gui %StartAfter%: Destroy
   }
}


SCW_SetUp(Options="") {
   if !(Options = "")
   {
      Loop, Parse, Options, %A_Space%
      {
         Field := A_LoopField
         DotPos := InStr(Field, ".")
         if (DotPos = 0)
         Continue
         var := SubStr(Field, 1, DotPos-1)
         val := SubStr(Field, DotPos+1)
         if var in StartAfter,MaxGuis,AutoMonitorWM_LBUTTONDOWN,DrawCloseButton,BorderAColor,BorderBColor,SelColor,SelTrans
         %var% := val
      }
   }

   SCW_Default(StartAfter,80), SCW_Default(MaxGuis,6)
   SCW_Default(AutoMonitorWM_LBUTTONDOWN,1), SCW_Default(DrawCloseButton,0)
   SCW_Default(BorderAColor,"ff6666ff"), SCW_Default(BorderBColor,"ffffffff")
   SCW_Default(SelColor,"Yellow"), SCW_Default(SelTrans,80)

   SCW_Reg("MaxGuis", MaxGuis), SCW_Reg("StartAfter", StartAfter), SCW_Reg("DrawCloseButton", DrawCloseButton)
   SCW_Reg("BorderAColor", BorderAColor), SCW_Reg("BorderBColor", BorderBColor)
   SCW_Reg("SelColor", SelColor), SCW_Reg("SelTrans",SelTrans)
   SCW_Reg("WasSetUp", 1)
   if AutoMonitorWM_LBUTTONDOWN
   OnMessage(0x201, "SCW_LBUTTONDOWN")
}

SCW_ScreenClip2Win() {
   static c
   if !(SCW_Reg("WasSetUp"))
   SCW_SetUp()

   StartAfter := SCW_Reg("StartAfter"), MaxGuis := SCW_Reg("MaxGuis"), SelColor := SCW_Reg("SelColor"), SelTrans := SCW_Reg("SelTrans")
   c++
   if (c > MaxGuis)
   c := 1

   GuiNum := StartAfter + c
   Area := SCW_SelectAreaMod("g" GuiNum " c" SelColor " t" SelTrans)
   StringSplit, v, Area, |
   if (v3 < 10 and v4 < 10)   ; too small area
   return

   pToken := Gdip_Startup()
   if pToken =
   {
      MsgBox, 64, GDI+ error, GDI+ failed to start. Please ensure you have GDI+ on your system.
      return
   }

   Sleep, 100
   pBitmap := Gdip_BitmapFromScreen(Area)
   SCW_Win2Clipboard(pBitmap)

   IfExist, %A_ScriptDir%\Sound\shutter.wav
   SoundPlay, %A_ScriptDir%\Sound\shutter.wav, wait
;*******************************************************
   SCW_CreateLayeredWinMod(GuiNum,pBitmap,v1,v2, SCW_Reg("DrawCloseButton"))
   Return pBitmap
   ;Gdip_Shutdown("pToken")
}

SCW_SelectAreaMod(Options="") {
   CoordMode, Mouse, Screen
   MouseGetPos, MX, MY
      loop, parse, Options, %A_Space%
   {
      Field := A_LoopField
      FirstChar := SubStr(Field,1,1)
      if FirstChar contains c,t,g,m
      {
         StringTrimLeft, Field, Field, 1
         %FirstChar% := Field
      }
   }
   c := (c = "") ? "Blue" : c, t := (t = "") ? "50" : t, g := (g = "") ? "99" : g
   Gui %g%: Destroy
   Gui %g%: +AlwaysOnTop -caption +Border +ToolWindow +LastFound
   WinSet, Transparent, %t%
   Gui %g%: Color, %c%
   Hotkey := RegExReplace(A_ThisHotkey,"^(\w* & |\W*)")
   While, (GetKeyState(Hotkey, "p"))
   {
      Sleep, 10
      MouseGetPos, MXend, MYend
      w := abs(MX - MXend), h := abs(MY - MYend)
      X := (MX < MXend) ? MX : MXend
      Y := (MY < MYend) ? MY : MYend
      Gui %g%: Show, x%X% y%Y% w%w% h%h% NA
   }
   Gui %g%: Destroy
   MouseGetPos, MXend, MYend
   If ( MX > MXend )
   temp := MX, MX := MXend, MXend := temp
   If ( MY > MYend )
   temp := MY, MY := MYend, MYend := temp
   Return MX "|" MY "|" w "|" h
}

SCW_CreateLayeredWinMod(GuiNum,pBitmap,x,y,DrawCloseButton=0) {
   static CloseButton := 16
   BorderAColor := SCW_Reg("BorderAColor"), BorderBColor := SCW_Reg("BorderBColor")

   Gui %GuiNum%: -Caption +E0x80000 +LastFound +ToolWindow +AlwaysOnTop +OwnDialogs
   Gui %GuiNum%: Show, Na, ScreenClippingWindow
   hwnd := WinExist()

   Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
   hbm := CreateDIBSection(Width+6, Height+6), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
   G := Gdip_GraphicsFromHDC(hdc), Gdip_SetSmoothingMode(G, 4), Gdip_SetInterpolationMode(G, 7)

   Gdip_DrawImage(G, pBitmap, 3, 3, Width, Height)
   ;Gdip_DisposeImage(pBitmap)

   pPen1 := Gdip_CreatePen("0x" BorderAColor, 3), pPen2 := Gdip_CreatePen("0x" BorderBColor, 1)
   if DrawCloseButton
   {
      Gdip_DrawRectangle(G, pPen1, 1+Width-CloseButton+3, 1, CloseButton, CloseButton)
      Gdip_DrawRectangle(G, pPen2, 1+Width-CloseButton+3, 1, CloseButton, CloseButton)
   }
   Gdip_DrawRectangle(G, pPen1, 1, 1, Width+3, Height+3)
   Gdip_DrawRectangle(G, pPen2, 1, 1, Width+3, Height+3)
   Gdip_DeletePen(pPen1), Gdip_DeletePen(pPen2)

   UpdateLayeredWindow(hwnd, hdc, x-3, y-3, Width+6, Height+6)
   SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
   SCW_Reg("G" GuiNum "#HWND", hwnd)
   SCW_Reg("G" GuiNum "#XClose", Width+6-CloseButton)
   SCW_Reg("G" GuiNum "#YClose", CloseButton)
   Return hwnd
}

SCW_LBUTTONDOWN() {
   MouseGetPos,,, WinUMID
    WinGetTitle, Title, ahk_id %WinUMID%
   if Title = ScreenClippingWindow
   {
      PostMessage, 0xA1, 2,,, ahk_id %WinUMID%
      KeyWait, Lbutton
      CoordMode, mouse, Relative
      MouseGetPos, x,y
     XClose := SCW_Reg("G" A_Gui "#XClose"), YClose := SCW_Reg("G" A_Gui "#YClose")
      if (x > XClose and y < YClose)
      Gui %A_Gui%: Destroy
      return 1   ; confirm that click was on module's screen clipping windows
   }
}

SCW_Reg(variable, value="") {
   static
   if (value = "") {
      yaqxswcdevfr := kxucfp%variable%pqzmdk
      Return yaqxswcdevfr
   }
   Else
   kxucfp%variable%pqzmdk = %value%
}

SCW_Default(ByRef Variable,DefaultValue) {
   if (Variable="")
   Variable := DefaultValue
}

SCW_Win2Clipboard(pBitmap) {
      Gdip_SetBitmapToClipboard(pBitmap)
      TrayTip,截图,截图已保存到剪贴板
}

SCW_CropImage(pBitmap, x, y, w, h) {
   pBitmap2 := Gdip_CreateBitmap(w, h), G2 := Gdip_GraphicsFromImage(pBitmap2)
   Gdip_DrawImage(G2, pBitmap, 0, 0, w, h, x, y, w, h)
   Gdip_DeleteGraphics(G2)
   return pBitmap2
}


;***********Function by Tervon*******************
SCW_Win2File(pBitmap,filetype="jpg",FileName="") {
global 截图保存目录
      if FileName
      {
      File2:= 截图保存目录 . "\" . filename . "." . filetype      
      if(Fileexist(File2))
     File2:= 截图保存目录 . "\" . filename . "_" . A_Now . "." . filetype  
     }
      else
      File2:= 截图保存目录 . "\Regional_" . A_Now . "." . filetype ;path to file to save
      Gdip_SaveBitmapToFile(pBitmap, File2) ;Exports automatcially to file
      ;Gdip_DisposeImage(pBitmap)
      ;Gdip_Shutdown("pToken")
}

xuanzhe:
if(询问=1){
  Gui +OwnDialogs
  SetTimer, ChangeButtonNames, 50
  OnMessage(0x53, "WM_HELP")
  msgbox,20483,截图,选定的区域已经截取,点击“是”自动保存。`n点击“否”打开画图，编辑图片。
  IfMsgBox Yes
   {
   SCW_Win2File(pBitmap,filetp)
   }
  IfMsgBox No
  {
   Run, mspaint.exe
   WinWaitActive,无标题 - 画图,,3
   if ErrorLevel
    ExitApp
   Send,^v
  }
Else
ExitApp
}
else{
SCW_Win2File(pBitmap,filetp)
}
ExitApp

WM_HELP(){
global pBitmap,filetp
WinSet,AlwaysOnTop,Off,ScreenClippingWindow ahk_class AutoHotkeyGUI

WinClose 截图
InputBox,FileName,截图,`n输入截图文件名并保存文件,,440,160
if ErrorLevel=0
SCW_Win2File(pBitmap,filetp,FileName)
ExitApp
}

ChangeButtonNames:
IfWinNotExist, 截图
    return  ; Keep waiting.
SetTimer, ChangeButtonNames, off
WinActivate
ControlSetText, Button4, 重命名
return