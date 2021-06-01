Windo_WPS_RunVba:
Application := ComObjActive("ket.Application")
if !Splitted_Windy_Cmd4
try Application.run("'" Application.ActiveWorkbook.FullName "'!" Splitted_Windy_Cmd3)
else
try Application.run("'" Application.ActiveWorkbook.FullName "'!" Splitted_Windy_Cmd3, Splitted_Windy_Cmd4)
ObjRelease(&Application)
;Application.ActiveWorkbook.run("!模块1.二合一函数")
;Application.ActiveSheet.run("!模块1.二合一函数")
;tooltip % "'" Application.ActiveWorkbook.FullName "'!模块1.二合一函数"
return

/*
wps  VB 宏（Alt+F8）中的选项  指定快捷键
在wps更新后，快捷键失效

同一个excel文件的方法调用：
module3/4/5在同一个excel文件。module5利用application.run调用其他module的sub/function时，如果该sub/function名在所有module里唯一，可以不加模块名(推荐全加模块名)。否则报错，需要模块名.方法名调用。
模块名和方法名都不区分大小写。

不同excel文件的方法调用：
方法1：Application.Run " ‘文件名’ “!模块名.方法名”
方法2：Application.Run " ‘路径+文件名’ “!模块名.方法名”
必须带上文件名和模块名，即使方法在该文件唯一。且文件名两边有单引号，文件名和模块名间有!。
如果被调用的工作簿是打开状态，方法1和方法2都可以。如果是关闭状态，方法2会打开路径+文件名进行调用，方法1会打开当前文件路径+文件名进行调用。
*/