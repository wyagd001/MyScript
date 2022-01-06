MG_changyong:
Menu, f_Folders, Add, &C:\, RunMenu
Menu, f_Folders, Add, &D:\, RunMenu
Menu, f_Folders, Add, &E:\, RunMenu

Menu, S_Folders, Add, 截图保存目录, RunMenu

Menu, tabs, Add, 硬盘分区(&F), :f_Folders
Menu, tabs, Add, 脚本变量目录, :S_Folders
Menu, tabs, Add, 计算机(&C), RunMenu
Menu, tabs, Add, 回收站(&R), RunMenu
Menu, tabs, Add, 我的文档, RunMenu
Menu, tabs, Add, 程序文件夹, RunMenu
Menu, tabs, Add

Menu, tabs, Add, 网络连接(&N), RunMenu
Menu, tabs, Add, 控制面板(&P), RunMenu
Menu, tabs, Add

Menu, tabs, Add, 注销(&L), RunMenu
Menu, tabs, Add, 待机(&D), RunMenu
Menu, tabs, Add, 重启(&U), RunMenu
Menu, tabs, Add, 关机(&S), RunMenu
Menu, tabs, Show
Menu, tabs, Deleteall
Return

程序文件夹:
Run %A_ProgramFiles%
Return

截图保存目录:
Run % screenshot_path
return

注销:
Shutdown, 0
Return

关机:
Shutdown, 1
Return

重启:
Shutdown, 2
Return

待机:
DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
Return

RunMenu(ItemName, ItemPos, MenuName)
{
	ItemName := StrReplace(ItemName, "&")
	ItemName := RegExReplace(ItemName, "\(.*\)")
	MenuArray := {"::{645FF040-5081-101B-9F08-00AA002F954E}":"回收站","::{450d8fba-ad25-11d0-98a8-0800361b1103}":"我的文档","::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}":"网络","::{20D04FE0-3AEA-1069-A2D8-08002B30309D}":"计算机","::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\::{21EC2020-3AEA-1069-A2DD-08002B30309D}":"控制面板","::{031E4825-7B94-4DC3-B131-E946B44C8DD5}":"库","Documents.library-ms":"文档库","Music.library-ms":"音乐库","Pictures.library-ms":"图片库","Videos.library-ms":"视频库","::{7B81BE6A-CE2B-4676-A29E-EB907A5126C5}":"程序和功能","::{21EC2020-3AEA-1069-A2DD-08002B30309D}\::{7007ACC7-3202-11D1-AAD2-00805FC1270E}":"网络连接","::{8E908FC9-BECC-40F6-915B-F4CA0E70D03D}":"网络和共享中心","::{BB06C0E4-D293-4F75-8A90-CB05B6477EEE}":"系统","::{60632754-C523-4B62-B45C-4172DA012619}":"用户帐户","::{78F3955E-3B90-4184-BD14-5397C15F1EFC}\PerfCenterAdvTools":"高级工具","::{ED834ED6-4B5A-4BFE-8F11-A626DCB6A921}":"个性化","::{05D7B0F4-2121-4EFF-BF6B-ED3F69B894D9}":"通知区域图标","::{78F3955E-3B90-4184-BD14-5397C15F1EFC}":"性能信息和工具","::{C555438B-3C23-4769-A71F-B6D3D9B6053A}":"显示","::{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}":"操作中心","::{025A5937-A6BE-4686-A844-36FE4BEC8B6D}":"电源选项","::{2227A280-3AEA-1069-A2DE-08002B30309D}":"打印机和传真","::{208D2C60-3AEA-1069-A2D7-08002B30309D}":"网上邻居","::{A8A91A66-3A7D-4424-8D24-04E180695C7A}":"设备和打印机"}
	for k,v in MenuArray
	{
		if (v=ItemName)
		{
			run % k
			return
		}
	}
	if FileExist(ItemName)
		run % ItemName
	else if IsLabel(ItemName)
		Gosub % ItemName
return
}