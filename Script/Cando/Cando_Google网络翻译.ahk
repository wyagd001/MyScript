Cando_Google网络翻译:
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
webs := URLDownloadToVar("https://translate.google.cn","UTF-8",,,,,,"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36")
RegExMatch(webs,"TKK='(.*?)'" , tkkkk)
tk:=TK(Google_keyword,tkkkk1)
msgbox % tk
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
	if RegExMatch(KeyWord,"[^a-zA-Z0-9\.\?\-\!\s]")
		LangOut := "en",LangIn := "zh"
	else
		LangOut := "zh",LangIn := "en"
url := "https://translate.google.cn/translate_a/single?client=gtx&dt=t&dj=1&ie=UTF-8&sl=" LangIn "&tl=" LangOut "&q=" UrlEncode(KeyWord,"UTF-8")
response := URLDownloadToVar(url,"UTF-8",,,,,,"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36")

json_obj := JSON.Load(response)
        trans := ""
        for value, sentence in json_obj.sentences
        {
            trans .= sentence.trans . "`n"
}
Result := trans
return Result
}

TK(string,tkk)  {
	js := new ActiveScript("JScript")
	js.Exec(GetJScript())
	Return js.token(string,tkk)
}

#Include %A_ScriptDir%\lib\Class_JSON.ahk