cando_智能解压:
If !CandySel
Return
Loop Parse, CandySel, `n, `r
	7z_smart_Unarchiver(A_LoopField)
Return
