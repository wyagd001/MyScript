Update:
/*
0x40 INTERNET_CONNECTION_CONFIGURED - Local system has a valid connection to the Internet, but not be currently connected.
0x02 INTERNET_CONNECTION_LAN - Local system uses a local area network to connect to the Internet.
0x01 INTERNET_CONNECTION_MODEM - Local system uses a modem to connect to the Internet.
0x08 INTERNET_CONNECTION_MODEM_BUSY - No longer used.
0x20 INTERNET_CONNECTION_OFFLINE - Local system is in offline mode.
0x04 INTERNET_CONNECTION_PROXY - Local system uses a proxy server to connect to the Internet

*/
;connected:=DllCall("Wininet.dll\InternetGetConnectedState", "Str", 0x40,"Int",0)
;DllCall("SENSAPI.DLL\IsDestinationReachableA" , Str,"www.google.com", Int,0 )
URL := "http://www.baidu.com"
If InternetCheckConnection(URL)
{
	WinHttp.URLGet("https://raw.githubusercontent.com/wyagd001/MyScript/master/version.txt",,, update_txtFile)
	IfNotExist,%update_txtFile%
	{
		msgbox,,升级通知,无法下载更新文件，请检查您的网络连接。
	return
	}
	FileGetSize, sizeq,%update_txtFile%
	if(sizeq>20)
	{
		msgbox,,升级通知,下载的更新文件大小不符，请检查您的网络连接。
		FileDelete, %update_txtFile%
	return
	}
	FileRead, CurVer, %update_txtFile%
	If not ErrorLevel
	{
		FileDelete, %update_txtFile%
		if(CurVer!=AppVersion)
		{
			msgbox,262148,升级通知,当前版本为:%AppVersion%`n最新版本为:%CurVer%`n是否前往主页下载？
			IfMsgBox Yes
				Run,https://github.com/wyagd001/MyScript
		return
		}
		else
		{
			msgbox,262144,升级通知,该版本已是最新版本:%AppVersion%。
		return
		}
	}
}
else
	msgbox,,升级通知,无法连接网络，请检查您的网络连接。
return

InternetCheckConnection(Url="",FIFC=1) {
Return DllCall("Wininet.dll\InternetCheckConnection", Str,Url, Int,FIFC, Int,0)
}