LB_QueryCursor(byRef cID)
{
	LB_GETCURSEL = 0x188
	NULL = 0x0
	SendMessage, LB_GETCURSEL, NULL, NULL,, ahk_id %cID%
;MsgBox, EL: %ErrorLevel%
return ( ErrorLevel <> "FAIL" ? ErrorLevel + 1 : 0 )
}

LB_SelectItem( cID, item="" )
{
	LB_SETSEL = 0x0185
	NULL = 0x0
	item:=(item="") ? LB_QueryCursor(cID) : item
	SendMessage, LB_SETSEL, TRUE, % item - 1,, ahk_id %cID%
return
}

LB_CountAllItems(cID)
{
	LB_GETCOUNT = 0x18B
	NULL = 0x0
	SendMessage, LB_GETCOUNT, NULL, NULL,, ahk_id %cID%
return ( ErrorLevel <> "FAIL" ? ErrorLevel : 0 )
}

LB_CountSelected(cID)
{
	LB_GETSELCOUNT = 0x190
	NULL = 0x0
	SendMessage LB_GETSELCOUNT, NULL, NULL,, ahk_id %cID%
return ( ErrorLevel <> "FAIL" ? ErrorLevel : 0 )
}

LB_QListSelected(cID, count="")
{
	LB_GETSELITEMS = 0x191

	if( count=="" && !(count:=LB_CountSelected( cID )) )
		return 0
	VarSetCapacity(selectedList, count * 4, 0 )
	SendMessage, LB_GETSELITEMS, %count%, &selectedList,, ahk_id %cID%
return selectedList
}

LB_QueryText(cID, cPos)
{
	LB_GETTEXT = 0x189
	VarSetCapacity(text,512)
	SendMessage, LB_GETTEXT, % cPos - 1, &text,, ahk_id %cID%
return text
}