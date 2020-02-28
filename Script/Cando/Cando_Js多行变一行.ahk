; 构建一行Js
; "javascript:void((function(){" . js . "})())"
getSingleLineOfJS(js){
url:="https://javascript-minifier.com/raw"
data:= "input=" UrlEncode(js)
Return clipboard := WinHttp.URLPOST(url,data)
}