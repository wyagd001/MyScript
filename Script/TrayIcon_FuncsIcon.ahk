OnTrayIcon(Hwnd, Event)
{
	if (Event != "L")		; 不是左键直接返回
	return

	if Hwnd=101
	{
		gosub cliphistoryPI
	return
	}
	if Hwnd=102
	{
		send ^{F2}
	return
	}
}