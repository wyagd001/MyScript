/*
MouseLeave(wParam, lParam, msg, hwnd)
{
Global
If (hwnd = SampleButton1_hwnd)
    AddGraphicButton("SampleButton1", A_ScriptDir . "\pic\prev.bmp", "x153 y33 h27 w48 gprev",21, 40)
      If (hwnd = SampleButton2_hwnd)
    AddGraphicButton("SampleButton2", A_ScriptDir . "\pic\pause.bmp", "x201 y33 h27 w48 gprev",21, 40)
     If (hwnd = SampleButton3_hwnd)
    AddGraphicButton("SampleButton3", A_ScriptDir . "\pic\next.bmp", "x249 y33 h27 w48 gprev",21, 40)
      If (hwnd = SampleButton4_hwnd)
    AddGraphicButton("SampleButton4", A_ScriptDir . "\pic\close.bmp", "x297 y33 h27 w48 gprev",21, 40)
Return
}

   Mousedown(wParam, lParam, msg, hwnd)
{
Global
If (hwnd = SampleButton1_hwnd)
    AddGraphicButton("SampleButton1", A_ScriptDir . "\pic\d_prev.bmp", "x153 y33 h27 w48 gprev",21, 40)
      If (hwnd = SampleButton2_hwnd)
    AddGraphicButton("SampleButton2", A_ScriptDir . "\pic\d_pause.bmp", "x201 y33 h27 w48 gprev",21, 40)
      If (hwnd = SampleButton3_hwnd)
    AddGraphicButton("SampleButton3", A_ScriptDir . "\pic\d_next.bmp", "x249 y33 h27 w48 gprev",21, 40)
      If (hwnd = SampleButton4_hwnd)
    AddGraphicButton("SampleButton4", A_ScriptDir . "\pic\d_close.bmp", "x297 y33 h27 w48 gprev",21, 40)
Return
}

MouseMove(wParam, lParam, msg, hwnd)
{
Global
Static _LastButtonData = true
If (hwnd = SampleButton1_hwnd)
    If (_LastButtonData != SampleButton1_hwnd)
      AddGraphicButton("SampleButton1", A_ScriptDir . "\pic\h_prev.bmp", "x153 y33 h27 w48 gprev", 21, 40)

   If (hwnd = SampleButton2_hwnd)
    If (_LastButtonData != SampleButton2_hwnd)
      AddGraphicButton("SampleButton2", A_ScriptDir . "\pic\h_pause.bmp", "x201 y33 h27 w48 gprev", 21, 40)
       If (hwnd = SampleButton3_hwnd)
    If (_LastButtonData != SampleButton3_hwnd)
      AddGraphicButton("SampleButton3", A_ScriptDir . "\pic\h_next.bmp", "x249 y33 h27 w48 gprev", 21, 40)
   If (hwnd = SampleButton4_hwnd)
    If (_LastButtonData != SampleButton4_hwnd)
      AddGraphicButton("SampleButton4", A_ScriptDir . "\pic\h_close.bmp", "x297 y33 h27 w48 gprev", 21, 40)
_LastButtonData := hwnd
Return
}

AddGraphicButton(VariableName, ImgPath, Options="",bHeight=27, bWidth=48)
{
Global
Local ImgType, ImgType1, LR_LOADFROMFILE, NULL, BM_SETIMAGE
; BS_BITMAP := 128, IMAGE_BITMAP := 0, BS_ICON := 64, IMAGE_ICON := 1
LR_LOADFROMFILE := 16
BM_SETIMAGE := 247
NULL=
SplitPath, ImgPath,,, ImgType1
ImgTYpe := (ImgType1 = "bmp") ? 128 : 64
If (%VariableName%_img != "")
DllCall("DeleteObject", "UInt", %VariableName%_img)
Else
Gui, Add, Button, v%VariableName% hwnd%VariableName%_hwnd +%ImgTYpe% %Options%
ImgType := (ImgType1 = "bmp") ? 0: 1
%VariableName%_img := DllCall("LoadImage", "UInt", NULL, "Str", ImgPath, "UInt", ImgType, "Int", bWidth, "Int", bHeight, "UInt", LR_LOADFROMFILE, "UInt")
DllCall("SendMessage", "UInt", %VariableName%_hwnd, "UInt", BM_SETIMAGE, "UInt", ImgType, "UInt", %VariableName%_img)
Return, %VariableName%_img ; Return the handle to the image
}
*/

MouseMove(wParam, lParam, msg, hwnd)
{
   Global
   if !visable
   {
    sleep, 50
   return
   }

   local Current_Hover_Image
   local Current_Main_Image
   local Current_GUI
   loop, parse, Graphic_Button_List, |
   {
      
      Current_GUI := %a_loopField%_GUI_Number
      If (hwnd = %a_loopField%_HWND) and (%a_loopField%LastButtonData1 != %a_loopField%_HWND)
      {
         Current_Hover_Image := %a_loopField%_Hover_Image
         guicontrol, %Current_GUI%:, %a_loopField%, %Current_Hover_Image%
         %a_loopField%LastButtonData1 := hwnd
      }
      else if(hwnd != %a_loopField%_HWND) and (%a_loopField%LastButtonData1 = %a_loopField%_HWND)
      {
         Current_Up_Image := %a_loopField%_Up_Image
         guicontrol, %Current_GUI%:, %a_loopField%, %Current_Up_Image%
         %a_loopField%LastButtonData1 := hwnd
         %a_loopField%LastButtonData2 =
       tooltip,
      }
   }
   Return
}

MouseLDown(wParam, lParam, msg, hwnd)
{
   Global
   if !visable
   {
    sleep, 50
   return
   }
   Local Current_Down_Image
   Local Current_GUI
      if (A_Gui>50 &&  A_Gui<fi+50){
       ;Êó±ê×ó¼üµã»÷ºóÄÜÍÏ×§ÒÆ¶¯´°¿Ú
       PostMessage, 0xA1, 2
    }
   else
 {
   loop, parse, Graphic_Button_List, |
   {
      If (hwnd = %a_loopField%_HWND) and (%a_loopField%LastButtonData2 != %a_loopField%_HWND)
      {
         Current_GUI := %a_loopField%_GUI_Number
         Current_Down_Image := %a_loopField%_Down_Image
         guicontrol, %Current_GUI%:, %a_loopField%, %Current_Down_Image%
         %a_loopField%LastButtonData2 := hwnd
         break
      }
   }
 }
   Return
}

MouseLUp(wParam, lParam, msg, hwnd)
{
   Global
   if !visable
   {
    sleep, 50
   return
   }
   local Current_Main_Image
   Local Current_GUI
   loop, parse, Graphic_Button_List, |
   {
      If (hwnd = %a_loopField%_HWND) and (%a_loopField%LastButtonData2 = %a_loopField%_HWND)
      {
         Current_GUI := %a_loopField%_GUI_Number
         Current_Hover_Image := %a_loopField%_Hover_Image
         guicontrol, %Current_GUI%:, %a_loopField%, %Current_Hover_Image%
         %a_loopField%LastButtonData2 =
         GOSUB % a_loopField . "_Down_Up"
         break
      }
   }
   Return
}

AddGraphicButton(GUI_Number, Button_X, Button_Y, Button_H, Button_W, Button_Identifier, Button_Up, Button_Hover, Button_Down)
{
   Global
   if(Graphic_Button_List = "")
      Graphic_Button_List .= Button_Identifier
   else
      Graphic_Button_List .= "|" . Button_Identifier
   current_Button_HWND := Button_Identifier . "_hwnd"
   %Button_Identifier%_Up_Image := Button_Up
   %Button_Identifier%_Hover_Image := Button_Hover
   %Button_Identifier%_Down_Image := Button_Down
   %Button_Identifier%_GUI_Number := GUI_Number
   Gui, %GUI_Number%:Add, Picture, +altsubmit %Button_X% %Button_Y% %Button_H% %Button_W% g%Button_Identifier%_Down v%Button_Identifier% hwnd%current_Button_HWND%, %Button_Up%
}