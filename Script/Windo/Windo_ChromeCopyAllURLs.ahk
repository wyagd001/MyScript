Windo_ChromeCopyAllURLs:
	Tmp_Val := ""
	URLs := []
	loop,50
	{
		URLs[A_index] := GetBrowserURL_ACC_byhwnd(Windy_CurWin_id)
		sleep, 20
		if (A_index != 1) && (URLs[A_index] = URLs[1])
		{
			URLs.RemoveAt(A_index)
			break
		}
		sleep, 200
		send ^{Tab}
		Continue
	}
	for k,v in URLs
		Tmp_Val .= v "`r`n"
	Clipboard := trim(Tmp_Val, "`r`n")
	sleep,10
	Tmp_Val := ""
	URLs := []
	;CF_ToolTip("所有标签页网址已复制到剪贴板。", 3000)
return
