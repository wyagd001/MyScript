indexInit:
mytext:=CF_IniRead(run_iniFile, "serverConfig","mytext")
SplitPath, txtfile, txtFileName
SplitPath, excelfile, excelFileName
Index_Html =
(
<!doctype html>
<html>
<head>
<link rel="shortcut icon" href="/favicon" type="image/x-icon" />
<title> 网页控制 </title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<style>
p {
  font-family: sans-serif;
  font-size: %textFontSize%;
}

button {
  font-family: sans-serif;
  font-size: %buttonSize%;
  height: 50px;
  vertical-align:middle;
}

h1 {
	padding: %pagePadding%; width: auto; font-family: Sans-Serif; font-size: 22pt;
}

body {
	background-color : black ;
	color : yellow ;
	padding: %pagePadding%; width: auto; font-family: Sans-Serif; font-size: 16pt;
}

</style>
<script type="text/javascript">
window.onload=function wyreload(){
var url=window.location.href;
var loc = url.substring(url.lastIndexOf('/')+1, url.length); 
if (loc !== "")
{
window.location.href="/";
}
}
</script>
</head>
<body>
<p>正在播放</p>
<h1>
%NowPlaying%
</h1>

<p>播放器控制</p>
<p>
<a href="/startaudioplayer"> <button> 播放器 </button>  </a> 
<a href="/previous"> <button> 上一首 </button>  </a> 
<a href="/pause_play"> <button> 播放/暂停 </button> </a>
<a href="/next"> <button> 下一首 </button> </a>
<a href="/exitapp"> <button> 退出 </button> </a>
<a href="/"> <button> 主页 </button> </a>
</p>
<p>
<a href="/vp"> <button> 音量+ </button> </a>
<a href="/vm"> <button> 音量- </button> </a>
<a href="/u_m"> <button> 静音 </button> </a>
<a href="/vhigh"> <button> 80`% </button> </a>
<a href="/vmed"> <button> 50`% </button> </a>
<a href="/vlow"> <button> 20`% </button> </a>
</p>

<p> &nbsp; </p>

<p>系统控制</p>

<p>
<a href="/standby"> <button> 待机 </button> </a>
<a href="/hibernate"> <button> 休眠 </button> </a>
<a href="/reloadpc"> <button> 重启 </button> </a>
<a href="/shutdownpc"> <button> 关机 </button> </a>
<a href="/monitoronoff"> <button> 屏幕开关 </button> </a>
</p>
<p>
<a href="/logout"> <button>退出网页控制登录</button> </a>
<a href="/serverreload"> <button> 重启服务 </button> </a>
</p>

<p> &nbsp; </p>

<p>文件下载</p>
<p> 
<a href="/mp3"> <button>mp3</button> </a> 
<a href="/excel" download="%excelFileName%"> <button>xls</button> </a>
<a href="/txt" download="%txtFileName%"> <button>txt</button> </a>
<a href="/downfile"> <button>文件(Cando)</button> </a>
<a href="/printscreentodown"> <button>电脑截屏</button> </a>
</p>
<p> &nbsp; </p>

<p>文件上传</p>
<form action="/upload" method="POST" enctype="multipart/form-data">  
 <input type="file" name="file" style="width:700px; height:55px; color:#c2c2c2; background-color: white; vertical-align:middle;" />  
<span>
 <input type="submit" style="width:80px; height:58px; vertical-align:middle;" value="上传" />
</span>
</form>  
<p> &nbsp; </p>

<p>发送文本</p>
<form action="/submit" method="get">
<input type="text" id="1234" name="mytext" style="width:694px; height:50px; vertical-align:middle;" value="%mytext%" />
<span>
<input type="submit" style="width:80px; height:55px; vertical-align:middle;" value="保存文字" />  
</span>
</form>
<p> &nbsp; </p>

<p>运行命令</p>
<!--select标签和input外面的span标签的格式是为了使两个位置在同一位置，控制位置-->
<!--有name属性都会提交-->
<form action="/runcom" method="get">
<span style="position:absolute;border:1pt solid #c1c1c1;overflow:hidden;width:699px;height:55px;">
<select name="aabb" id="aabb" style="width:699px;height:55px;" 
onChange="javascript:document.getElementById('ccdd').value=document.getElementById('aabb').options[document.getElementById('aabb').selectedIndex].value;">
<!--下面的option的样式是为了使字体为灰色，只是视觉问题，看起来像是注释一样-->
<option value="" style="color:#c2c2c2;">---请选择---</option>
<option value="%stableitem1%">hichat2626</option>
<option value="%stableitem2%">关机</option>
<option value="%stableitem3%">项目三</option>
<option value="%stableitem4%">项目四</option>
<option value="%stableitem5%">项目五</option>
</select> 
</span> 
<span style="position:absolute;border-top:1pt solid #c1c1c1;border-left:1pt solid #c1c1c1;border-bottom:1pt solid #c1c1c1;width:665px;height:50px;"><input type="text" name="ccdd" id="ccdd" style="width:665px; height:50px;" placeholder="请输入要运行的内容, 回车提交" /></span>
<span><input type="submit" style="width:80px; height:55px; vertical-align:middle;" value="提交" /></span>
</form>

</body>
</html>
)

SiteContents =
(LTrim
	<!DOCTYPE html>
	<html>
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width">
			<title>网页控制</title>
			<style>
				html {
					font-family: Ubuntu;
				}
				body {
					margin:25px;
					margin-top:5px;
				}
				h4 {
					font-size: 20px;
					color:green;
				}
				h5 {
					font-size: 16px;
					color:teal;
				}
			</style>
			<script type="text/javascript">
				[ScriptTagContents]
			</script>
		</head>
		<body>
			[BodyTagContents]
		</body>
	</html>
)

global UserLogin
global UserPass
global StoredReqBody
global HttpServer_File :=
global HttpServer_FileName :=

if indexInit_activated
	Return	;to return only after first initilisation,i.e from a 'Gosub'
indexInit_activated++

paths := {}
paths["/"] := Func("Index")
paths["/logo"] := Func("Logo")
paths["/favicon"] := Func("favicon")
paths["/page"] := Func("MainPage")

paths["/startaudioplayer"] := Func("startaudioplayer")
paths["/previous"] := Func("previous")
paths["/pause_play"] := Func("pause_play")
paths["/next"] := Func("next")
paths["/exitapp"] := Func("exitapp")
paths["/music"] := Func("Func_music")

paths["/vp"] := Func("vp")
paths["/vm"] := Func("vm")
paths["/u_m"] := Func("u_m")
paths["/vhigh"] := Func("vHigh")
paths["/vmed"] := Func("vMed")
paths["/vlow"] := Func("vLow")

paths["/standby"] := Func("standby")
paths["/hibernate"] := Func("hibernate")
paths["/monitoronoff"] := Func("monitorOnOff")
paths["/shutdownpc"] := Func("shutdownPC")
paths["/reloadpc"] := Func("ReloadPC")

paths["/logout"] := Func("logout")
paths["/serverreload"] := Func("serverReload")

paths["/submit"] := Func("submit")
paths["/runcom"] :=Func("runcom")
paths["/runCmd"] := Func("Func_runCmd")
paths["/setclip"] := Func("Func_setClip")
paths["/getclip"] := Func("Func_getClip")
paths["/getchromeurl"] := Func("Func_getchromeUrl")

paths["/mp3"] := Func("mp3")
paths["/excel"] := Func("excel")
paths["/txt"] := Func("txt")
paths["/downfile"] := Func("Func_downFile")
paths["/downfilename"] := Func("Func_downFileName")
paths["/printscreentodown"] := Func("printscreenToDown")
paths["/upload"] := Func("upload")
paths["/downClientFile"] := Func("Fun_downClientFile")

paths["404"] := Func("NotFound")

global server := new HttpServer()
server.LoadMimes(A_ScriptDir . "/lib/mime.types")
server.SetPaths(paths)
server.Serve(serverPort)
global clientWebServerUrl := "http://192.168.1.214:10000"
global urlUtil := new URI()
return

Logo(ByRef req, ByRef res, ByRef server) {
    server.ServeFile(res, A_ScriptDir . "/pic/logo.png")
    res.status := 200
}

favicon(ByRef req, ByRef res, ByRef server) {
    server.ServeFile(res, A_ScriptDir . "/pic/favicon.ico")
    res.status := 200
}

;获取正在播放的歌曲  暂只支持 foobar2000和ahkplayer
Index(ByRef req, ByRef res) {
Global
if loginpass
{
NowPlaying:=""
DetectHiddenWindows, On
SetTitleMatchMode,2
activeplayer:=activeplayer(DefaultPlayer)
sleep,1500
WinGetTitle, NowPlaying, % " - " activeplayer

	Gosub, indexInit	;to refresh page
    res.SetBodyText(Index_Html)
    res.status := 200
}
else
{
ContentsOfScript = <!--...-->
ContentsToDisplay=
	(LTrim
		<div class="container" align="center">
			<section id="content">
				<form action="/page" method="post">
					<h4>登录</h4>
					<div id="username">
						<input type="text" placeholder="用户名" required="" name="username" />
					</div>
					<div id="password">
						<input type="password" placeholder="密码" required="" name="password" />
					</div>
					<br />
					<div id="button1">
						<input type="submit" value="登录" />
					</div>
				</form>
				<div class="button">
				</div>
			</section>
		</div>
	)
	StringReplace, ServeTemp, SiteContents, [ScriptTagContents], %ContentsOfScript%, All
	StringReplace, Serve, ServeTemp, [BodyTagContents], %ContentsToDisplay%, All
	res.SetBodyText(Serve)
	res.status := 200
}
}

MainPage(ByRef req, ByRef res){
Global
	UserLogin = ;Wipe all contents
	UserPass = ;Wipe all contents
	HttpReqBodyArray := "" ;Release the object
	HttpReqBodyArray := Object()
	For each, Pair in StrSplit(req.body,"&")
	{
		Part := StrSplit(Pair, "=")
		HttpReqBodyArray.Push([Part[1], Part[2]])
	}
	UserLogin := HttpReqBodyArray[1,2]
	UserPass := HttpReqBodyArray[2,2]
	If (UserLogin != StoredLogin) || (UserPass != StoredPass)
	{
		ContentsToDisplay = <p>用户名或密码错误</p>
	StringReplace, ServeTemp, SiteContents, [ScriptTagContents], %ContentsOfScript%, All
	StringReplace, Serve, ServeTemp, [BodyTagContents], %ContentsToDisplay%, All
	res.SetBodyText(Serve)
	res.status := 200
	}
	Else
	{
LoginPass:=1
;StoredReqBody := req.body
	res.SetBodyText(Index_Html)
	res.status := 200
}
}

resetScheduleTimer(ByRef req, ByRef res){
Global
scheduleDelay := 0
SHT:=scheduleDelay//60000	;standby/hibernate timer abstracted in minutes
SetTimer, scheduledStandby, off
SetTimer, scheduledHibernate, off
Msg(, "Timer Reset,all scheduled StandBy/Hibernate timers also disabled.")
	Index(req, res)
}

TimerInc(ByRef req, ByRef res){
Global
scheduleDelay+=1800000	;add 30 minutes
SHT:=scheduleDelay//60000	;standby/hibernate timer abstracted in minutes
Msg(, "StandBy/Hibernate Timer Added 30min, NOW: " . SHT . "min")
	Index(req, res)
}

TimerDec(ByRef req, ByRef res){
Global
if !scheduleDelay	;if already zero,don't go down to negative numbers!
	{
	Index(req, res)
	Return
	}
scheduleDelay-=1800000	;subtract 30 minutes
SHT:=scheduleDelay//60000	;standby/hibernate timer abstracted in minutes
Msg(, "StandBy/Hibernate Timer Decreased 30min, NOW: " . SHT . "min")
	Index(req, res)
}

standby(ByRef req, ByRef res){
Global
if loginpass
{
	Index(req, res)
if scheduleDelay
	{
	SetTimer, scheduledHibernate, off
	SetTimer, scheduledStandby, %scheduleDelay%
	Msg(, "StandBy Scheduled after, " . SHT . "min")
	Return
	}
; Call the Windows API function "SetSuspendState" to have the system suspend or hibernate.
; Parameter #1: Pass 1 instead of 0 to hibernate rather than suspend.
; Parameter #2: Pass 1 instead of 0 to suspend immediately rather than asking each application for permission.
; Parameter #3: Pass 1 instead of 0 to disable all wake events.
DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
}
}

hibernate(ByRef req, ByRef res){
Global
if loginpass
{
	Index(req, res)
if scheduleDelay
	{
	SetTimer, scheduledStandby, off
	SetTimer, scheduledHibernate, %scheduleDelay%
	Msg(, "Hibernation Scheduled after, " . SHT . "min")
	Return
	}
; Call the Windows API function "SetSuspendState" to have the system suspend or hibernate.
; Parameter #1: Pass 1 instead of 0 to hibernate rather than suspend.
; Parameter #2: Pass 1 instead of 0 to suspend immediately rather than asking each application for permission.
; Parameter #3: Pass 1 instead of 0 to disable all wake events.
DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
}
}

shutdownPC(ByRef req, ByRef res){
shutdown 5
}

ReloadPC(ByRef req, ByRef res){
shutdown 2
}

monitorOnOff(ByRef req, ByRef res){
Global
	Index(req, res)
; Turn Monitor Off:
if mOn
	{
	SendMessage, 0x112, 0xF170, 2,, Program Manager  ; 0x112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
	mOn:=0
	return
	}
; Turn Monitor On:
if !mOn
	{
	Msg(, "Monitor On")
	SendMessage, 0x112, 0xF170, -1,, Program Manager  ; 0x112 is WM_SYSCOMMAND, 0xF170 is SC_MONITORPOWER.
	mOn:=1
	return
	}
; Note for the above: Use -1 in place of 2 to turn the monitor on.
; Use 1 in place of 2 to activate the monitor's low-power mode.
}

logout(ByRef req, ByRef res){
Global
loginpass:=0
	Index(req, res)
}

serverReload(ByRef req, ByRef res){
	Index(req, res)
	Global loginpass
	if loginpass
		Reload
}

; 空格会变+号
submit(ByRef req, ByRef res){
Global run_iniFile
mytext:=req.queries["mytext"]
;fileappend,% A_now "`r`n" Array_ToString(req),%A_ScriptDir%\bbbb.txt,UTF-8
;qq:=StringToHex(pp)
;MCode(varchinese, qq)
;mytext := StrGet(&varchinese, "cp65001")
mytext := StrReplace(mytext, "+", " ") ;不支持文字中有符号“+”
iniwrite, % mytext, %run_iniFile%, serverConfig, mytext
;req.headers["Referer"]:="http://192.168.1.100:2525"
;req.path:="/"
;for k,v in req
;msgbox % k "`n" v
	Index(req, res)
res.status := 200
return
}

Func_RunCmd(ByRef req, ByRef res) {

    bodyMap := ParseBody(req.body)
    cmd := bodyMap["cmd"]
    if (cmd) {
		if IsLabel(cmd)
		{
			gosub % cmd
		return
		}
		if IsStringFunc(cmd)
		{
			RunStringFunc(cmd)
		return
		}
		Run,%cmd%,,UseErrorLevel
		If ErrorLevel
			Msg(, "命令 %command% 运行失败")
    }
    res.status := 200
}

Func_setClip(ByRef req, ByRef res) {

    bodyMap := ParseBody(req.body)
    mobileClip := bodyMap["clip"]
    mobileUrl := bodyMap["url"]
    if (mobileClip) {
        Clipboard := urlUtil.Decode(mobileClip)
        CF_ToolTip("remoteControl:文字已复制!")
    }
    if (mobileUrl) {
        mobileUrl := urlUtil.Decode(mobileUrl)
        FoundPos := RegExMatch(mobileUrl, "(http|ftp|https|file)://[\w]{1,}([\.\w]{1,})+[\w-_/?&=#%:]*", mobileUrl2) ; 校验\分离出url
        if (FoundPos != 0) {
            run, %mobileUrl2%
        } else {
            run, www.baidu.com/s?wd=%mobileUrl%
        }
}
    res.status := 200
}

Func_getClip(ByRef req, ByRef res) {
    res.SetBodyText(Clipboard)
    res.status := 200
}

Func_getchromeUrl(ByRef req, ByRef res) {
    chromeUrl := GetActiveBrowserURL("Chrome_WidgetWin_1")
    if chromeUrl{
    res.SetBodyText(chromeUrl)
    res.status := 200
    }
    else {
        res.status := 404
    }
}

; 空格会变+号 使用★代替+号
runcom(ByRef req, ByRef res){
	Global
	command:=req.queries["ccdd"]
	;qq:=StringToHex(pp)
	;MCode(varchinese, qq)
	;command:=StrGet(&varchinese,"cp65001")
	command := StrReplace(command, "+", " ")
	command := StrReplace(command, "★", "+")
	if loginpass
	{
		if IsLabel(command)
		{
			gosub % command
		return
		}
		if IsStringFunc(command)
		{
			RunStringFunc(command)
		return
		}
		Run,%command%,,UseErrorLevel
		If ErrorLevel
			Msg(, "命令 %command% 运行失败")
	}
	Index(req, res)
	res.status := 200
return
}

Func_music(ByRef req, ByRef res) {
    bodyMap := ParseBody(req.body)
    musicAction := bodyMap["action"]
    if (musicAction == "toggle") {
        gosub GB2_down_up
    } else if (musicAction == "next") {
        gosub GB3_down_up
    } else if (musicAction == "prev") {
        gosub GB1_down_up
    }else if (musicAction == "start") {
        gosub MG_OpenAudioPlayer
    }
    res.status := 200
}

startaudioplayer(ByRef req, ByRef res){
Msg(, "打开播放器")
gosub MG_OpenAudioPlayer
	Index(req, res)
}

previous(ByRef req, ByRef res){
Msg(, "上一首")
gosub GB1_down_up
	Index(req, res)
}

pause_play(ByRef req, ByRef res){
Msg(, "播放/暂停")
gosub GB2_down_up
	Index(req, res)
}

next(ByRef req, ByRef res){
Msg(, "下一首")
gosub GB3_down_up
	Index(req, res)
}

exitapp(ByRef req, ByRef res){
	Index(req, res)
Msg(, "退出播放器")
gosub GB4_down_up
}

vp(ByRef req, ByRef res){
	Index(req, res)
SoundGet, masterVolumeLevel
Msg(, "加大音量 - " . masterVolumeLevel)
	Send {Volume_Up} ;  increase volume
}
vm(ByRef req, ByRef res){
	Index(req, res)
SoundGet, masterVolumeLevel
Msg(, "减少音量 - " . masterVolumeLevel)
	Send {Volume_Down} ;  lower volume
}
vHigh(ByRef req, ByRef res){
	Index(req, res)
Msg(, "音量 : 80")
	SoundSet, 80  ; Set the master volume to 80%
}
vMed(ByRef req, ByRef res){
	Index(req, res)
Msg(, "音量 : 50")
	SoundSet, 50  ; Set the master volume to 50%
}
vLow(ByRef req, ByRef res){
	Index(req, res)
Msg(, "音量 : 20")
	SoundSet, 20  ; Set the master volume to 20%
}
u_m(ByRef req, ByRef res){
Global
	Index(req, res)
Msg(, "Un/Mute")
	Send {Volume_Mute} ;  mute volume toggle
}

mp3(ByRef req, ByRef res){
Global
Msg(, "mp3")
    f := FileOpen(mp3file, "r") ; example mp3 file
    length := f.RawRead(data, f.Length)
    f.Close()
    res.status := 200
    ;res.headers["Content-Type"] := "audio/mpeg"
    res.SetBody(data, length)
	;Index(req, res)
}

excel(ByRef req, ByRef res){
Global
Msg(, "excel")
    f := FileOpen(excelfile, "r") ; example mp3 file
    length := f.RawRead(data, f.Length)
    f.Close()
    res.status := 200
    ;res.headers["Content-Type"] := "audio/x-mpequrl"
res.headers["content-disposition"] := "attachment; filename=" excelFileName
    res.SetBody(data, length)
}

txt(ByRef req, ByRef res){
Global
Msg(, "txt")
    f := FileOpen(txtfile, "r") ; example mp3 file
    length := f.RawRead(data, f.Length)
    f.Close()
    res.status := 200
    ;res.headers["Content-Type"] := "audio/x-mpequrl"
res.headers["content-disposition"] := "attachment; filename=" txtFileName
    res.SetBody(data, length)
}


upload(ByRef req, ByRef res) {
				;if req.body
;Index(req, res)
;fileappend,% A_now "`r`n" Array_ToString(req),%A_ScriptDir%\bbbb.txt,UTF-8
SiteContents =
(LTrim
	<!DOCTYPE html>
	<html>
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width">
			<title>网页控制</title>
		</head>
		<body>
			[BodyTagContents]
		</body>
	</html>
)
	
res.status := 200
tooltip % req.filepath "`r`n" req.filesize
if fileexist(req.filepath)
{
FileGetSize, OutputVar, % req.filepath
if (OutputVar=req.filesize)
{
Msg(, "文件上传成功。")
StringReplace, Serve, SiteContents, [BodyTagContents], 文件上传成功。, All
res.SetBodyText(Serve)
}
else
{
Msg(, "文件上传完毕，但字节不对！")
StringReplace, Serve, SiteContents, [BodyTagContents], % "文件上传完毕，但字节不对。`r`n原文件大小为: " req.filesize "`r`n接收到的字节: " OutputVar, All
res.SetBodyText(Serve)
}
}
else
{
Msg(, "文件上传失败！")
StringReplace, Serve, SiteContents, [BodyTagContents], 文件上传失败！请重试或检查磁盘容量是否足够。, All
res.SetBodyText(Serve)
;tooltip 处理完毕！
}
}

; 下载PC上设置的文件(Cando)
Func_downFile(ByRef req, ByRef res) {
    if (!HttpServer_File) {
        server.AddHeader(res, "Content-type", "text/html; charset=utf-8")
        res.SetBodyText("请先在PC上选择文件")
        res.status := 404
        return
    }
    server.ServeFile(res, HttpServer_File)
    server.AddHeader(res, "Content-Disposition", "attachment; filename=" HttpServer_FileName)
    res.status := 200
}

printscreenToDown(ByRef req, ByRef res) {
    CaptureScreen(0, True, 0)
    Convert(0,  A_ScriptDir . "\Settings\tmp\Screen.jpg")
    Msg(, "客户端正在截取本机屏幕")
    server.ServeFile(res, A_ScriptDir . "\Settings\tmp\Screen.jpg")
    server.AddHeader(res, "Content-Disposition", "attachment; filename=Screen.jpg")
    res.status := 200
}

Func_downFileName(ByRef req, ByRef res) {    ;辅助/downFile路径, 方便客户端获取要下载的文件名
    if (HttpServer_FileName) {
        res.SetBodyText(HttpServer_FileName)
        res.status := 200
    } else {
        res.SetBodyText("请先在PC上选择文件")
        server.AddHeader(res, "Content-type", "text/plain; charset=utf-8")
        res.status := 404
    }
}

Fun_downClientFile(ByRef req, ByRef res) {
    bodyMap := ParseBody(req.body)
    clientFilePath := bodyMap["filePath"]
    clientFileName := bodyMap["fileName"]
    if !clientFileName
    {
      ftext:= "%2F"
      StringGetPos, hPos, clientFilePath, % ftext, R1
      StringMid, clientFileName, % clientFilePath, % hPos+4
    }
    if (!StrLen(clientFilePath) || !StrLen(clientFileName)) {
        res.SetBodyText("/downClientFile=> 需要配置参数filePath fileName")
        res.status := 404
    } else {
        clientFileName := urlUtil.Decode(clientFileName)
        clientFileDownPath := "N:\" clientFileName
        clientFileDownUrl := clientWebServerUrl "/download?path=" clientFilePath
        WinHttp.URLGet(clientFileDownUrl, "","",clientFileDownPath)
        ;TODO 下载失败通知  DownloadSync失败需要返回处理(返回false)
        Msg(,"下载文件[" clientFileName "]成功!")
        res.SetBodyText("/downClientFile=> 文件下载成功:" clientFileDownPath)
        res.status := 200
    }
}

NotFound(ByRef req, ByRef res) {
    res.SetBodyText("找不到网页")
}

;========================= 公共函数 =========================
ParseBody(body) {
    ;bodyArray := StrSplit(body, "`n")
    bodyArray := StrSplit(body, "&")
    bodyMap := {}
    for i, value in bodyArray {
        pos := InStr(value, "=")
        key := SubStr(value, 1, pos - 1)
        val := SubStr(value, pos + 1)
        bodyMap[key] := val
    }
    return bodyMap
}

;========================================================================================================================================================================================
;---------------------------------------------------------------
; Msg Monolog
; http://www.autohotkey.com/board/topic/94458-msgbox-or-traytip-replacement-monolog-non-modal-transparent-msg-cornernotify/
;---------------------------------------------------------------

Msg(title="网页控制", body="", loc="bl", fixedwidth=0, time=0) {
	global msgtransp, hwndmsg, MonBottom, MonRight
	SetTimer, MsgStay, Off
	SetTimer, MsgFadeOut, Off
	Gui,78:Destroy
	Gui,78:+AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound
	hwndmsg := WinExist()
	WinSet, ExStyle, +0x20 ; WS_EX_TRANSPARENT make the window transparent-to-mouse
	WinSet, Transparent, 250
	msgtransp := 250
	Gui,78:Color, 000000 ;background color
	Gui,78:Font, c5C5CF0 s17 wbold, Arial
	Gui,78:Add, Text, x20 y12, %title%
	If(body) {
		Gui,78:Font, cFF0000 s15 wnorm
		Gui,78:Add, Text, x20 y56, %body%
	}
	If(fixedwidth) {
		Gui,78:Show, NA W700
	} else {
		Gui,78:Show, NA
	}
	WinGetPos,ix,iy,w,h, ahk_id %hwndmsg%
	; SysGet, Mon, MonitorWorkArea ; already called
	if(loc) {
		x := InStr(loc,"l") ? 0 : InStr(loc,"c") ? (MonRight-w)/2 : InStr(loc,"r") ? A_ScreenWidth-w : 0
		y := InStr(loc,"t") ? 0 : InStr(loc,"m") ? (MonBottom-h)/2 : InStr(loc,"b") ? MonBottom - h : MonBottom - h
	} else { ; bl
		x := 0
		y := MonBottom - h
	}
	WinMove, ahk_id %hwndmsg%,,x,y
	If(time) {
		time *= 1000
		SetTimer, MsgStay, %time%
	} else {
		SetTimer, MsgFadeOut, 100
	}
}

MsgStay:
	SetTimer, MsgStay, Off
	SetTimer, MsgFadeOut, 1
Return

MsgFadeOut:
	If(msgtransp > 0) {
		msgtransp -= 4
		WinSet, Transparent, %msgtransp%, ahk_id %hwndmsg%
	} Else {
		SetTimer, MsgFadeOut, Off
		Gui,78:Destroy
	}
Return

;Goto, unintendedStdBy_Hib_JUMP	;so that standby/hibernate is not activated on script exit & labels can only be reached if called
scheduledStandby:
	SetTimer, scheduledStandby, off
	scheduleDelay:=0	;reset timer to allow going into standby/hibernate
	standby(req, res)
Return
scheduledHibernate:
	SetTimer, scheduledHibernate, off
	scheduleDelay:=0	;reset timer to allow going into standby/hibernate
	hibernate(req, res)
Return
;unintendedStdBy_Hib_JUMP:

;::mrcexit::
;ExitApp