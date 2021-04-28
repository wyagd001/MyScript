#ifwinactive, ahk_Group AppMainWindow
~@::
sleep,200
GuiControlGet, EditContent,,dir
if EditContent=@
{
Tmp_ComboBoxShowItems:="@ExeAhk@|@Cmd@|@Proxy@|@regedit@|@转换@UrlDecode@|@转换@UrlEncode@|@转换@10→16@|@转换@16→10@|@转换@农历→公历@|@转换@公历→农历@|@转换@简→繁@|@转换@繁→简@"
GuiControl, , dir, |%Tmp_ComboBoxShowItems%
changeComboBox=1
send @
settimer,huifu_ComboBox,-40000
}
return

~#::
sleep,200
GuiControlGet, EditContent,,dir
if EditContent=#
{
Tmp_ComboBoxShowItems=
Loop, Files, %A_ScriptDir%\favorites\*.*,FR
{
	SplitPath,A_LoopFileName, , , , Tmp_Val
	Tmp_ComboBoxShowItems.= Tmp_Val "|"
}
Sort, Tmp_ComboBoxShowItems,D|
GuiControl, , dir, |%Tmp_ComboBoxShowItems%
changeComboBox=1
favorites_link=1
settimer,huifu_ComboBox,-40000
}
return
#ifwinactive

huifu_ComboBox:
if changeComboBox=1
{
GuiControl, , dir, |%ComboBoxShowItems%
changeComboBox=0
favorites_link=0
}
return