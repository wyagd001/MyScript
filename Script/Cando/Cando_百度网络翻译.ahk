; 源网址：http://thinkai.net/p/537
; https://www.jianshu.com/p/38a65d8d3e80
; https://blog.csdn.net/hujingshuang/article/details/80180294
; https://www.jianshu.com/p/5f3177943b91
; https://blog.csdn.net/master_ning/article/details/81002474
; https://blog.csdn.net/hongquan1991/article/details/80616491

Cando_百度网络翻译:
	Gui,66:Default
	Gui,Destroy
	res=
	Baidu_keyword=%CandySel%
	Baidu_译文:=BaiduApi(Baidu_keyword)
	obj := Jxon_Load(Baidu_译文)
	gosub baidujson
	If Baidu_基本释义<>
	{
		Gui,add,Edit,x10 y10 w260 h80 vBaidu_keyword,%Baidu_keyword%
		Gui,add,button,x270 y10 w40 h80 vtransandplay gsoundpaly2,播放
		Gui,add,Edit,x10 y100 w300 h80 vBaidu_基本释义,%Baidu_基本释义%
		Gui,add,Edit,x10 y190 w300 h80 vBaidu_网络释义,%Baidu_网络释义%
		Gui,show,,百度网络翻译
	}
	else
		MsgBox,,百度网络翻译,网络错误或查询不到该单词的翻译。
Return

soundpaly2:
	Gui, Submit, NoHide
	if(Baidu_keyword=CandySel)
	{
	; 本地语音引擎
	; spovice:=ComObjCreate("sapi.spvoice")
	; spovice.Speak(Baidu_keyword)
	
		IfExist,%A_SCRIPTDIR%\Settings\tmp\tts.mp3
		{
			SoundPlay,%A_SCRIPTDIR%\Settings\tmp\tts.mp3,wait
		Return
		}
		else
		{
			if RegExMatch(Baidu_keyword,"[a-zA-Z0-9\.\?\-\!\s]")
			{
				speechurl=http://fanyi.baidu.com/gettts?lan=uk&text=%Baidu_keyword%&spd=3&source=web
				WinHttp.URLGet(speechurl,,,A_SCRIPTDIR "\Settings\tmp\tts.mp3")
				sleep,1500
				SoundPlay,%A_SCRIPTDIR%\Settings\tmp\baidu_tts.mp3,wait
				deltts=1
			Return
			}
		}
	}
	else
	{
		CandySel:=Baidu_keyword
		res:=Baidu_基本释义:=Baidu_译文=""
		GuiControl, Disable, transandplay
		Baidu_译文:=BaiduApi(Baidu_keyword)
		obj := Jxon_Load(Baidu_译文)
		gosub baidujson
		If Baidu_基本释义<>
		{
			GuiControl, , Baidu_基本释义, % Baidu_基本释义
			GuiControl, , Baidu_网络释义, % Baidu_网络释义
			;spovice:=ComObjCreate("sapi.spvoice")
			;spovice.Speak(Baidu_keyword)
			IfExist,%A_SCRIPTDIR%\Settings\tmp\tts.mp3
				FileDelete,%A_SCRIPTDIR%\Settings\tmp\tts.mp3

			if RegExMatch(Baidu_keyword,"[a-zA-Z0-9\.\?\-\!\s]")
			{
				speechurl=http://fanyi.baidu.com/gettts?lan=uk&text=%Baidu_keyword%&spd=3&source=web
				WinHttp.URLGet(speechurl,,,A_SCRIPTDIR "\Settings\tmp\tts.mp3")
				sleep,1500
				SoundPlay,%A_SCRIPTDIR%\Settings\tmp\tts.mp3,wait
				deltts=1
				GuiControl, Enable, transandplay
			Return
			}
		}
		GuiControl, Enable, transandplay
	}
Return

BaiduApi(KeyWord)
{
IfExist,%A_ScriptDir%\Settings\tmp\baidu.ini
	IniRead, baiducookie, %A_ScriptDir%\Settings\tmp\baidu.ini, baidu, cookie
else
{
webs := WinHttp.URLGet("https://fanyi.baidu.com","Charset:UTF-8","User-Agent:Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36")
baiduobj:=WinHttp.ResponseHeaders
baiducookie:=baiduobj["Set-Cookie"]
StringReplace, baiducookie, baiducookie,`r`n,`;, All
IniWrite,% baiducookie, %A_ScriptDir%\Settings\tmp\baidu.ini, baidu, cookie
}

header := {"Cookie": baiducookie,"User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"}

webs := WinHttp.URLGet("https://fanyi.baidu.com","Charset:UTF-8",header)
RegExMatch(webs,"window.gtk = '(.*?)';" , gtk)
RegExMatch(webs,"token: '(.*?)'" , token)
if !token1
return

	js := new ActiveScript("JScript")
	js.Exec(GetJScript())
  sign:=js.token(keyword,gtk1)

if RegExMatch(KeyWord,"[^a-zA-Z0-9\.\?\-\!\s]")
    slang := "zh",dlang := "en"
else
    slang := "en",dlang := "zh"
url := "https://fanyi.baidu.com/v2transapi?from=" slang "&to=" dlang "&query=" UrlEncode(KeyWord,"UTF-8") "&transtype=translang&simple_means_flag=3&sign=" sign "&token=" token1

   json := WinHttp.URLGet(url,"Charset:UTF-8",header)
; 错误代码：997，没有cookie； 998，cookie 过期；999，内部错误。
;msgbox % json
    Return json
}

baidujson:
Baidu_基本释义:= decodeu(obj.trans_result.data.1.dst)
dict_result := obj.dict_result.simple_means.symbols
if IsObject(dict_result.1)
{
    res .= "词典结果:`n"
    for k,v in dict_result.1.parts
    {
        res .= k ". " v.part
        if IsObject(v.means)
        {

            for x,y in v.means
            {

                if IsObject(y)
{

                    res .= decodeu(y.word_mean) ";"
}
                else
{
                    res .= decodeu(y) ";"
}
            }
            res .= "`n"
        }
    }
}  
if IsObject(obj.dict_result.cizu)
{
    res .= "`n词组结果:`n"
    for k,v in obj.dict_result.cizu
        res .= k ". " decodeu(v.fanyi) "(" decodeu(v.cz_name) ")：" v.jx.1.jx_en " " decodeu(v.jx.1.jx_zh) "`n"
}
	Baidu_网络释义:= res
return

Jxon_Load(ByRef src, args*)
{
	static q := Chr(34)

	key := "", is_key := false
	stack := [ tree := [] ]
	is_arr := { (tree): 1 }
	next := q . "{[01234567890-tfn"
	pos := 0
	while ( (ch := SubStr(src, ++pos, 1)) != "" )
	{
		if InStr(" `t`n`r", ch)
			continue
		if !InStr(next, ch, true)
		{
			ln := ObjLength(StrSplit(SubStr(src, 1, pos), "`n"))
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
			,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
			  : (next == "'")     ? "Unterminated string starting at"
			  : (next == "\")     ? "Invalid \escape"
			  : (next == ":")     ? "Expecting ':' delimiter"
			  : (next == q)       ? "Expecting object key enclosed in double quotes"
			  : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
			  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
			    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
			, ln, col, pos)

			throw Exception(msg, -1, ch)
		}

		is_array := is_arr[obj := stack[1]]

		if i := InStr("{[", ch)
		{
			val := (proto := args[i]) ? new proto : {}
			is_array? ObjPush(obj, val) : obj[key] := val
			ObjInsertAt(stack, 1, val)
			
			is_arr[val] := !(is_key := ch == "{")
			next := q . (is_key ? "}" : "{[]0123456789-tfn")
		}

		else if InStr("}]", ch)
		{
			ObjRemoveAt(stack, 1)
			next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
		}

		else if InStr(",:", ch)
		{
			is_key := (!is_array && ch == ",")
			next := is_key ? q : q . "{[0123456789-tfn"
		}

		else ; string | number | true | false | null
		{
			if (ch == q) ; string
			{
				i := pos
				while i := InStr(src, q,, i+1)
				{
					val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
					static end := A_AhkVersion<"2" ? 0 : -1
					if (SubStr(val, end) != "\")
						break
				}
				if !i ? (pos--, next := "'") : 0
					continue

				pos := i ; update pos

				  val := StrReplace(val,    "\/",  "/")
				, val := StrReplace(val, "\" . q,    q)
				, val := StrReplace(val,    "\b", "`b")
				, val := StrReplace(val,    "\f", "`f")
				, val := StrReplace(val,    "\n", "`n")
				, val := StrReplace(val,    "\r", "`r")
				, val := StrReplace(val,    "\t", "`t")

				i := 0
				while i := InStr(val, "\",, i+1)
				{
					if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
						continue 2

					; \uXXXX - JSON unicode escape sequence
					xxxx := Abs("0x" . SubStr(val, i+2, 4))
					if (A_IsUnicode || xxxx < 0x100)
						val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
				}

				if is_key
				{
					key := val, next := ":"
					continue
				}
			}

			else ; number | true | false | null
			{
				val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
			
			; For numerical values, numerify integers and keep floats as is.
			; I'm not yet sure if I should numerify floats in v2.0-a ...
				static number := "number", integer := "integer"
				if val is %number%
				{
					if val is %integer%
						val += 0
				}
			; in v1.1, true,false,A_PtrSize,A_IsUnicode,A_Index,A_EventInfo,
			; SOMETIMES return strings due to certain optimizations. Since it
			; is just 'SOMETIMES', numerify to be consistent w/ v2.0-a
				else if (val == "true" || val == "false")
					val := %value% + 0
			; AHK_H has built-in null, can't do 'val := %value%' where value == "null"
			; as it would raise an exception in AHK_H(overriding built-in var)
				else if (val == "null")
					val := ""
			; any other values are invalid, continue to trigger error
				else if (pos--, next := "#")
					continue
				
				pos += i-1
			}
			
			is_array? ObjPush(obj, val) : obj[key] := val
			next := obj==tree ? "" : is_array ? ",]" : ",}"
		}
	}

	return tree[1]
}
 
decodeu(ustr){
If A_IsUnicode
return ustr
ustr := StrReplace(ustr, "[", "")
ustr := StrReplace(ustr, "]", "")
ustr := StrReplace(ustr, "<", "")
ustr := StrReplace(ustr, ">", "")
   Loop
    {
        if !ustr
            break  
        if RegExMatch(ustr,"^\s*\\u([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})(.*)",m)
        {
            word_u := Chr("0x" m2) Chr("0x" m1), ustr := m3, word_a := ""
            word_a :=Ansi4Unicode(&word_u)
            out .= word_a
        }
        else if RegExMatch(ustr, "^([a-zA-Z0-9\.\?\-\!\s]*)(.*)",n)
        {
            ustr := n2
            out .= n1
        }
    }
    return out
}