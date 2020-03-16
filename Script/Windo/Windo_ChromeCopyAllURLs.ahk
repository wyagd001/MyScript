Windo_ChromeCopyAllURLs:
	tmp_v := ""
	URLs := {}
	loop,50
	{
		URLs[A_index] := GetBrowserURL_ACC(Windy_CurWin_Class)
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
		tmp_v .= v "`r`n"
	Clipboard := tmp_v
	sleep,10
	tmp_v := ""
	URLs := {}
	CF_ToolTip("所有标签页网址已复制到剪贴板。", 3000)
return
