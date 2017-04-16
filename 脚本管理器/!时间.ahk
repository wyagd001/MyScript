;-------------------------------------------------------------------------------
; 13:52 13-4-2007, by Bold, parts from autohotkey forum.
;
; Shows clock, batterypower, mem load and cpu load on top of screen
; Derived from:
; Snippets and scripts from the AutoHotkey forum.
; Thanks to Majkinetor for his getTextWidth function.

; The script is not flawless, no warranties.
; The progressbars disappear (the text stays) on mouseover so they don't get in the way if you want to click something below it.
; The text overlay is in a separate gui on top of the progressbar, not sure if this is the best way to get a progressbar with text overlay.
; You can set thresholds for low battery, high mem load and high cpu. When these thresholds are reached the colors change.
;
; Problems:
; - The date time seems to lose the time sometimes and only shows the date
; - I'm not sure how to always keep the windows on top, even if an other
; - sometimes there is an annoying flicker in the guis.
;
#SingleInstance Force
#NoTrayIcon
#NoEnv
SetWorkingDir %A_ScriptDir%

applicationname := SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4)

Gosub, INIREAD

windowTitle := "ClockInfo"

regionMargin := 10
progressBarPos := regionMargin - 1

; I tried to make as much as possible configurable in the ini file, so we need some calculations.
clockFontStyle = s%fontsize% bold
infoFontStyle = s%infoFontSize% bold

FormatTime, clockText ,, %timeFormat%
clockWidth := GetTextSize(clockText, clockFontStyle "," clockFont )+10

battText1 = xx
battText2 := "100%"
battWidth := GetTextSize(battText1, infoFontStyle "," Webdings )+10
battWidth += GetTextSize(battText2, infoFontStyle "," infoFont )+10

memText := memLabel . "100%"
memWidth := GetTextSize(memText, infoFontStyle "," infoFont )+10

cpuText := cpuLabel . "100.00%"
cpuWidth := GetTextSize(cpuText, infoFontStyle "," infoFont )+10

maxWidth := Max(battWidth, Max(memWidth, cpuWidth))
; Use the widest width for all
battWidth := maxWidth
cpuWidth := maxWidth
memWidth := maxWidth

battProgressWidth := battWidth + 1
memProgressWidth := memWidth + 1
cpuProgressWidth := cpuWidth + 1

height := fontSize + (fontsize * 0.7)
infoHeight := infoFontSize + (fontsize * 0.7)
txtY := 0
txtX := 15
posFromRight = 120

battInfo := GetPowerStatus(acLineStatus)

VarSetCapacity( IdleTicks, 2*4 )
VarSetCapacity( memstatus, 100 )

OnExit, ExitSub

Gosub, CALCULATEPOSITIONS
Gosub, CREATECLOCKWINDOW

SetTimer, UPDATECLOCK, 1000
SetTimer, UPDATEBATTERY, 2000
SetTimer, UPDATECPU, 1500
SetTimer, WATCHCURSOR, 115
SetTimer, KEEPONTOP, 1000

getDistance(mX, mY, x, y, w, h)
{
    ; pointer is in object
    If (mX > x) and (mX < (x + w))
    and (mY > y) and (mY < (y + h))
    {
        xDistance := 0
        yDistance := 0
    }
    Else
    {
        ; pointer is to the left of object
        If (mX < x)
            xDistance := x - mX
        ; pointer is to the right of object
        Else If (mX > (x + w))
            xDistance := mX - (x + w)

        ; pointer is above object
        If (mY < y)
            yDistance := y - mY
        ; pointer is below object
        Else If (mY > (y + h))
            yDistance := mY - (y + h)
    }
    distance := max(xDistance, yDistance) * 3
    return distance
}

CALCULATEPOSITIONS:
   savedScreenWidth := A_ScreenWidth
   savedScreenHeight := A_ScreenHeight

   width := clockWidth + battWidth + memWidth + cpuWidth + margin * 3
   xPos := savedScreenWidth - width - posFromRight
   yPos := 3
    battPos := xPos + clockWidth + margin
    memPos := battPos + battWidth + margin
    cpuPos := memPos + memWidth + margin
Return

WATCHCURSOR:
    CoordMode, Mouse
    MouseGetPos, mouseX, mouseY
    clockTransparency := min(getDistance(mouseX, mouseY, xPos + regionMargin, yPos, regionMargin + clockWidth, height), transparency)
    battTransparency := min(getDistance(mouseX, mouseY, battPos + regionMargin, yPos, regionMargin + battWidth, height), transparency)
    memTransparency := min(getDistance(mouseX, mouseY, memPos + regionMargin, yPos, regionMargin + memWidth, height), transparency)
    cpuTransparency := min(getDistance(mouseX, mouseY, cpuPos + regionMargin, yPos, regionMargin + cpuWidth, height), transparency)

   WinSet, Transparent, %clockTransparency%, %windowTitle%
   WinSet, Transparent, %battTransparency%, BattBarGui
   WinSet, Transparent, %memTransparency%, MemBarGui
   WinSet, Transparent, %cpuTransparency%, CpuBarGui
;   WinSet, Transparent, %battTransparency%, Batt
;   WinSet, Transparent, %memTransparency%, Mem
;   WinSet, Transparent, %cpuTransparency%, Cpu
Return

CREATECLOCKWINDOW:
   ; 1: Windows for the clock text
    Gui, 1:+LastFound +AlwaysOnTop +ToolWindow -SysMenu -Caption
    Gui, 1:Color, %clockBGColor%
    Gui, 1:Font, c%clockFontColor% %clockFontStyle%, %clockFont%
   Gui, 1:Add,Text,vDate y%txtY% x%txtX%, %clockText%
    Gui, 1:Show,NoActivate x%xPos% y%yPos% ,%windowTitle%
    WinSet, Region, %regionMargin%-0 W%clockWidth% H%height% R5-5, %windowTitle%

   ; 6: Window for the batt progress bar
   Gui, 6:+LastFound +AlwaysOnTop +ToolWindow -SysMenu -Caption
   Gui, 6:Add, Progress, y0 x%progressBarPos% w%battProgressWidth% h%infoHeight% c%battBarColor% vBattBar Background%battBGColor%
    Gui, 6:Show,NoActivate x%battPos% y%yPos%, BattBarGui
    WinSet, Region, %regionMargin%-0 W%battWidth% H%infoHeight% R5-5, BattBarGui

   ; 2: Window for the batt text
   Gui, 2:+LastFound +AlwaysOnTop +ToolWindow -SysMenu -Caption
    Gui, 2:Color, %battBGColor%
    Gui, 2:Font, c%battFontColor% %infoFontStyle%, Webdings
    Gui, 2:Add,Text,vPlugged y-2 x%txtX%, x
    Gui, 2:Font, c%battFontColor% %infoFontStyle%, %infoFont%
    Gui, 2:Add,Text,vBatt y%txtY% w%battWidth% x46, %battinfo%`%
    Gui, 2:Show,NoActivate x%battPos% y%yPos%, Batt
    WinSet, Region, %regionMargin%-0 W%battWidth% H%infoHeight% R5-5, Batt
   WinSet, TransColor, %battBGColor%

   ; 7: Window for the memory progress bar
   Gui, 7:+LastFound +AlwaysOnTop +ToolWindow -SysMenu -Caption
   Gui, 7:Add, Progress, y0 x%progressBarPos% w%memProgressWidth% h%infoHeight% c%memBarColor% vMemBar Background%memBGColor%
    Gui, 7:Show,NoActivate x%memPos% y%yPos%, MemBarGui
    WinSet, Region, %regionMargin%-0 W%memWidth% H%infoHeight% R5-5, MemBarGui
   GuiControl, 7:, MemBar, 50

   ; 3: Window for the memory text
   Gui, 3:+LastFound +AlwaysOnTop +ToolWindow -SysMenu -Caption
    Gui, 3:Color, %memBGColor%
    Gui, 3:Font, c%memFontColor% %infoFontStyle%, %infoFont%
    Gui, 3:Add,Text,vMem y%txtY% x%txtX%, %memText%
    Gui, 3:Show,NoActivate x%memPos% y%yPos% ,Mem
    WinSet, Region, %regionMargin%-0 W%memWidth% H%infoHeight% R5-5, Mem
   WinSet, TransColor, %memBGColor%

   ; 5: Window for the cpu progress bar
   Gui, 5:+LastFound +AlwaysOnTop +ToolWindow -SysMenu -Caption
   Gui, 5:Add, Progress, y0 x%progressBarPos% w%cpuProgressWidth% h%infoHeight% c%cpuBarColor% vCpuBar Background%cpuBGColor%
    Gui, 5:Show,NoActivate x%cpuPos% y%yPos%, CpuBarGui
    WinSet, Region, %regionMargin%-0 W%cpuWidth% H%infoHeight% R5-5, CpuBarGui

   ; 4: Window for the cpu text
   Gui, 4:+LastFound +AlwaysOnTop +ToolWindow -SysMenu -Caption
    Gui, 4:Color, %cpuBGColor%
    Gui, 4:Font, c%cpuFontColor% %infoFontStyle%, %infoFont%
    Gui, 4:Add,Text,vCpu y%txtY% x%txtX%, %cpuText%
    Gui, 4:Show,NoActivate x%cpuPos% y%yPos% ,Cpu
    WinSet, Region, %regionMargin%-0 W%cpuWidth% H%height% R5-5, Cpu
   WinSet, TransColor, %cpuBGColor%
Return


UPDATECLOCK:
   if (savedScreenWidth <> A_ScreenWidth)
   {
      ; I switch recolution often on my laptop so thats why I added this.
       Gosub, CalculatePositions
       Gui, 1:Hide
       Gui, 2:Hide
       Gui, 3:Hide
       Gui, 4:Hide
       Gui, 5:Hide
       Gui, 6:Hide
       Gui, 7:Hide
      ; These will be shown again by the KEEPONTOP sub
    }
   FormatTime, clockText ,, %timeFormat%
    GuiControl, 1:,Date, %clockText%
Return

UPDATEBATTERY:
    battinfo := GetPowerStatus(acLineStatus)
    If (acLineStatus > 0)
    {
        GuiControl,2:,Plugged, ~
      Gui, 2:Font, c%battFontColor%
      GuiControl, 6: +Background%battBGColor%, BattBar
      GuiControl, 6: +c%battBarColor%, BattBar
    }
    Else
    {
        GuiControl,2:,Plugged, x
        if (battinfo < alertbattLevel)
      {
         Gui, 2:Font, c%battFontColorAlert%
         GuiControl, 6: +Background%battBGColorAlert%, BattBar
         GuiControl, 6: +c%battBarColorAlert%, BattBar
      }
    }
    GuiControl, 2:Font, Batt  ; Put the above font into effect for a control.
    GuiControl, 2:,Batt,%battinfo%`%
   GuiControl, 6:, BattBar, %battinfo%
Return

UPDATECPU:
    IdleTime0 = %IdleTime%  ; Save previous values
    Tick0 = %Tick%
    DllCall("kernel32.dll\GetSystemTimes", "uint",&IdleTicks, "uint",0, "uint",0)
    IdleTime := *(&IdleTicks)
    Loop 7                  ; Ticks when Windows was idle
        IdleTime += *( &IdleTicks + A_Index ) << ( 8 * A_Index )
    Tick := A_TickCount     ; Ticks all together
    load := 100 - 0.01*(IdleTime - IdleTime0)/(Tick - Tick0)
    SetFormat, Float, 0.2
    load += 0

   If (load > cpuThreshold)
   {
      Gui, 4:Font, c%cpuFontColorAlert%
      GuiControl, 5: +Background%cpuBGColorAlert%, CpuBar
      GuiControl, 5: +c%cpuBarColorAlert%, CpuBar
   }
    Else
    {
      Gui, 4:Font, c%cpuFontColor%
      GuiControl, 5: +Background%cpuBGColor%, CpuBar
      GuiControl, 5: +c%cpuBarColor%, CpuBar
   }
    GuiControl, 4:Font, Cpu  ; Put the above font into effect for a control.
    GuiControl, 4:, Cpu, %cpuLabel%%load%`%
   GuiControl, 5:, CpuBar, %load%

   ; --- Calculate memory
    DllCall("kernel32.dll\GlobalMemoryStatus", "uint",&memstatus)
    mem := *( &memstatus + 4 ) ; last byte is enough, mem = 0..100
   If (mem > memThreshold)
   {
      Gui, 3:Font, c%memFontColorAlert%
      GuiControl, 7: +Background%memBGColorAlert%, MemBar
      GuiControl, 7: +c%memBarColorAlert%, MemBar
   }
    Else
    {
      Gui, 3:Font, c%memFontColor%
      GuiControl, 7: +Background%memBGColor%, MemBar
      GuiControl, 7: +c%memBarColor%, MemBar
   }
    GuiControl, 3:Font, Mem
    GuiControl, 3:,Mem, %memLabel%%mem%`%
   GuiControl, 7:, MemBar, %mem%

Return


GetPowerStatus(ByRef acLineStatus)
{
    VarSetCapacity(powerstatus, 1+1+1+1+4+4)
    success := DllCall("kernel32.dll\GetSystemPowerStatus", "uint", &powerstatus)
    acLineStatus:=ReadInteger(&powerstatus,0,1,false)
    battFlag:=ReadInteger(&powerstatus,1,1,false)
    battLifePercent:=ReadInteger(&powerstatus,2,1,false)
    battLifeTime:=ReadInteger(&powerstatus,4,4,false)
    battFullLifeTime:=ReadInteger(&powerstatus,8,4,false)
   Return battLifePercent
}


ReadInteger( p_address, p_offset, p_size, p_hex=true )
{
    value = 0
    old_FormatInteger := a_FormatInteger
    if ( p_hex )
        SetFormat, integer, hex
    else
        SetFormat, integer, dec
    loop, %p_size%
        value := value+( *( ( p_address+p_offset )+( a_Index-1 ) ) << ( 8* ( a_Index-1 ) ) )
    SetFormat, integer, %old_FormatInteger%
    return, value
}


Max(In_Val1,In_Val2)
{
   IfLess In_Val1,%In_Val2%, Return In_Val2
   Return In_Val1
}

Min(In_Val1,In_Val2)
{
   IfLess In_Val1,%In_Val2%, Return In_Val1
   Return In_Val2
}

INIREAD:
   IfNotExist,%applicationname%.ini
   {
      clockFont := "Verdana"
      fontSize := 10
      clockFontColor := "Silver"
      clockBGColor := "Black"

      infoFontSize := 10
      infoFont := "Tahoma"

      battFontColor := "Lime"
      battFontColorAlert := "Yellow"
      battBGColor := "Black"
      battBGColorAlert := "Maroon"
      battBarColor := "Green"
      battBarColorAlert := "Red"
      alertbattLevel := 10

      memFontColor := "Fuchsia"
      memFontColorAlert := "Yellow"
      memBGColor := "Black"
      memBGColorAlert := "Maroon"
      memBarColor := "Purple"
      memBarColorAlert := "Red"
      memThreshold := 80

      cpuFontColor := "Aqua"
      cpuFontColorAlert := "Yellow"
      cpuBGColor := "Black"
      cpuBGColorAlert := "Maroon"
      cpuBarColor := "Blue"
      cpuBarColorAlert := "Red"
      cpuThreshold := 80
      margin := 2
      transparency := 200
      memLabel := "Mem: "
      cpuLabel := "Cpu: "
      timeFormat := "ddd dd MMM yyyy HH:mm:ss"
      Gosub,INIWRITE
   }
   IniRead,clockFont,%applicationname%.ini,Settings,clockFont
   IniRead,fontSize,%applicationname%.ini,Settings,fontSize
   IniRead,clockFontColor,%applicationname%.ini,Settings,clockFontColor
   IniRead,clockBGColor,%applicationname%.ini,Settings,clockBGColor
   IniRead,infoFontSize,%applicationname%.ini,Settings,infoFontSize
   IniRead,infoFont,%applicationname%.ini,Settings,infoFont
   IniRead,battFontColor,%applicationname%.ini,Settings,battFontColor
   IniRead,battFontColorAlert,%applicationname%.ini,Settings,battFontColorAlert
   IniRead,battBGColor,%applicationname%.ini,Settings,battBGColor
   IniRead,battBGColorAlert,%applicationname%.ini,Settings,battBGColorAlert
   IniRead,battBarColor,%applicationname%.ini,Settings,battBarColor
   IniRead,battBarColorAlert,%applicationname%.ini,Settings,battBarColorAlert
   IniRead,alertbattLevel,%applicationname%.ini,Settings,alertbattLevel
   IniRead,memFontColor,%applicationname%.ini,Settings,memFontColor
   IniRead,memFontColorAlert,%applicationname%.ini,Settings,memFontColorAlert
   IniRead,memBGColor,%applicationname%.ini,Settings,memBGColor
   IniRead,memBGColorAlert,%applicationname%.ini,Settings,memBGColorAlert
   IniRead,memBarColor,%applicationname%.ini,Settings,memBarColor
   IniRead,memBarColorAlert,%applicationname%.ini,Settings,memBarColorAlert
   IniRead,memThreshold,%applicationname%.ini,Settings,memThreshold
   IniRead,cpuFontColor,%applicationname%.ini,Settings,cpuFontColor
   IniRead,cpuFontColorAlert,%applicationname%.ini,Settings,cpuFontColorAlert
   IniRead,cpuBGColor,%applicationname%.ini,Settings,cpuBGColor
   IniRead,cpuBGColorAlert,%applicationname%.ini,Settings,cpuBGColorAlert
   IniRead,cpuBarColor,%applicationname%.ini,Settings,cpuBarColor
   IniRead,cpuBarColorAlert,%applicationname%.ini,Settings,cpuBarColorAlert
   IniRead,cpuThreshold,%applicationname%.ini,Settings,cpuThreshold
   IniRead,margin,%applicationname%.ini,Settings,margin
   IniRead,transparency,%applicationname%.ini,Settings,transparency
   IniRead,memLabel,%applicationname%.ini,Settings,memLabel
   IniRead,cpuLabel,%applicationname%.ini,Settings,cpuLabel
   IniRead,timeFormat,%applicationname%.ini,Settings,timeFormat
Return

INIWRITE:
   IniWrite,%clockFont%,%applicationname%.ini,Settings,clockFont
   IniWrite,%fontSize%,%applicationname%.ini,Settings,fontSize
   IniWrite,%clockFontColor%,%applicationname%.ini,Settings,clockFontColor
   IniWrite,%clockBGColor%,%applicationname%.ini,Settings,clockBGColor
   IniWrite,%infoFontSize%,%applicationname%.ini,Settings,infoFontSize
   IniWrite,%infoFont%,%applicationname%.ini,Settings,infoFont
   IniWrite,%battFontColor%,%applicationname%.ini,Settings,battFontColor
   IniWrite,%battFontColorAlert%,%applicationname%.ini,Settings,battFontColorAlert
   IniWrite,%battBGColor%,%applicationname%.ini,Settings,battBGColor
   IniWrite,%battBGColorAlert%,%applicationname%.ini,Settings,battBGColorAlert
   IniWrite,%battBarColor%,%applicationname%.ini,Settings,battBarColor
   IniWrite,%battBarColorAlert%,%applicationname%.ini,Settings,battBarColorAlert
   IniWrite,%alertbattLevel%,%applicationname%.ini,Settings,alertbattLevel
   IniWrite,%memFontColor%,%applicationname%.ini,Settings,memFontColor
   IniWrite,%memFontColorAlert%,%applicationname%.ini,Settings,memFontColorAlert
   IniWrite,%memBGColor%,%applicationname%.ini,Settings,memBGColor
   IniWrite,%memBGColorAlert%,%applicationname%.ini,Settings,memBGColorAlert
   IniWrite,%memBarColor%,%applicationname%.ini,Settings,memBarColor
   IniWrite,%memBarColorAlert%,%applicationname%.ini,Settings,memBarColorAlert
   IniWrite,%memThreshold%,%applicationname%.ini,Settings,memThreshold
   IniWrite,%cpuFontColor%,%applicationname%.ini,Settings,cpuFontColor
   IniWrite,%cpuFontColorAlert%,%applicationname%.ini,Settings,cpuFontColorAlert
   IniWrite,%cpuBGColor%,%applicationname%.ini,Settings,cpuBGColor
   IniWrite,%cpuBGColorAlert%,%applicationname%.ini,Settings,cpuBGColorAlert
   IniWrite,%cpuBarColor%,%applicationname%.ini,Settings,cpuBarColor
   IniWrite,%cpuBarColorAlert%,%applicationname%.ini,Settings,cpuBarColorAlert
   IniWrite,%cpuThreshold%,%applicationname%.ini,Settings,cpuThreshold
   IniWrite,%margin%,%applicationname%.ini,Settings,margin
   IniWrite,%transparency%,%applicationname%.ini,Settings,transparency
   IniWrite,%memLabel%,%applicationname%.ini,Settings,memLabel
   IniWrite,%cpuLabel%,%applicationname%.ini,Settings,cpuLabel
   IniWrite,%timeFormat%,%applicationname%.ini,Settings,timeFormat
Return

ExtractInteger(ByRef pSource, pOffset = 0, pIsSigned = false, pSize = 4)
; pSource is a string (buffer) whose memory area contains a raw/binary integer at pOffset.
; The caller should pass true for pSigned to interpret the result as signed vs. unsigned.
; pSize is the size of PSource's integer in bytes (e.g. 4 bytes for a DWORD or Int).
; pSource must be ByRef to avoid corruption during the formal-to-actual copying process
; (since pSource might contain valid data beyond its first binary zero).
{
    Loop %pSize%  ; Build the integer by adding up its bytes.
        result += *(&pSource + pOffset + A_Index-1) << 8*(A_Index-1)
    if (!pIsSigned OR pSize > 4 OR result < 0x80000000)
        return result  ; Signed vs. unsigned doesn't matter in these cases.
    ; Otherwise, convert the value (now known to be 32-bit) to its signed counterpart:
    return -(0xFFFFFFFF - result + 1)
}

;-----------------------------------------------------------------------------------------------------------------------
; Function: GetTextSize
; Calculate widht and/or height of text, taking the font style and face into account
;:
;
;
; Parameters:
;      pStr      - Text to be measured
;      pFont     - Font description in AHK syntax
;      pHeight   - Set to true to return height also. False is default.
;
; Returns:
;   Text width if pHeight=false. Otherwise, dimension is returned as "width,height"
;
; Example:
;      width := GetTextSize("string to be measured", "bold s22, Courier New" )
;
GetTextSize(pStr, pFont="", pHeight=false) {
   local height, weight, italic, underline, strikeout , nCharSet
   local hdc := DllCall("GetDC", "Uint", 0)
   local hFont, hOldFont

  ;parse font
   if (pFont != "") {
      italic      := InStr(pFont, "italic")
      underline   := InStr(pFont, "underline")
      strikeout   := InStr(pFont, "strikeout")
      weight      := InStr(pFont, "bold") ? 700 : 0

      RegExMatch(pFont, "(?<=[S|s])(\d{1,2})(?=[ ,])", height)
      if (height != "")
         height := -DllCall("MulDiv", "int", height, "int", DllCall("GetDeviceCaps", "Uint", hDC, "int", 90), "int", 72)

      RegExMatch(pFont, "(?<=,).+", fontFace)
      fontFace := RegExReplace( fontFace, "(^\s+)|(\s+$)")      ;trim

      ;   msgbox "%fontFace%" "%italic%" "%underline%" "%strikeout%" "%weight%" "%height%"
   }


 ;create font
   hFont   := DllCall("CreateFont", "int", height, "int", 0, "int", 0, "int", 0
                           ,"int", weight, "Uint", italic, "Uint", underline
                           ,"uint", strikeOut, "Uint", nCharSet, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", fontFace)
   hOldFont := DllCall("SelectObject", "Uint", hDC, "Uint", hFont)
   DllCall("GetTextExtentPoint32", "Uint", hDC, "str", pStr, "int", StrLen(pStr), "int64P", nSize)
;   DllCall("DrawTextA", "Uint", hDC, "str", pStr, "int", StrLen(pStr), "int64P", nSize, "uint", 0x400)


 ;clean

   DllCall("SelectObject", "Uint", hDC, "Uint", hOldFont)
   DllCall("DeleteObject", "Uint", hFont)
   DllCall("ReleaseDC", "Uint", 0, "Uint", hDC)

   nWidth  := nSize & 0xFFFFFFFF
   nHeight := nSize >> 32 & 0xFFFFFFFF


   if (pHeight)
      nWidth .= "," nHeight
   return   nWidth
}

KEEPONTOP:
   Gui, 1:Show, NA x%xPos% y%yPos%, %windowTitle%
   Gui, 6:Show, NA x%battPos% y%yPos% ,BattBarGui
   Gui, 2:Show, NA x%battPos% y%yPos%, Batt
   Gui, 7:Show, NA x%memPos% y%yPos% ,MemBarGui
   Gui, 3:Show, NA x%memPos% y%yPos% ,Mem
   Gui, 5:Show, NA x%cpuPos% y%yPos% ,CpuBarGui
   Gui, 4:Show, NA x%cpuPos% y%yPos% ,Cpu
Return

ExitSub:
ExitApp