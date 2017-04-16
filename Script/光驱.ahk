driver:
list=%1%
If 0=0
DriveGet,list,List,CDROM
Loop,Parse,list
{
  if A_GuiControl =openCD
{
     Drive,Eject,%A_LoopField%:
}
  else 
{
 Drive,Eject,%A_LoopField%:,1
}
}
return