Cando_Google网络翻译:
	;  后台打开IE获取翻译结果
	Gui,66:Default
	Gui,Destroy
	res=
	global tkkkk
	Google_keyword=%CandySel%
	Google_基本释义:=GoogleApi(Google_keyword)
	If Google_基本释义<>
	{
		Gui,add,Edit,x10 y10 w260 h80 vGoogle_keyword,%Google_keyword%
		Gui,add,button,x270 y10 w40 h80 vtransandplay gsoundpaly3,播放
		Gui,add,Edit,x10 y100 w300 h80 vGoogle_基本释义,%Google_基本释义%
		Gui,show,,Google网络翻译
	}
	else
		MsgBox,,Google网络翻译,网络错误或查询不到该单词的翻译。
Return

soundpaly3:
	Gui, Submit, NoHide
	tk:=TK(Google_keyword)

IfExist,%A_SCRIPTDIR%\Settings\tmp\google_tts.mp3
	FileDelete,%A_SCRIPTDIR%\Settings\tmp\google_tts.mp3
sleep,1000
textlen:=StrLen(Google_keyword)

SpeechUrl = https://translate.google.cn/translate_tts?ie=UTF-8&q=%Google_keyword%&sl=zh-CN&tl=en&total=1&idx=0&textlen=%textlen%&tk=%tk%&client=t&prev=input&ttsspeed=0.5

$CMD = "%A_SCRIPTDIR%\Bin\wget.exe"  -U "Lynx 1.2.3.4" -O "%A_SCRIPTDIR%\Settings\tmp\google_tts.mp3" --no-check-certificate  "%SpeechUrl%"
Run, %comspec% /c "%$CMD%"  , , Hide
sleep,3000
SoundPlay,%A_SCRIPTDIR%\Settings\tmp\google_tts.mp3
sleep,2000
SoundPlay,none
FileDelete,%A_SCRIPTDIR%\Settings\tmp\google_tts.mp3
Return

GoogleApi(KeyWord)
{
; 缺陷打开IE，IE进程残留
	if RegExMatch(KeyWord,"[^a-zA-Z0-9\.\?\-\!\s]")
		LangOut := "en",LangIn := "zh-CN"
	else
		LangOut := "zh-CN",LangIn := "en"
base := "https://translate.google.cn/?hl=zh-CN&tab=wT#"
path := base . LangIn . "/" . LangOut . "/" . UrlEncode(KeyWord,"UTF-8")

IE := ComObjCreate("InternetExplorer.Application")
; IE.Visible := true  ; 前台打开IE
; 如果打开的是360浏览器说明注册表被修改了
; [HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{0002DF01-0000-0000-C000-000000000046}]
; [HKEY_CLASSES_ROOT\CLSID\{0002DF01-0000-0000-C000-000000000046}]
IE.Navigate(path)
StartTime := A_TickCount
While IE.readyState!=4 || IE.document.readyState!="complete" || IE.busy
{
        Sleep 50
ElapsedTime := A_TickCount - StartTime
if ElapsedTime > 25000
break
}
 RegExMatch(IE.Document.body.innerHTML,"TKK.*?\)\;" , tkkkk)

Result := IE.document.all.result_box.innertext
IE.Quit
return Result
}

TK(string)  {
	js := new ActiveScript("JScript")
	js.Exec(GetJScript())
	Return js.tk(string)
}

GetJScript()
{
	script =
	(
  %tkkkk%

		function b(a, b) {
		  for (var d = 0; d < b.length - 2; d += 3) {
				var c = b.charAt(d + 2),
					 c = "a" <= c ? c.charCodeAt(0) - 87 : Number(c),
					 c = "+" == b.charAt(d + 1) ? a >>> c : a << c;
				a = "+" == b.charAt(d) ? a + c & 4294967295 : a ^ c
		  }
		  return a
		}

		function tk(a) {
			 for (var e = TKK.split("."), h = Number(e[0]) || 0, g = [], d = 0, f = 0; f < a.length; f++) {
				  var c = a.charCodeAt(f);
				  128 > c ? g[d++] = c : (2048 > c ? g[d++] = c >> 6 | 192 : (55296 == (c & 64512) && f + 1 < a.length && 56320 == (a.charCodeAt(f + 1) & 64512) ?
				  (c = 65536 + ((c & 1023) << 10) + (a.charCodeAt(++f) & 1023), g[d++] = c >> 18 | 240,
				  g[d++] = c >> 12 & 63 | 128) : g[d++] = c >> 12 | 224, g[d++] = c >> 6 & 63 | 128), g[d++] = c & 63 | 128)
			 }
			 a = h;
			 for (d = 0; d < g.length; d++) a += g[d], a = b(a, "+-a^+6");
			 a = b(a, "+-3^+b+-f");
			 a ^= Number(e[1]) || 0;
			 0 > a && (a = (a & 2147483647) + 2147483648);
			 a `%= 1E6;
			 return a.toString() + "." + (a ^ h)
		}
	)
	Return script
}