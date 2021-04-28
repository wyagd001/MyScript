MG_OpenCD:
DriveGet, CdList, List, CDROM
Loop, Parse, CdList
{
	if A_GuiControl = openCD
	{
		Drive, Eject, %A_LoopField%:
	}
	else 
	{
		Drive, Eject, %A_LoopField%:, 1
	}
}
return