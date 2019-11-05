Cando_FileToHttpServer:
	HttpServer_File     := CandySel
	HttpServer_FileName := CandySel_FileNameWithExt
	CF_ToolTip("文件已设置为服务器文件。`n请在手机(/PC)上使用Tasker或浏览器下载。", 5000)
return

Cando_FileToFlaskandTasker:
	HttpServer_File     := CandySel
	HttpServer_FileName := CandySel_FileNameWithExt
	WinHttp.URLGet("http://192.168.1.214:10000/ahkhttpupload")
return