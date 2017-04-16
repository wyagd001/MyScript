changyong:
Menu, f_Folders, Add, &C:\, C:\
Menu, f_Folders, Add, &D:\, D:\
Menu, f_Folders, Add, &E:\, E:\
Menu, f_Folders, Add, 我的文档, 我的文档
Menu, f_Folders, Add, 程序文件夹, 程序文件夹

Menu, tabs, Add, 文件夹(&F), :f_Folders
Menu, tabs, Add, 我的电脑(&C), 我的电脑
Menu, tabs, Add, 网络连接(&N), 网络连接
Menu, tabs, Add, 控制面板(&P), 控制面板
Menu, tabs, Add, 回收站(&R), 回收站
Menu, tabs, Add
Menu, tabs, Add, 注销(&L),注销
Menu, tabs, Add, 待机(&D),待机
Menu, tabs, Add, 重启(&U),重启
Menu, tabs, Add, 关机(&S),关机
Menu, tabs,Show
Menu, tabs,Deleteall
Return

我的电脑:
Run ::{20d04fe0-3aea-1069-a2d8-08002b30309d}
Return

网络连接:
run ::{7007ACC7-3202-11D1-AAD2-00805FC1270E}
Return

控制面板:
Run ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\::{21EC2020-3AEA-1069-A2DD-08002B30309D}
;run control.exe
Return

回收站:
Run ::{645FF040-5081-101B-9F08-00AA002F954E}
Return

C:\:
Run C:\
Return

D:\:
Run D:\
Return

E:\:
Run E:\
Return

我的文档:
Run ::{450d8fba-ad25-11d0-98a8-0800361b1103}
Return

程序文件夹:
Run C:\Program Files
Return

注销:
Shutdown, 0
Return

关机:
Shutdown,1
Return

重启:
Shutdown,2
Return

待机:
DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
Return