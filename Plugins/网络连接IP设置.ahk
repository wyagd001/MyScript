/*
TODO:
- find a better way to make context sensitive hotkeys for when listbox is selected
	- didn't work: hotkey ifwinactive ahk_id %controlhwnd%
- ini has a tendency to accumulate blank lines after deleting and inserting ips. Should fix?
- use more robust ini functions, maybe existing lib, objects?
- add button to get active adapter confs
- preset names containing "|" break the listbox
*/

#NoEnv

; Gotta be admin to change adapter settings. Snippet from the docs (in Variables)
; or shajul's, I don't know anymore: http://www.autohotkey.com/board/topic/46526-run-as-administrator-xpvista7-a-isadmin-params-lib/
; TODO: not working if compiled?
if not A_IsAdmin
{
	if A_IsCompiled
		DllCall("shell32\ShellExecuteA", uint, 0, str, "RunAs", str, A_ScriptFullPath, str, "", str, A_WorkingDir, int, 1)
			; note the A, no dice without it, don't know of side effects
	else
		DllCall("shell32\ShellExecute", uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """", str, A_WorkingDir, int, 1)
		
	ExitApp
}

presets_ini_file := A_ScriptDir "\网络连接IP设置.ini"
interfaces_tmpfile := A_ScriptDir "\interfaces.tmp"
putty := A_ScriptDir "\putty.exe"
Gui, Add, Text, x12 y9 w120 h20 , 网络连接
Gui, Add, DropDownList, x12 y29 w130 h100 vinterface gupdate_cmd, % get_interfaces_list(interfaces_tmpfile)
Gui, Add, Button, x12 y59 w130 h20 gchang_interface_state, 切换连接状态

Gui, Add, Text, x12 y89 w130 h20 , 保存的方案
Gui, Add, ListBox, x12 y109 w130 h130 vpreset gpreset_select Hwndpresets_hwnd, % ini_get_sections(presets_ini_file)
Gui, Add, Button, x12 y233 w30 h20 gpreset_up, 上
Gui, Add, Button, x42 y233 w30 h20 gpreset_down, 下
Gui, Add, Button, x102 y233 w30 h20 gpreset_delete, 删除

Gui, Add, GroupBox, x152 y9 w260 h120 , IP
Gui, Add, CheckBox, x162 y29 w70 h20 vip_ignore gip_toggle, 忽略
Gui, Add, CheckBox, x242 y29 w70 h20 vip_auto gip_toggle, 自动获取

Gui, Add, Text, x162 y59 w80 h20 , IP地址
Gui, Add, Custom, ClassSysIPAddress32 x242 y58 w120 h20 hwndhIPControl vcomp_ip gupdate_cmd
Gui, Add, Text, x162 y79 w80 h20 , 子网掩码
;Gui, Add, Custom, ClassSysIPAddress32 x242 y79 w120 h20 vnetmask gupdate_cmd, 
Gui, Add, Custom, ClassSysIPAddress32 x242 y80 w120 h20  hwndhnetmaskControl vnetmask gip_haschanged
Gui, Add, Text, x162 y99 w80 h20 , 默认网关
Gui, Add, Custom, ClassSysIPAddress32 x242 y102 w120 h20 hwndhgatewayControl vgateway gupdate_cmd
Gui, Add, Button, x372 y59 w30 h20 ggateway2comp_ip, <+1

Gui, Add, GroupBox, x152 y139 w260 h100 , DNS
Gui, Add, CheckBox, x160 y160 w70 h20 vdns_ignore gdns_toggle, 忽略
Gui, Add, CheckBox, x242 y159 w70 h20 vdns_auto gdns_toggle, 自动获取
Gui, Add, Button, x312 y159 w90 h20 gset_google_dns, Google DNS
Gui, Add, Text, x162 y189 w80 h20 , 首选DNS服务器
Gui, Add, Custom, ClassSysIPAddress32 x242 y189 w120 h20 vdns_1 gupdate_cmd
Gui, Add, Text, x162 y209 w80 h20 , 备用DNS服务器
Gui, Add, Custom, ClassSysIPAddress32 x242 y209 w120 h20 vdns_2 gupdate_cmd

Gui, Add, Text, x12 y260 w120 h20 , Cmd
Gui, Add, Edit, x12 y280 w400 h70 vcmd, Edit
Gui, Add, Button, x432 y299 w120 h30 grun_cmd, 应用设置

Gui, Add, Button, x432 y19 w120 h30 gsave, 保存方案

Gui, Add, Text, x432 y69 w120 h20 , 其它
Gui, Add, Button, x432 y89 w120 h30 gping, ping 网关
Gui, Add, Button, x432 y129 w120 h30 gbrowse, 浏览 网关
Gui, Add, Button, x432 y169 w120 h30 gtelnet, telnet 网关
Gui, Add, Button, x432 y209 w120 h30 gssh, ssh 网关
Gui, Add, Text, x610 y340 w40 h20 vshowmoretext gshowmore,更多∨

Gui, Add, Text, xm+2 section
Gui, Add, Text, yp+10, Ctrl+Enter = 应用  Ctrl+s = 保存  Ctrl+p = Ping  Ctrl+b = 浏览  Ctrl+t = Telnet  Ctrl+h = SSH  Esc = 关闭
Gui, Add, Text, xs, 当选中预设方案列表时: Del = 删除  Ctrl+up = 向上移动  Ctrl+down = 向下移动  双击 = 应用

Gui, Add, GroupBox, x15 y420 w550 h80 , IE 代理设置
Gui, Add, CheckBox, x25 y440 w100 h20 vieproxy , 使用代理服务器
Gui, Add, Text,x25 y470 w100 h20,代理服务器:端口:
Gui, Add, edit,x130 y465 w300 h20 vieproxyserver
Gui, Add, Button, x432 y445 w120 h30 gieproxy, 应用代理

; Generated using SmartGUI Creator 4.0

gosub, ip_toggle
gosub, dns_toggle

Gui, +Hwndgui_hwnd

hotkey, ifwinactive, ahk_id %gui_hwnd%
	hotkey, ^p, ping, on
	hotkey, ^b, browse, on
	hotkey, ^s, save, on
	hotkey, ^t, telnet, on
	hotkey, ^h, ssh, on
	hotkey, ^Enter, run_cmd, on

	;hotkey, ^up, context_preset_up
	;hotkey, ^down, context_preset_down
	;hotkey, del, context_preset_delete
hotkey, ifwinactive
Gui, Show,w650 h360
ComObjError(false)
objWMIService := ComObjGet("winmgmts:\\.\root\cimv2")
colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
while colItems[objItem]
{
if objItem.IPAddress[0] == A_IPAddress1
{
comp_ip:=A_IPAddress1
netmask:=objItem.IPSubnet[0]
gateway:=objItem.DefaultIPGateway[0]
dns_1:=objItem.DNSServerSearchOrder[0]?objItem.DNSServerSearchOrder[0]:""
dns_2:=objItem.DNSServerSearchOrder[1]?objItem.DNSServerSearchOrder[1]:""
guicontrol,, comp_ip,  %comp_ip%
guicontrol,, netmask,  %netmask%
guicontrol,, gateway,  %gateway%
guicontrol,, dns_1,  %dns_1%
guicontrol,, dns_2,  %dns_2%
}
}
Return

; end of autoexec ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

GuiClose:
GuiEscape:
ExitApp

showmore:
if !showmore
{
GuiControl,,ieproxy,% CF_regread("HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","Proxyenable")
GuiControl,,ieproxyserver,% CF_regread("HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyServer")
gui,show,w650 h510
GuiControl,,showmoretext,收起∧
showmore:=1
}
else 
{
Gui, Show,w650 h360
GuiControl,,showmoretext,更多∨
showmore:=
}
return

chang_interface_state:
gui, submit, nohide
filedelete, error.tmp
if interface contains  已启用
{
interface:=trim(StrReplace(interface,"已启用"))
Runwait,%comspec% /c netsh interface set interface name="%interface%" admin=disabled >error.tmp, ,Hide
check_error("error.tmp","已禁用" interface)
}
if interface contains  已禁用
{
interface:=trim(StrReplace(interface,"已禁用"))
Runwait,  %comspec% /c netsh interface set interface name="%interface%" admin=enabled >error.tmp,,Hide
check_error("error.tmp","已启用" interface)
}

GuiControl, , interface,|
GuiControl, , interface, % get_interfaces_list(interfaces_tmpfile)
	gosub, update_cmd
return

get_interfaces_list(tmp_file) {
	filedelete, % tmp_file
	runwait, %comspec% /c "for /f "tokens=1`,3*" `%a in ('netsh interface show interface^|more +3') do echo `%a `%c>> "%tmp_file%"" , % A_ScriptDir ,hide
	fileread, interfaces, % tmp_file
	filedelete, % tmp_file  ; don't leave nothing in the dir
	stringreplace, interfaces, interfaces, `r`n, |, all
	sort,interfaces, D| U
	stringreplace, interfaces, interfaces, |, ||  ; preselect first
	return interfaces
}

check_error(tmp_file,msg)
{
fileread,error_msg,%tmp_file%
error_msg:=StrReplace(error_msg,"`r`n")
filedelete, %tmp_file%
if !error_msg
{
tooltip,%msg%。
sleep,1000
tooltip
return
}
else
{
msgbox,,提示信息,% error_msg
return
}
}

ieproxy:
gui, submit, nohide
CF_RegWrite("REG_DWORD","HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","Proxyenable",ieproxy)
CF_RegWrite("REG_SZ","HKCU","Software\Microsoft\Windows\CurrentVersion\Internet Settings","ProxyServer",ieproxyserver)
dllcall("wininet\InternetSetOptionW","int","0","int","39","int","0","int","0")
dllcall("wininet\InternetSetOptionW","int","0","int","37","int","0","int","0")
tooltip,代理设置完毕。
sleep,1000
tooltip
return


ip_haschanged:
ControlGetFocus, WhichControl, A
if WhichControl=Edit8
{
IPoctet1:=IPCtrlGetAddress(hIPControl,1)
IPoctet2:=IPCtrlGetAddress(hIPControl,2)
IPoctet3:=IPCtrlGetAddress(hIPControl,3)
GWoctet4:=IPCtrlGetAddress(hgatewayControl,4)
if IPoctet1 between 1 and 127
IPCtrlSetAddress(hnetmaskControl, "255.0.0.0")
if IPoctet1 between 128 and 191
IPCtrlSetAddress(hnetmaskControl, "255.255.0.0")
if (IPoctet1>191)
IPCtrlSetAddress(hnetmaskControl, "255.255.255.0")
IPCtrlSetAddress(hgatewayControl, IPoctet1 "." IPoctet2 "." IPoctet3 "." GWoctet4)
}
return

/*
; 消息列表
; SendMessage(hIpEdit,IPM_CLEARADDRESS,0,0)
IPM_CLEARADDRESS := WM_USER + 100 ; wparam 为0 Lparam为0
; nIP=MAKEIPADDRESS(192,168,0,1);   
; SendMessage(hIpEdit,IPM_SETADDRESS,0,nIP)
IPM_SETADDRESS := WM_USER + 101 ; wparam 为0 Lparam为32位的IP值
; SendMessage(hIpEdit,IPM_GETADDRESS,0,int(&nIP))
IPM_GETADDRESS := WM_USER + 102 ; wparam 为0 Lparam为一个指向Integer变量的指针(指向IP值) 返回值为字段数目
; SendMessage   (hIpEdit,   IPM_SETRANGE,   0,   200 < <8|100)
IPM_SETRANGE　:=   WM_USER + 103 ; 设置IP控件4个部分(0,1,2,3)的其中一个的IP取值范围, Wparam指明要设置取值范围的部分(0,1,2,3)；lparam的低16位字为该字段的范围：高字节为上限，低字节为下限(例子 200*256+100)
; SendMessage(hIpEdit,IPM_SETFOCUS,3,0)
IPM_SETFOCUS   :=    WM_USER + 104 ; 设输入焦点　Wparam指明哪个部分(0,1,2,3)获取焦点
; if(!SendMessage(hIpEdit,IPM_ISBLANK,0,0))
IPM_ISBLANK　 :=　 WM_USER+105 ; IP串是否为空  为空返回非0 不为空返回0
*/

IPCtrlSetAddress(hControl, ipaddress)
{
    static WM_USER := 0x400
    static IPM_SETADDRESS := WM_USER + 101

    ; 把 IP 地址打包成 32 位字以用于 SendMessage.
    ipaddrword := 0
    Loop, Parse, ipaddress, .
        ipaddrword := (ipaddrword * 256) + A_LoopField
    SendMessage IPM_SETADDRESS, 0, ipaddrword,, ahk_id %hControl%
}

IPCtrlGetAddress(hControl,n="")
{
    static WM_USER := 0x400
    static IPM_GETADDRESS := WM_USER + 102

    n :=n?n:0
    VarSetCapacity(addrword, 4)
    SendMessage IPM_GETADDRESS, 0, &addrword,, ahk_id %hControl%
  if n=1
    return NumGet(addrword, 3, "UChar") 
  else if n=2
return  NumGet(addrword, 2, "UChar") 
  else if n=3
return NumGet(addrword, 1, "UChar")
  else if n=4
return NumGet(addrword, 0, "UChar")
  else if n=0
return NumGet(addrword, 3, "UChar") "." NumGet(addrword, 2, "UChar")  "." NumGet(addrword, 1, "UChar") "." NumGet(addrword, 0, "UChar")
}

; ip + dns 
ip_toggle:
	gui, submit, nohide
	if ip_ignore
		guicontrol, disable, ip_auto
	else
		guicontrol, enable, ip_auto
		
	if (ip_ignore or ip_auto)
		action := "disable"
	else
		action := "enable"

	guicontrol, %action%, comp_ip
	guicontrol, %action%, netmask
	guicontrol, %action%, gateway
	gosub, update_cmd
return

dns_toggle:
	gui, submit, nohide
	if dns_ignore
		guicontrol, disable, dns_auto
	else
		guicontrol, enable, dns_auto
		
	if (dns_ignore or dns_auto)
		action := "disable"
	else
		action := "enable"

	guicontrol, %action%, dns_1
	guicontrol, %action%, dns_2
	gosub, update_cmd
return

gateway2comp_ip:
	gui, submit, nohide
	regexmatch(gateway, "^(.+)\.(\d+)$", segments)
	segments2 = %segments2%  ; strip spaces, still string?
	; segments2 += 1  ; casting magic
	comp_ip := segments1 "." segments2+1
	guicontrol,, comp_ip, % comp_ip
	gosub, update_cmd
return

set_google_dns:
	dns_1 := "8.8.8.8"
	dns_2 := "8.8.4.4"
	guicontrol,, dns_1, % dns_1
	guicontrol,, dns_2, % dns_2
	gosub, update_cmd
return

; gui-initiated stuff
update_cmd:
	gui, submit, nohide
	cmd := ""
	if not ip_ignore
	{
		if ip_auto
			cmd .= "netsh interface ip set address """ interface """ source = dhcp & "
		else
			cmd .= "netsh interface ipv4 set address name=""" interface """ source=static address=" comp_ip " mask=" netmask " gateway=" gateway " & "
	}

	if not dns_ignore
	{
		if dns_auto
			cmd .= "netsh interface ip set dns """ interface """ dhcp & "
		else
		{
			if dns_1 != 0.0.0.0
				cmd .= "netsh interface ip set dns name=""" interface """ static " dns_1 " & "
			if dns_2 != 0.0.0.0
				cmd .= "netsh interface ip add dns name=""" interface """ addr=" dns_2 " index=2 & "
		}	
	}
	cmd:=StrReplace(cmd,"已禁用 ")
	cmd:=StrReplace(cmd,"已启用 ")
	cmd := regexreplace(cmd, "& $", "")
	guicontrol,, cmd, % cmd
return

update_gui:
	controls = 
	(
		ip_ignore
		ip_auto
		comp_ip
		netmask
		gateway
		dns_ignore
		dns_auto
		dns_1
		dns_2
	)

	loop, parse, controls, `n, `r%A_Tab%%A_Space%
		guicontrol,, %A_LoopField%, % %A_LoopField%
	
	gosub, ip_toggle
	gosub, dns_toggle
	gosub, update_cmd
return

preset_select:
	gui, submit, nohide
	
	iniread, ip_ignore, % presets_ini_file, % preset, ip_ignore, 0
	if not ip_ignore
	{
		iniread, ip_auto, % presets_ini_file, % preset, ip_auto, 0
		if not ip_auto
		{
			iniread, comp_ip, % presets_ini_file, % preset, comp_ip, 
			iniread, netmask, % presets_ini_file, % preset, netmask, 
			iniread, gateway, % presets_ini_file, % preset, gateway, 
		}
	}
	
	iniread, dns_ignore, % presets_ini_file, % preset, dns_ignore, 0
	if not dns_ignore
	{
		iniread, dns_auto, % presets_ini_file, % preset, dns_auto, 0
		if not dns_auto
		{
			iniread, dns_1, % presets_ini_file, % preset, dns_2, 
			iniread, dns_2, % presets_ini_file, % preset, dns_1, 
		}
	}
	
	gosub, update_gui
	
	if (A_GuiEvent == "DoubleClick")
		gosub, run_cmd
return

run_cmd:
	gui, submit, nohide
	filedelete, error.tmp
	cmd:=StrReplace(cmd,"&",">>error.tmp &") ">>error.tmp"
	RunWait, %comspec% /c %cmd%,,hide
check_error("error.tmp","IP 设置应用完成")
return

save:
	gui, submit, nohide
	inputbox, name, 保存设置到方案 , 请输入方案名称,,,,,,,, % comp_ip
	if ErrorLevel
	{
		return
	}

	; check if already exists
	current_sections := ini_get_sections(presets_ini_file)
	loop, parse, current_sections, |
	{
		if (name == A_LoopField)
		{
			msgbox 方案名 %name% 已经存在.`n请输入新的名称.
			return
		}
	}
	
	iniwrite, % ip_ignore, % presets_ini_file, % name, ip_ignore
	if not ip_ignore
	{
		iniwrite, % ip_auto, % presets_ini_file, % name, ip_auto
		if not ip_auto
		{
			iniwrite, % comp_ip, % presets_ini_file, % name, comp_ip
			iniwrite, % netmask, % presets_ini_file, % name, netmask
			iniwrite, % gateway, % presets_ini_file, % name, gateway
		}
	}
	
	iniwrite, % dns_ignore, % presets_ini_file, % name, dns_ignore
	if not dns_ignore
	{
		iniwrite, % dns_auto, % presets_ini_file, % name, dns_auto
		if not dns_auto
		{
			iniwrite, % dns_1, % presets_ini_file, % name, dns_1
			iniwrite, % dns_2, % presets_ini_file, % name, dns_2
		}
	}
	
	guicontrol,, preset, % name  ; TODO: select new entry?
	GuiControl, ChooseString, preset, % name
return

ping:
	gui, submit, nohide
	; run, %comspec% /c ping -t %gateway%
	ShellRun("ping", "-t " gateway)  ; gotta run as de-elevated user
return

browse:
	gui, submit, nohide

	; gt57's, from http://www.autohotkey.com/board/topic/84785-default-browser-path-and-executable/
	; RegRead, browser, HKCR, .html  ; use this for XP, I think it was working on 7 too.
	RegRead, browser, HKCU, Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.html\UserChoice, Progid
	RegRead, browser_cmd, HKCR, %browser%\shell\open\command  ; Get path to default browser + options

	; string has the form "path to browser" arg1 arg2 OR pathtobrowserwithoutspaces arg1 arg2
	regexmatch(browser_cmd, "^("".*?""|[^\s]+) (.*)", browser_cmd_split)
	
	stringreplace, browser_cmd_split2, browser_cmd_split2, `%1, % gateway
	
	ShellRun(browser_cmd_split1, browser_cmd_split2)
return

ssh:
telnet:
	gui, submit, nohide
	
	ShellRun(putty, "-" A_ThisLabel " " gateway)
	; run, "%putty%" -%A_ThisLabel% %gateway%
return

del::
context_preset_delete:
	guicontrolget, focused, FocusV
	if (focused != "preset")
	{
		; send, %A_ThisHotkey%
		send, {del}
		return
	}
preset_delete:
	gui, submit, nohide
	ini_delete_section(presets_ini_file, preset)
	guicontrol,, preset, % "|" ini_get_sections(presets_ini_file)
return

^up::
context_preset_up:
	guicontrolget, focused, FocusV
	if (focused != "preset")
	{
		; send, %A_ThisHotkey%
		send, ^{up}
		return
	}
preset_up:
	gui, submit, nohide
	ini_move_section_up(presets_ini_file, preset)
	
	guicontrol, +altsubmit, preset
	gui, submit, nohide
	
	guicontrol,, preset, % "|" ini_get_sections(presets_ini_file)

	if (preset > 1)
		preset -= 1
	
	guicontrol, choose, preset, % preset
	guicontrol, -altsubmit, preset
return

^Down::
context_preset_down:
	guicontrolget, focused, FocusV
	if (focused != "preset")
	{
		; send, %A_ThisHotkey%
		send, ^{down}
		return
	}
preset_down:
	gui, submit, nohide
	ini_move_section_down(presets_ini_file, preset)
	
	guicontrol, +altsubmit, preset
	gui, submit, nohide
	
	guicontrol,, preset, % "|" ini_get_sections(presets_ini_file)
	
	if ( preset < LB_get_count(presets_hwnd) ) 
		preset += 1
	
	guicontrol, choose, preset, % preset
	guicontrol, -altsubmit, preset
return


; from https://msdn.microsoft.com/en-us/library/windows/desktop/bb775195(v=vs.85).aspx
; get the number of items in a listbox
LB_get_count(hwnd) {
	SendMessage, 0x018B, 0, 0, ,ahk_id %hwnd%  ; 0x018B is LB_GETCOUNT
	return ErrorLevel
}

; ------------------------------------------------------------------------------------
; beginning includefile: ini.ahk
; ------------------------------------------------------------------------------------

ini_get_sections(file) {
	sections := ""
	loop, read, % file
	{
		RegexMatch(A_LoopReadLine, "^\[(.*)\]$", match)  
			; couldn't make this work with multiline regex (option "m")
			; something like "m)^\[[^\]]+\]$"
			; "m)  ^  \[  [^\]]+  \]  $"

		if (match1) 
		{
			sections .= match1 "|"
		}
	}
	
	return % sections
}

ini_delete_section(ini_file, ini_section) {
	fileread, ini_contents, % ini_file
	ini_contents := regexreplace(ini_contents, "s)\[" . ini_section . "\].*?(?=(\[.+]|$))")
	filedelete, % ini_file
	fileappend, % ini_contents, % ini_file
}

ini_move_section_up(file, section) {
	fileread, ini_contents, % file
	
	stringreplace, ini_contents, ini_contents, % section, PLACEHOLDER
		; avoid especially dots in regex pattern
	
	ini_contents := regexreplace(ini_contents, "(\r?\n)*$", "`r`n")
		; if moving the last one and there's no newline at the end of file, put one there.
	
	ini_contents := regexreplace(ini_contents, "(\[[^\[]+)\[PLACEHOLDER]([^\[]+)", "[PLACEHOLDER]$2$1")  

	stringreplace, ini_contents, ini_contents, PLACEHOLDER, % section

	filedelete, % file
	fileappend, % ini_contents, % file
}

ini_move_section_down(file, section) {
	fileread, ini_contents, % file
	
	stringreplace, ini_contents, ini_contents, % section, PLACEHOLDER
	
	ini_contents := regexreplace(ini_contents, "(\r?\n)*$", "`r`n")
		; add last newline, don't know if needed in this case
		
	ini_contents := regexreplace(ini_contents, "\[PLACEHOLDER\]([^\[]+)(\[[^\[]+)?", "$2[PLACEHOLDER]$1")
	
	stringreplace, ini_contents, ini_contents, PLACEHOLDER, % section
	
	filedelete, % file
	fileappend, % ini_contents, % file	
}


; ------------------------------------------------------------------------------------
; ending includefile: ini.ahk
; ------------------------------------------------------------------------------------


; ------------------------------------------------------------------------------------
; beginning includefile: shellrun.ahk
; ------------------------------------------------------------------------------------

/*
  ShellRun by Lexikos
    requires: AutoHotkey_L
    license: http://creativecommons.org/publicdomain/zero/1.0/

  Credit for explaining this method goes to BrandonLive:
  http://brandonlive.com/2008/04/27/getting-the-shell-to-run-an-application-for-you-part-2-how/
 
  Shell.ShellExecute(File [, Arguments, Directory, Operation, Show])
  http://msdn.microsoft.com/en-us/library/windows/desktop/gg537745
*/
ShellRun(prms*)
{
    shellWindows := ComObjCreate("{9BA05972-F6A8-11CF-A442-00A0C90A8F39}")
    
    desktop := shellWindows.Item(ComObj(19, 8)) ; VT_UI4, SCW_DESKTOP                
   
    ; Retrieve top-level browser object.
    if ptlb := ComObjQuery(desktop
        , "{4C96BE40-915C-11CF-99D3-00AA004AE837}"  ; SID_STopLevelBrowser
        , "{000214E2-0000-0000-C000-000000000046}") ; IID_IShellBrowser
    {
        ; IShellBrowser.QueryActiveShellView -> IShellView
        if DllCall(NumGet(NumGet(ptlb+0)+15*A_PtrSize), "ptr", ptlb, "ptr*", psv:=0) = 0
        {
            ; Define IID_IDispatch.
            VarSetCapacity(IID_IDispatch, 16)
            NumPut(0x46000000000000C0, NumPut(0x20400, IID_IDispatch, "int64"), "int64")
           
            ; IShellView.GetItemObject -> IDispatch (object which implements IShellFolderViewDual)
            DllCall(NumGet(NumGet(psv+0)+15*A_PtrSize), "ptr", psv
                , "uint", 0, "ptr", &IID_IDispatch, "ptr*", pdisp:=0)
           
            ; Get Shell object.
            shell := ComObj(9,pdisp,1).Application
           
            ; IShellDispatch2.ShellExecute
            shell.ShellExecute(prms*)
           
            ObjRelease(psv)
        }
        ObjRelease(ptlb)
    }
}

; ------------------------------------------------------------------------------------
; ending includefile: shellrun.ahk
; ------------------------------------------------------------------------------------

#include %A_ScriptDir%\..\Lib\CF.ahk
