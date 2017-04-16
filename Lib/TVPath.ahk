; 注册表打开时跳转到相应条目 主窗口_OpenButton.ahk
; 复制注册表相应条目路径  注册表.ahk

;TVPath_Get()      Written By wz520 [wingzero1040~gmail.com]
;读取任意 TreeView 控件的选中项目的路径。格式如 Root\Parent\SelectedItem
;参数：
;hTreeView: SysTreeView32的句柄(HWND)，用ControlGet, hwnd取得
;outPath: 输出参数，接收结果。
;返回值: 字符串，指示错误出现的位置。无错误返回空串。
TVPath_Get(hTreeView, ByRef outPath)
{
	;消息和消息参数常量
	TVM_GETITEM = 0x110C
	TVM_GETNEXTITEM = 0x110A
	TVGN_CARET = 0X09
	TVGN_PARENT = 0x03
	TVIF_TEXT = 0x01
	NULL = 0
	;变量
	cchTextMax=512
	sizeof_TVITEM=40
	outPath=
	VarSetCapacity(szText, cchTextMax, 0)
	VarSetCapacity(tvitem, sizeof_TVITEM, 0)

	;获取选中项目的HTREEITEM
	SendMessage, TVM_GETNEXTITEM, TVGN_CARET, 0, ,ahk_id %hTreeView%
	if(errorlevel=NULL) ;没有选中项目
		return "selection"
	Else
		hSelItem:=errorlevel

	;以下Process系函数用
	;常量声明
	PROCESS_VM_OPERATION=0x8
	PROCESS_VM_WRITE=0x20
	PROCESS_VM_READ=0x10

	MEM_COMMIT=0x1000
	MEM_FREE=0x10000
	PAGE_READWRITE=0x4
	;常量声明结束

	;变量初始化
	hProcess=0
	ret=0
	HasError:=""
	;变量初始化结束

	ControlGet, hwnd, HWND, , ,ahk_id %hTreeView%
	WinGet, pid, PID, ahk_id %hwnd%
	if (!pid)
		return "pid"

	hProcess:=DllCall("OpenProcess"
		, uint, PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ
		, int, 0, uint, pid, uint)
	if (hProcess)
	{
		pTVItemRemote:=DllCall("VirtualAllocEx"
			, uint, hProcess
			, uint, 0
			, uint, sizeof_TVITEM
			, uint, MEM_COMMIT
			, uint, PAGE_READWRITE)
		pszTextRemote:=DllCall("VirtualAllocEx"
			, uint, hProcess
			, uint, 0
			, uint, cchTextMax
			, uint, MEM_COMMIT
			, uint, PAGE_READWRITE)
		if (pszTextRemote && pTVItemRemote)
		{
			while hSelItem != 0 ;到根节点结束
			{
				;写tvitem结构体
				NumPut(TVIF_TEXT, tvitem, 0) ;mask
				NumPut(hSelItem, tvitem, 4) ;hItem
				NumPut(pszTextRemote, tvitem, 16) ;szText
				NumPut(cchTextMax, tvitem, 20) ;cchTextMax

				ret := DllCall("WriteProcessMemory"
					, uint, hProcess
					, uint, pTVItemRemote
					, uint, &tvitem
					, uint, sizeof_TVITEM
					, uint, 0)
				if (ret)
				{
					;获取文字
					SendMessage, TVM_GETITEM, 0, pTVItemRemote, , ahk_id %hTreeView%
					if(errorlevel) ;获取文字成功
					{
						ret := DllCall("ReadProcessMemory"
							, uint, hProcess
							, uint, pszTextRemote
							, str,  szText
							, uint, cchTextMax
							, uint, 0)
						if (ret)
						{
							outPath := (outPath="") ? szText : szText . "\" . outPath
							;获取父节点
							SendMessage, TVM_GETNEXTITEM, TVGN_PARENT, hSelItem, , ahk_id %hTreeView%
							hSelItem:=errorlevel ;返回NULL则跳出
					    }
					else
					   {
							HasError:="read"
							break
						}
				   }
				   else
				      {
						HasError:="gettext"
						break
					  }
			    }
				  else
				     {
					HasError:="write"
					break
				      }
			}
	    }
	else
	HasError:="alloc"
   }
    else
	HasError:="process"


	;释放内存
	if(pszTextRemote)
		DllCall("VirtualFreeEx"
			,uint, hProcess
			,uint, pszTextRemote
			,uint, cchTextMax
			,uint, MEM_FREE)
	if(pTVItemRemote)
		DllCall("VirtualFreeEx"
			,uint, hProcess
			,uint, pTVItemRemote
			,uint, sizeof_TVITEM
			,uint, MEM_FREE)
	if(hProcess)
		DllCall("CloseHandle", uint, hProcess)

	return HasError
}


;TVPath_Set()      Written By wz520 [wingzero1040~gmail.com]
;选中任意 TreeView 控件的节点。格式如 Root\Parent\Item
;参数：
;hTreeView: SysTreeView32的句柄(HWND)，用ControlGet, hwnd取得
;inPath: 需要设置的路径，用"\"分隔。
;outMatchPath: 输出参数，返回实际选中项目的路径。
;返回值: 字符串，指示错误出现的位置。无错误返回空串。
TVPath_Set(hTreeView, inPath, ByRef outMatchPath)
{
	;消息和消息参数常量
	TVM_GETITEM = 0x110C
	TVM_GETNEXTITEM = 0x110A

	TVGN_CARET = 0X09
    TVGN_CHILD = 0x04
    TVGN_NEXT = 0x01
    TVGN_ROOT = 0

	TVIF_TEXT = 0x01
	NULL = 0
	;变量
	cchTextMax=512
	sizeof_TVITEM=40
	VarSetCapacity(szText, cchTextMax, 0)
	VarSetCapacity(tvitem, sizeof_TVITEM, 0)

	;获取根节点的HTREEITEM
	SendMessage, TVM_GETNEXTITEM, TVGN_ROOT, 0, ,ahk_id %hTreeView%
	if(errorlevel=NULL) ;没有根节点
		return "root"
	Else
		hSelItem:=errorlevel

	;以下Process系函数用
	;常量声明
	PROCESS_VM_OPERATION=0x8
	PROCESS_VM_WRITE=0x20
	PROCESS_VM_READ=0x10

	MEM_COMMIT=0x1000
	MEM_FREE=0x10000
	PAGE_READWRITE=0x4
	;常量声明结束

	;变量初始化
	hProcess=0
	ret=0
	HasError:=""
	;变量初始化结束

	ControlGet, hwnd, HWND, , ,ahk_id %hTreeView%
	WinGet, pid, PID, ahk_id %hwnd%
	if (!pid)
		return "pid"

	hProcess:=DllCall("OpenProcess"
		, uint, PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ
		, int, 0, uint, pid, uint)
	if (hProcess)
	{
		pTVItemRemote:=DllCall("VirtualAllocEx"
			, uint, hProcess
			, uint, 0
			, uint, sizeof_TVITEM
			, uint, MEM_COMMIT
			, uint, PAGE_READWRITE)
		pszTextRemote:=DllCall("VirtualAllocEx"
			, uint, hProcess
			, uint, 0
			, uint, cchTextMax
			, uint, MEM_COMMIT
			, uint, PAGE_READWRITE)
		if (pszTextRemote && pTVItemRemote)
			__dummySetPathToTreeView(hProcess, hTreeView, hSelItem, inPath, tvitem, szText, pszTextRemote, pTVItemRemote, inPath, outMatchPath, HasError)
		else
			HasError:="alloc"
	} else
		HasError:="process"

	;释放内存
	if(pszTextRemote)
		DllCall("VirtualFreeEx"
			,uint, hProcess
			,uint, pszTextRemote
			,uint, cchTextMax
			,uint, MEM_FREE)
	if(pTVItemRemote)
		DllCall("VirtualFreeEx"
			,uint, hProcess
			,uint, pTVItemRemote
			,uint, sizeof_TVITEM
			,uint, MEM_FREE)
	if(hProcess)
		DllCall("CloseHandle", uint, hProcess)

	return HasError
}

;由 TVPath_Set 函数调用，勿直接调用此函数。
__dummySetPathToTreeView(hProcess, hTreeView, hItem, RestPath, ByRef tvitem, ByRef szText, pszTextRemote, pTVItemRemote, ByRef FullPath, ByRef MatchPath, ByRef HasError)
{
	if RestPath=
		return
	FindText:=RegExReplace(RestPath, "\\.*$")
	StringTrimLeft, RestPath, RestPath, % StrLen(FindText)+1

 	;消息和消息参数常量
	TVM_EXPAND = 0x1102
	TVM_GETITEM = 0x110C
	TVM_GETNEXTITEM = 0x110A
    TVM_SELECTITEM = 0x110B

	TVGN_CARET = 0X09
    TVGN_CHILD = 0x04
    TVGN_NEXT = 0x01

    TVE_EXPAND = 0x02
	TVIF_TEXT = 0x01
	;变量
	cchTextMax=512
	sizeof_TVITEM=40
	while hItem != 0
	{
		;写tvitem结构体
		NumPut(TVIF_TEXT, tvitem, 0) ;mask
		NumPut(hItem, tvitem, 4) ;hItem
		NumPut(pszTextRemote, tvitem, 16) ;szText
		NumPut(cchTextMax, tvitem, 20) ;cchTextMax

		;准备获取文字
		ret := DllCall("WriteProcessMemory"
			, uint, hProcess
			, uint, pTVItemRemote
			, uint, &tvitem
			, uint, sizeof_TVITEM
			, uint, 0)
		if (ret)
		{
			;获取文字
			SendMessage, TVM_GETITEM, 0, pTVItemRemote, , ahk_id %hTreeView%
			if(errorlevel) ;获取文字成功
			{
				ret := DllCall("ReadProcessMemory"
					, uint, hProcess
					, uint, pszTextRemote
					, str,  szText
					, uint, cchTextMax
					, uint, 0)
				if (ret)
				{
					if (szText=FindText) ;符合要搜索的路径
					{
						StringTrimRight, MatchPath, FullPath, % StrLen(RestPath)
						;选中节点
						SendMessage, TVM_SELECTITEM, TVGN_CARET, hItem, , ahk_id %hTreeView%
						;展开
						SendMessage, TVM_EXPAND, TVE_EXPAND, hItem, , ahk_id %hTreeView%
						if errorlevel ;展开成功
						{
							;获取第一个子节点
							SendMessage, TVM_GETNEXTITEM, TVGN_CHILD, hItem, , ahk_id %hTreeView%
							hItem:=errorlevel
							;递归查找下一层
							__dummySetPathToTreeView(hProcess, hTreeView, hItem, RestPath, tvitem, szText, pszTextRemote, pTVItemRemote, FullPath, MatchPath, HasError)
						}
						break
					}
				} else {
					HasError:="read"
					break
				}
			} else {
				HasError:="gettext"
				break
			}
		} else {
			HasError:="write"
			break
		}
		;获取下一个同级节点
		SendMessage, TVM_GETNEXTITEM, TVGN_NEXT, hItem, , ahk_id %hTreeView%
		hItem:=errorlevel
	}
}