indexInit:
mytext:=CF_IniRead(run_iniFile, "serverConfig","mytext")

Index_Html =
(
<!doctype html>
<html>
<head>
<title> 网页控制 </title>
<link href="https://autohotkey.com/favicon.ico" type="image/x-icon" rel="shortcut icon">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<style>
p {
  font-family: Arial,Helvetica,sans-serif;
  font-size: %textFontSize%;
}

button {
  font-family: Arial,Helvetica,sans-serif;
  font-size: %buttonSize%;
}

h1 {
	padding: %pagePadding%; width: auto; font-family: Sans-Serif; font-size: 22pt;
}

input{
width: 700px ; height: 48px;
}

body {
	background-color : black ;
	color : yellow ;
	padding: %pagePadding%; width: auto; font-family: Sans-Serif; font-size: 16pt;
}

</style>
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
</p>

<p>
<a href="/vp"> <button> 音量+ </button> </a>
<a href="/vm"> <button> 音量- </button> </a>
<a href="/u_m"> <button> 静音 </button> </a>
<a href="/vHigh"> <button> 80`% </button> </a>
<a href="/vMed"> <button> 50`% </button> </a>
<a href="/vLow"> <button> 20`% </button> </a>
</p>

<p> &nbsp; </p>

<p>系统控制</p>

<p>
<a href="/standby"> <button> 待机 </button> </a>
<a href="/hibernate"> <button> 休眠 </button> </a>
<a href="/monitorOnOff"> <button> 屏幕开关 </button> </a>
<a href="/logout"> <button> 退出登录 </button> </a>
<a href="/serverReload"> <button> 重启服务 </button> </a>
</p>

<p> &nbsp; </p>

<p>文件下载</p>
<p> 
<a href="/music"> <button> mp3 文件</button> </a> 
<a href="/excel" download="通服工作日志.xls"> <button> xls 文件</button> </a>
<a href="/txt" download="中文歌曲.txt"> <button> txt 文件</button> </a>
</p>

<p>发送文本</p>
<form action="/submit" method="get">
<input type="text" id="1234" name="mytext" value="%mytext%" />
<input type=submit style="width: 80px; height: 55px;" value="保存文字"/>  
<!-- <a href="/submit"> <button> 提交 </button> </a> --!>
</form>

<p>运行命令</p>

<!--select标签和input外面的span标签的格式是为了使两个位置在同一位置，控制位置-->
<!--有name属性都会提交-->
<form action="/runcom" method="get">
<span style="position:absolute;border:1pt solid #c1c1c1;overflow:hidden;width:740px;height:54px;">
<select name="aabb" id="aabb" style="width:742px;height:55px;" 
onChange="javascript:document.getElementById('ccdd').value=document.getElementById('aabb').options[document.getElementById('aabb').selectedIndex].value;">
<!--下面的option的样式是为了使字体为灰色，只是视觉问题，看起来像是注释一样-->
<option value="" style="color:#c2c2c2;">---请选择---</option>
<option value="%stableitem1%">hichat2626</option>
<option value="%stableitem2%">项目二</option>
<option value="%stableitem3%">项目三</option>
<option value="%stableitem4%">项目四</option>
<option value="%stableitem5%">项目五</option>
</select> 
</span> 
<span style="position:absolute;border-top:1pt solid #c1c1c1;border-left:1pt solid #c1c1c1;border-bottom:1pt solid #c1c1c1;width:700px;height:50px;"> 
<input type="text" name="ccdd" id="ccdd" placeholder="请输入要运行的内容, 回车提交">
</span>
<span> 
<input type="submit" style="width: 80px; height: 50px;" value="提交"/>
</span> 
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
			<link href='http://fonts.googleapis.com/css?family=Ubuntu' rel='stylesheet' type='text/css'>
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

if indexInit_activated
	Return	;to return only after first initilisation,i.e from a 'Gosub'
indexInit_activated++

paths := {}
paths["/"] := Func("Index")
paths["/logo"] := Func("Logo")
paths["/page"] := Func("MainPage")

paths["/startaudioplayer"] := Func("startaudioplayer")
paths["/previous"] := Func("previous")
paths["/pause_play"] := Func("pause_play")
paths["/next"] := Func("next")
paths["/exitapp"] := Func("exitapp")

paths["/vp"] := Func("vp")
paths["/vm"] := Func("vm")
paths["/u_m"] := Func("u_m")
paths["/vHigh"] := Func("vHigh")
paths["/vMed"] := Func("vMed")
paths["/vLow"] := Func("vLow")

paths["/standby"] := Func("standby")
paths["/hibernate"] := Func("hibernate")
paths["/monitorOnOff"] := Func("monitorOnOff")
paths["/logout"] := Func("logout")
paths["/serverReload"] := Func("serverReload")

paths["/submit"] := Func("submit")
paths["/runcom"] :=Func("runcom")

paths["/music"] := Func("music")
paths["/excel"] := Func("excel")
paths["/txt"] := Func("txt")

paths["404"] := Func("NotFound")

server := new HttpServer()
server.LoadMimes(A_ScriptDir . "/lib/mime.types")
server.SetPaths(paths)
server.Serve(serverPort)
return

Logo(ByRef req, ByRef res, ByRef server) {
    server.ServeFile(res, A_ScriptDir . "/pic/logo.png")
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
if loginpass
Reload
}

; 空格会变+号
submit(ByRef req, ByRef res){
Global run_iniFile
pp:=req.queries["mytext"]
qq:=StringToHex(pp)
MCode(varchinese, qq)
iniwrite, % StrGet(&varchinese, "cp65001"), %run_iniFile%, serverConfig, mytext
	Index(req, res)
return
}

; 空格会变+号 使用★代替+号
runcom(ByRef req, ByRef res){
Global
pp:=req.queries["ccdd"]
qq:=StringToHex(pp)
MCode(varchinese, qq)
command:=StrGet(&varchinese,"cp65001")
command := StrReplace(command, "+", " ")
command := StrReplace(command, "★", "+")
if loginpass
{
if IsLabel(command)
{
gosub % command
return
}
if IsStingFunc(command)
 RunStingFunc(command)
Run,%command%,,UseErrorLevel
If ErrorLevel
	{
If % %dir%<>""
		{
			Run,% %Dir%,,UseErrorLevel
}
}
}
	Index(req, res)
return
}

startaudioplayer(ByRef req, ByRef res){
Msg(, "打开播放器")
gosub OpenAudioPlayer
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

music(ByRef req, ByRef res){
Global
Msg(, "Music")
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
res.headers["content-disposition"] := "attachment;filename=通服工作日志.xls"
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
res.headers["content-disposition"] := "attachment;filename=中文歌曲.txt"
    res.SetBody(data, length)
}

NotFound(ByRef req, ByRef res) {
    res.SetBodyText("Page not found")
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
	Gui,77:Destroy
	Gui,77:+AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound
	hwndmsg := WinExist()
	WinSet, ExStyle, +0x20 ; WS_EX_TRANSPARENT make the window transparent-to-mouse
	WinSet, Transparent, 250
	msgtransp := 250
	Gui,77:Color, 000000 ;background color
	Gui,77:Font, c5C5CF0 s17 wbold, Arial
	Gui,77:Add, Text, x20 y12, %title%
	If(body) {
		Gui,77:Font, cFF0000 s15 wnorm
		Gui,77:Add, Text, x20 y56, %body%
	}
	If(fixedwidth) {
		Gui,77:Show, NA W700
	} else {
		Gui,77:Show, NA
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
		Gui,77:Destroy
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